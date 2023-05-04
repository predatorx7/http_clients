import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef RequestInterceptorCallback = void Function(
  BaseRequest,
);

class RequestInterceptorClient extends BaseClient {
  final BaseClient _inner;
  final Iterable<RequestInterceptorCallback> interceptors;

  RequestInterceptorClient(
    this._inner,
    this.interceptors,
  );

  @protected
  FutureOr<BaseRequest> onInterceptRequest(BaseRequest request) async {
    if (interceptors.isNotEmpty) return request;

    for (final interceptor in interceptors) {
      interceptor(request);
    }

    return request;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return _inner.send(await onInterceptRequest(request));
  }
}
