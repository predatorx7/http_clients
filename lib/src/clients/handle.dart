import 'dart:async';

import 'package:handle/handle.dart';
import 'package:handle/src/utils/unawaited_response.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../features.dart';
import '../serializer/used_handle.dart';

class HandleException implements ClientException {
  @override
  final String message;
  @override
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

class HandleRetryLimitExceededException extends HandleException {
  final int limit;

  const HandleRetryLimitExceededException(
    super.message,
    this.limit, {
    super.uri,
    super.statusCode,
    super.innerException,
    super.innerStackTrace,
  });

  @override
  String toString() {
    return 'HandleRetryLimitExceededException: $message. Limit exceeded with $limit retires.';
  }
}

typedef WhenRequestCallback = FutureOr<BaseRequest> Function(
  BaseRequest originalRequest,
  BaseRequest lastRequest,
  FinalizedBodyStreamCallback bodyStream,
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
    FinalizedBodyStreamCallback bodyStream,
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

/// {@macro HandleClient}
///
/// Note: This adds a header 'used-handle' by default in request which is used by [JsonModelSerializer] to
/// disable asynchronous deserialization which would otherwise fail with an error if handle is used to update request.
///
/// {@category Clients}
abstract mixin class Handle
    implements Client, InnerClientWrapper, HandleInterface {
  /// {@macro Handle.client}
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
    FinalizedBodyStreamCallback bodyStream,
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
  Future<StreamedResponse> send(BaseRequest originalRequest) async {
    final request = $HandleFeatures.disableAsyncDeserializationWithHandle
        ? markHandleUsageInRequestHeaders(originalRequest)
        : originalRequest;
    int retryCount = 0;
    BaseRequest latestRequest = request;
    StreamedResponse? response;

    StreamController<List<int>>? sendBodyStreamController;
    StreamController<List<int>>? retryBodyStreamController;
    StreamSubscription<List<int>>? bodyStreamSubscription;

    FutureOr<void> disposeLatest() {
      bodyStreamSubscription?.cancel();
      sendBodyStreamController?.close();
      retryBodyStreamController?.close();
      bodyStreamSubscription = null;
      sendBodyStreamController = null;
      retryBodyStreamController = null;
    }

    do {
      try {
        disposeLatest();
        final FinalizedBodyStream body = latestRequest.finalizedBodyStream;

        sendBodyStreamController = StreamController<List<int>>();
        retryBodyStreamController = StreamController<List<int>>();
        bodyStreamSubscription = body.addStreamToSinks([
          sendBodyStreamController!.sink,
          retryBodyStreamController!.sink,
        ]);
        try {
          response = await inner.send(
            latestRequest.createCopy(sendBodyStreamController!.stream),
          );
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

        bool didConsumeBodyInCopiedRequest = false;

        FinalizedBodyStream getBodyStream() {
          didConsumeBodyInCopiedRequest = true;
          return retryBodyStreamController!.stream;
        }

        latestRequest = await getUpdatedRequest(
          request,
          latestRequest,
          getBodyStream,
          response,
          retryCount,
        );

        if (didConsumeBodyInCopiedRequest) {
          retryBodyStreamController!.close();
        }

        await onRequestRetry(latestRequest, response, retryCount);
      } on ClientException {
        disposeLatest();
        rethrow;
      } catch (e, s) {
        disposeLatest();
        throw HandleException(
          'Unexpected exception while retrying a request',
          uri: request.url,
          statusCode: response?.statusCode,
          innerException: e,
          innerStackTrace: s,
        );
      }

      retryCount++;
    } while (retryCount < HANDLE_RETRY_MAX_LIMIT);

    disposeLatest();
    throw HandleRetryLimitExceededException(
      'Too many retries',
      retryCount,
      uri: request.url,
      statusCode: response?.statusCode,
    );
  }
}

/// {@template HandleClient}
/// A client that allows retrying HTTP request with different request
/// on response or errors
/// {@endtemplate}
///
/// {@category Clients}
class HandleClient extends WrapperClient with Handle {
  /// {@template Handle.client}
  /// Creates a client that allows retrying HTTP request with different request
  /// on response or errors
  /// {@endtemplate}
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
    FinalizedBodyStreamCallback bodyStream,
    BaseResponse? response,
    int retryCount,
  ) {
    final updateRequest = this.updateRequest;
    if (updateRequest != null) {
      return updateRequest(
        originalRequest,
        lastRequest,
        bodyStream,
        response,
        retryCount,
      );
    }
    return super.getUpdatedRequest(
      originalRequest,
      lastRequest,
      bodyStream,
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
