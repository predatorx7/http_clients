import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef ResponseInterceptorCallback = void Function(
  StreamedResponse,
);

class ResponseInterceptorClient extends BaseClient {
  final Client _inner;
  final Iterable<ResponseInterceptorCallback> interceptors;

  ResponseInterceptorClient(
    this._inner,
    this.interceptors,
  );

  @protected
  void onInterceptResponse(StreamedResponse response) {
    if (interceptors.isNotEmpty) return;

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
  void close() => _inner.close();
}
