import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../wrapper.dart';

typedef ResponseInterceptorCallback = void Function(
  StreamedResponse,
);

class ResponseInterceptorClient extends WrapperClient {
  final Iterable<ResponseInterceptorCallback> interceptors;

  ResponseInterceptorClient(
    Client client,
    this.interceptors,
  ) : super(client);

  @protected
  void onInterceptResponse(StreamedResponse response) {
    if (interceptors.isEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(response);
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await inner.send(request);
    onInterceptResponse(response);
    return response;
  }
}
