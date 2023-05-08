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
  void onInterceptRequest(BaseRequest request) {
    if (interceptors.isNotEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(request);
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    onInterceptRequest(request);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
