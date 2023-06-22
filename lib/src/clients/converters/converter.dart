import 'dart:async';

import 'package:http/http.dart';

import '../wrapper.dart';
import 'request.dart';
import 'response.dart';

export 'exception.dart';
export 'request.dart';
export 'response.dart';

/// {@category Clients}
class ConverterClient extends WrapperClient
    with RequestConverterMixin, ResponseConverterMixin {
  @override
  final Iterable<RequestConverterCallback>? requestConverters;
  @override
  final Iterable<ResponseConverterCallback>? responseConverters;

  ConverterClient(
    super.client, {
    this.requestConverters,
    this.responseConverters,
  });

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final modifiedRequest = await onConvertRequest(request);
    final response = await inner.send(modifiedRequest);
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }
}
