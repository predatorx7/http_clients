import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../wrapper.dart';
import 'exception.dart';

typedef RequestInterceptorCallback = FutureOr<void> Function(
  BaseRequest,
);

class RequestInterceptorException extends InterceptorException {
  const RequestInterceptorException(
    super.message, {
    super.uri,
    super.innerException,
    super.innerStackTrace,
  });
}

mixin RequestInterceptorMixin {
  @protected
  Iterable<RequestInterceptorCallback>? get requestInterceptors;

  @protected
  Future<void> onInterceptRequest(BaseRequest request) async {
    final requestInterceptors = this.requestInterceptors;
    if (requestInterceptors == null || requestInterceptors.isEmpty) return;

    for (final interceptor in requestInterceptors) {
      try {
        await interceptor(request);
      } catch (e, s) {
        throw RequestInterceptorException(
          'Request Interceptor failed due to an error',
          uri: request.url,
          innerException: e,
          innerStackTrace: s,
        );
      }
    }
  }
}

/// {@category Clients}
class RequestInterceptorClient extends WrapperClient
    with RequestInterceptorMixin {
  RequestInterceptorClient(
    super.client,
    this.interceptors,
  );

  final Iterable<RequestInterceptorCallback> interceptors;

  @override
  Iterable<RequestInterceptorCallback> get requestInterceptors => interceptors;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    await onInterceptRequest(request);
    return inner.send(request);
  }
}
