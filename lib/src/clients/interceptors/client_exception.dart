import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../wrapper.dart';
import 'exception.dart';

typedef ClientExceptionInterceptorCallback = FutureOr<void> Function(
  BaseRequest,
  Object?,
  StackTrace,
);

class ClientExceptionInterceptorException extends InterceptorException {
  const ClientExceptionInterceptorException(
    super.message, {
    super.uri,
    super.innerException,
    super.innerStackTrace,
  });
}

mixin ClientExceptionInterceptorMixin {
  @protected
  Iterable<ClientExceptionInterceptorCallback>? get clientExceptionInterceptors;

  @protected
  Future<void> onInterceptClientException(
    BaseRequest request,
    Object? exception,
    StackTrace stackTrace,
  ) async {
    final clientExceptionInterceptors = this.clientExceptionInterceptors;
    if (clientExceptionInterceptors == null ||
        clientExceptionInterceptors.isEmpty) return;

    for (final interceptor in clientExceptionInterceptors) {
      try {
        await interceptor(request, exception, stackTrace);
      } catch (e, s) {
        throw ClientExceptionInterceptorException(
          'Client Exception Interceptor failed due to an error',
          uri: request.url,
          innerException: e,
          innerStackTrace: s,
        );
      }
    }
  }
}

/// {@category Clients}
class ClientExceptionInterceptorClient extends WrapperClient
    with ClientExceptionInterceptorMixin {
  ClientExceptionInterceptorClient(
    super.client,
    this.interceptors,
  );

  final Iterable<ClientExceptionInterceptorCallback> interceptors;

  @override
  Iterable<ClientExceptionInterceptorCallback>
      get clientExceptionInterceptors => interceptors;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    try {
      return await inner.send(request);
    } catch (error, stackTrace) {
      await onInterceptClientException(request, error, stackTrace);
      rethrow;
    }
  }
}
