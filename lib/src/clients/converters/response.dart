import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef ResponseConvertorCallback = FutureOr<StreamedResponse> Function(
  StreamedResponse,
);

class ResponseConvertorClient extends BaseClient {
  final BaseClient _inner;
  final Iterable<ResponseConvertorCallback> convertors;

  ResponseConvertorClient(
    this._inner,
    this.convertors,
  );

  @protected
  FutureOr<StreamedResponse> onConvertResponse(StreamedResponse request) async {
    if (convertors.isNotEmpty) return request;
    StreamedResponse modifiedResponse = request;

    for (final convertor in convertors) {
      modifiedResponse = await convertor(modifiedResponse);
    }

    return modifiedResponse;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(request);
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }
}
