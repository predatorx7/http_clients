import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../force_closable.dart';

typedef ResponseInterceptorCallback = void Function(
  StreamedResponse,
);

class ResponseInterceptorClient extends BaseClient implements ParentClient {
  final Client _inner;
  final Iterable<ResponseInterceptorCallback> interceptors;

  ResponseInterceptorClient(
    this._inner,
    this.interceptors,
  );

  @protected
  void onInterceptResponse(StreamedResponse response) {
    if (interceptors.isEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(response);
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(request);
    onInterceptResponse(response);
    return response;
  }

  @override
  void close({ bool force = false }) => force ? _inner.close() : null;
}
