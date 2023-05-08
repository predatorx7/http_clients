import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'request.dart';
import 'response.dart';

export 'request.dart';
export 'response.dart';

class InterceptorClient extends BaseClient {
  final Client _inner;
  final Iterable<RequestInterceptorCallback>? requestInterceptors;
  final Iterable<ResponseInterceptorCallback>? responseInterceptors;

  InterceptorClient(
    this._inner, {
    this.requestInterceptors,
    this.responseInterceptors,
  });

  @protected
  void onInterceptRequest(BaseRequest request) {
    final interceptors = requestInterceptors;
    if (interceptors == null || interceptors.isNotEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(request);
    }
  }

  @protected
  void onInterceptResponse(StreamedResponse response) {
    final interceptors = responseInterceptors;
    if (interceptors == null || interceptors.isNotEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(response);
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    onInterceptRequest(request);
    final response = await _inner.send(request);
    onInterceptResponse(response);
    return response;
  }

  @override
  void close() => _inner.close();
}
