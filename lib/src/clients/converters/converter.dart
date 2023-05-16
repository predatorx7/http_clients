import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../force_closable.dart';
import 'request.dart';
import 'response.dart';

export 'request.dart';
export 'response.dart';

class ConverterClient extends ParentClient {
  final Iterable<RequestConverterCallback>? requestConverters;
  final Iterable<ResponseConverterCallback>? responseConverters;

  ConverterClient(
    Client client, {
    this.requestConverters,
    this.responseConverters,
  }) : super(client);

  @protected
  FutureOr<BaseRequest> onConvertRequest(BaseRequest request) async {
    final converters = requestConverters;
    if (converters == null || converters.isEmpty) return request;
    BaseRequest modifiedRequest = request;

    for (final converter in converters) {
      modifiedRequest = await converter(modifiedRequest);
    }

    return modifiedRequest;
  }

  @protected
  FutureOr<StreamedResponse> onConvertResponse(StreamedResponse request) async {
    final converters = responseConverters;
    if (converters == null || converters.isEmpty) return request;
    StreamedResponse modifiedResponse = request;

    for (final converter in converters) {
      modifiedResponse = await converter(modifiedResponse);
    }

    return modifiedResponse;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await client.send(await onConvertRequest(request));
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }
}
