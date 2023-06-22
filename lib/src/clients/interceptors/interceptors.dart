import 'package:http/http.dart';

import '../wrapper.dart';
import 'request.dart';
import 'response.dart';

export 'exception.dart';
export 'request.dart';
export 'response.dart';

/// {@category Clients}
class InterceptorClient extends WrapperClient
    with RequestInterceptorMixin, ResponseInterceptorMixin {
  @override
  final Iterable<RequestInterceptorCallback>? requestInterceptors;
  @override
  final Iterable<ResponseInterceptorCallback>? responseInterceptors;

  InterceptorClient(
    super.client, {
    this.requestInterceptors,
    this.responseInterceptors,
  });

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    await onInterceptRequest(request);
    final response = await inner.send(request);
    await onInterceptResponse(response);
    return response;
  }
}
