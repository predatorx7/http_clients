import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../wrapper.dart';

typedef ResponseConverterCallback = FutureOr<StreamedResponse> Function(
  StreamedResponse,
);

class ResponseConverterClient extends WrapperClient {
  final Iterable<ResponseConverterCallback> converters;

  ResponseConverterClient(
    Client client,
    this.converters,
  ) : super(client);

  @protected
  FutureOr<StreamedResponse> onConvertResponse(StreamedResponse request) async {
    if (converters.isEmpty) return request;
    StreamedResponse modifiedResponse = request;

    for (final converter in converters) {
      modifiedResponse = await converter(modifiedResponse);
    }

    return modifiedResponse;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await inner.send(request);
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }
}
