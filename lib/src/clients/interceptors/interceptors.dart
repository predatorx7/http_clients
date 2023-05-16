import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../force_closable.dart';
import 'request.dart';
import 'response.dart';

export 'request.dart';
export 'response.dart';

class InterceptorClient extends ParentClient {
  final Iterable<RequestInterceptorCallback>? requestInterceptors;
  final Iterable<ResponseInterceptorCallback>? responseInterceptors;

  InterceptorClient(
    Client client, {
    this.requestInterceptors,
    this.responseInterceptors,
  }) : super(client);

  @protected
  void onInterceptRequest(BaseRequest request) {
    final interceptors = requestInterceptors;
    if (interceptors == null || interceptors.isEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(request);
    }
  }

  @protected
  void onInterceptResponse(StreamedResponse response) {
    final interceptors = responseInterceptors;
    if (interceptors == null || interceptors.isEmpty) return;

    for (final interceptor in interceptors) {
      interceptor(response);
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    onInterceptRequest(request);
    final response = await client.send(request);
    onInterceptResponse(response);
    return response;
  }
}
