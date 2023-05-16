import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../force_closable.dart';

typedef RequestInterceptorCallback = void Function(
  BaseRequest,
);

class RequestInterceptorClient extends BaseClient implements ParentClient {
  final Client _inner;
  final Iterable<RequestInterceptorCallback> interceptors;

  RequestInterceptorClient(
    this._inner,
    this.interceptors,
  );

  @protected
  void onInterceptRequest(BaseRequest request) {
    if (interceptors.isEmpty) return;

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
  void close({ bool force = false }) => force ? _inner.close() : null;
}
