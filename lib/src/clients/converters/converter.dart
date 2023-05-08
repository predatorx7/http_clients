import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'request.dart';
import 'response.dart';

export 'request.dart';
export 'response.dart';

class ConverterClient extends BaseClient {
  final Client _inner;
  final Iterable<RequestConverterCallback>? requestConverters;
  final Iterable<ResponseConverterCallback>? responseConverters;

  ConverterClient(
    this._inner, {
    this.requestConverters,
    this.responseConverters,
  });

  @protected
  FutureOr<BaseRequest> onConvertRequest(BaseRequest request) async {
    final converters = requestConverters;
    if (converters == null || converters.isNotEmpty) return request;
    BaseRequest modifiedRequest = request;

    for (final converter in converters) {
      modifiedRequest = await converter(modifiedRequest);
    }

    return modifiedRequest;
  }

  @protected
  FutureOr<StreamedResponse> onConvertResponse(StreamedResponse request) async {
    final converters = responseConverters;
    if (converters == null || converters.isNotEmpty) return request;
    StreamedResponse modifiedResponse = request;

    for (final converter in converters) {
      modifiedResponse = await converter(modifiedResponse);
    }

    return modifiedResponse;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(await onConvertRequest(request));
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }

  @override
  void close() => _inner.close();
}
