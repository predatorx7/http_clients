import 'package:http/http.dart';

import '../wrapper.dart';
import 'client_exception.dart';
import 'request.dart';
import 'response.dart';

export 'exception.dart';
export 'request.dart';
export 'response.dart';

/// {@category Clients}
class InterceptorClient extends WrapperClient
    with RequestInterceptorMixin, ResponseInterceptorMixin, ClientExceptionInterceptorMixin {
  @override
  final Iterable<RequestInterceptorCallback>? requestInterceptors;
  @override
  final Iterable<ResponseInterceptorCallback>? responseInterceptors;
  @override
  final Iterable<ClientExceptionInterceptorCallback>? clientExceptionInterceptors;

  InterceptorClient(
    super.client, {
    this.requestInterceptors,
    this.responseInterceptors,
    this.clientExceptionInterceptors,
  });

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    try {
      await onInterceptRequest(request);
      final response = await inner.send(request);
      await onInterceptResponse(response);
      return response;
    } catch (error, stackTrace) {
      await onInterceptClientException(request, error, stackTrace);
      rethrow;
    }
  }
}
