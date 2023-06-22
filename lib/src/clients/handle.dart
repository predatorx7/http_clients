import 'dart:async';

import 'package:handle/handle.dart';
import 'package:handle/src/utils/unawaited_response.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

class HandleException implements ClientException {
  final String message;
  final Uri? uri;
  final int? statusCode;
  final Object? innerException;
  final StackTrace? innerStackTrace;

  const HandleException(
    this.message, {
    this.uri,
    this.statusCode,
    this.innerException,
    this.innerStackTrace,
  });

  @override
  String toString() => 'HandleException: $message';
}

typedef WhenRequestCallback = FutureOr<BaseRequest> Function(
  BaseRequest originalRequest,
  BaseRequest lastRequest,
  BaseResponse? response,
  int retryCount,
);

typedef WhenCallback = FutureOr<bool> Function(
  BaseResponse response,
  int retryCount,
);

typedef WhenErrorCallback = FutureOr<bool> Function(
  Object object,
  StackTrace stackTrace,
  int retryCount,
);

typedef WhenRetriedCallback = FutureOr<void> Function(
  BaseRequest request,
  BaseResponse? response,
  int retryCount,
);

typedef DelayCallback = Duration Function(
  int retryCount,
);

const HANDLE_RETRY_MAX_LIMIT = 1000;

abstract class HandleInterface {
  /// This is used to determine whether a request should be retried
  @protected
  FutureOr<bool> retryRequestWhen(
    BaseResponse response,
    int retryCount,
  );

  /// This is used to determine whether a request should be retried when an
  /// error is thrown
  @protected
  FutureOr<bool> retryRequestWhenError(
    Object object,
    StackTrace stackTrace,
    int retryCount,
  );

  /// Returns a duration of delay before retrying a request
  @protected
  Duration? calculateDelay(int retryCount);

  /// Returns an updated request that should be retried
  @protected
  FutureOr<BaseRequest> getUpdatedRequest(
    BaseRequest originalRequest,
    BaseRequest lastRequest,
    BaseResponse? response,
    int retryCount,
  );

  /// This is called when a request is being retried. This is called
  /// after the request is updated and before the request is sent.
  @protected
  FutureOr<void> onRequestRetry(
    BaseRequest request,
    BaseResponse? response,
    int retryCount,
  );
}

abstract mixin class Handle
    implements Client, InnerClientWrapper, HandleInterface {
  factory Handle.client(
    Client client, {
    WhenCallback? when,
    WhenErrorCallback? whenError,
    WhenRetriedCallback? onRetry,
    DelayCallback? delay,
    WhenRequestCallback? updateRequest,
  }) = HandleClient;

  @override
  @protected
  FutureOr<bool> retryRequestWhen(
    BaseResponse response,
    int retryCount,
  ) {
    return retryCount <= 3 && response.statusCode == 503;
  }

  @override
  @protected
  FutureOr<bool> retryRequestWhenError(
    Object object,
    StackTrace stackTrace,
    int retryCount,
  ) {
    return false;
  }

  @override
  @protected
  Duration? calculateDelay(int retryCount) => null;

  @override
  @protected
  FutureOr<BaseRequest> getUpdatedRequest(
    BaseRequest originalRequest,
    BaseRequest lastRequest,
    BaseResponse? response,
    int retryCount,
  ) {
    return lastRequest;
  }

  @override
  @protected
  FutureOr<void> onRequestRetry(
    BaseRequest request,
    BaseResponse? response,
    int retryCount,
  ) {}

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    int retryCount = 0;
    BaseRequest latestRequest = request;
    StreamedResponse? response;

    while (true) {
      if (retryCount > HANDLE_RETRY_MAX_LIMIT) {
        throw HandleException(
          'Too many retries',
          uri: request.url,
          statusCode: response?.statusCode,
        );
      }
      try {
        try {
          response = await inner.send(latestRequest);
          if (!await retryRequestWhen(response, retryCount)) {
            return response;
          }
          unawaitedResponse(response);
        } catch (e, s) {
          if (!await retryRequestWhenError(e, s, retryCount)) rethrow;
        }

        final delay = calculateDelay(retryCount);
        if (delay != null) {
          await Future.delayed(delay);
        }

        latestRequest = await getUpdatedRequest(
          request,
          latestRequest,
          response,
          retryCount,
        );

        await onRequestRetry(latestRequest, response, retryCount);
      } on ClientException {
        rethrow;
      } catch (e, s) {
        throw HandleException(
          'Unexpected exception while retrying a request',
          uri: request.url,
          statusCode: response?.statusCode,
          innerException: e,
          innerStackTrace: s,
        );
      }

      retryCount++;
    }
  }
}

/// A client that allows retrying HTTP request with different request
/// on response or errors
class HandleClient extends WrapperClient with Handle {
  HandleClient(
    super.client, {
    this.when,
    this.whenError,
    this.onRetry,
    this.delay,
    this.updateRequest,
  });

  /// The callback that determines whether a request should be retried.
  @protected
  final WhenCallback? when;

  /// The callback that updates a request that should be retried.
  @protected
  final WhenRequestCallback? updateRequest;

  /// The callback that determines whether a request when an error is thrown.
  @protected
  final WhenErrorCallback? whenError;

  /// The callback to call to indicate that a request is being retried.
  @protected
  final WhenRetriedCallback? onRetry;

  /// The callback that determines how long to wait before retrying a request.
  @protected
  final DelayCallback? delay;

  @override
  @protected
  FutureOr<bool> retryRequestWhen(
    BaseResponse response,
    int retryCount,
  ) {
    final when = this.when;
    if (when != null) {
      return when(response, retryCount);
    }
    return super.retryRequestWhen(response, retryCount);
  }

  @override
  @protected
  FutureOr<bool> retryRequestWhenError(
    Object object,
    StackTrace stackTrace,
    int retryCount,
  ) {
    final whenError = this.whenError;
    if (whenError != null) {
      return whenError(object, stackTrace, retryCount);
    }
    return super.retryRequestWhenError(object, stackTrace, retryCount);
  }

  @override
  @protected
  Duration? calculateDelay(int retryCount) {
    final delay = this.delay;
    if (delay != null) {
      return delay(retryCount);
    }
    return super.calculateDelay(retryCount);
  }

  @override
  @protected
  FutureOr<BaseRequest> getUpdatedRequest(
    BaseRequest originalRequest,
    BaseRequest lastRequest,
    BaseResponse? response,
    int retryCount,
  ) {
    final updateRequest = this.updateRequest;
    if (updateRequest != null) {
      return updateRequest(
        originalRequest,
        lastRequest,
        response,
        retryCount,
      );
    }
    return super.getUpdatedRequest(
      originalRequest,
      lastRequest,
      response,
      retryCount,
    );
  }

  @override
  @protected
  FutureOr<void> onRequestRetry(
    BaseRequest request,
    BaseResponse? response,
    int retryCount,
  ) {
    final onRetry = this.onRetry;
    if (onRetry != null) {
      return onRetry(request, response, retryCount);
    }
    return super.onRequestRetry(request, response, retryCount);
  }
}
