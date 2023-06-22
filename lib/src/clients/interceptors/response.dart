import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../../utils/unawaited_response.dart';
import '../wrapper.dart';
import 'exception.dart';

typedef ResponseInterceptorCallback = FutureOr<void> Function(
  StreamedResponse,
);

class ResponseInterceptorException extends InterceptorException {
  const ResponseInterceptorException(
    super.message, {
    super.uri,
    super.innerException,
    super.innerStackTrace,
  });
}

mixin ResponseInterceptorMixin {
  @protected
  Iterable<ResponseInterceptorCallback>? get responseInterceptors;

  @protected
  Future<void> onInterceptResponse(StreamedResponse response) async {
    final responseInterceptors = this.responseInterceptors;
    if (responseInterceptors == null || responseInterceptors.isEmpty) return;

    for (final interceptor in responseInterceptors) {
      try {
        await interceptor(response);
      } catch (e, s) {
        unawaitedResponse(response);
        throw ResponseInterceptorException(
          'Response Interceptor failed due to an error',
          uri: response.request?.url,
          innerException: e,
          innerStackTrace: s,
        );
      }
    }
  }
}

/// {@category Clients}
class ResponseInterceptorClient extends WrapperClient
    with ResponseInterceptorMixin {
  ResponseInterceptorClient(
    super.client,
    this.interceptors,
  );

  final Iterable<ResponseInterceptorCallback> interceptors;

  @override
  Iterable<ResponseInterceptorCallback> get responseInterceptors =>
      interceptors;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await inner.send(request);
    await onInterceptResponse(response);
    return response;
  }
}
