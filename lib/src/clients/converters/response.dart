import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef ResponseConverterCallback = FutureOr<StreamedResponse> Function(
  StreamedResponse,
);

class ResponseConverterClient extends BaseClient {
  final Client _inner;
  final Iterable<ResponseConverterCallback> converters;

  ResponseConverterClient(
    this._inner,
    this.converters,
  );

  @protected
  FutureOr<StreamedResponse> onConvertResponse(StreamedResponse request) async {
    if (converters.isNotEmpty) return request;
    StreamedResponse modifiedResponse = request;

    for (final converter in converters) {
      modifiedResponse = await converter(modifiedResponse);
    }

    return modifiedResponse;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(request);
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }

  @override
  void close() => _inner.close();
}
