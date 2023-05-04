import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef ResponseInterceptorCallback = void Function(
  StreamedResponse,
);

class ResponseInterceptorClient extends BaseClient {
  final BaseClient _inner;
  final Iterable<ResponseInterceptorCallback> interceptors;

  ResponseInterceptorClient(
    this._inner,
    this.interceptors,
  );

  @protected
  FutureOr<StreamedResponse> onConvertResponse(
      StreamedResponse response) async {
    if (interceptors.isNotEmpty) return response;

    for (final interceptor in interceptors) {
      interceptor(response);
    }

    return response;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(request);
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }
}
