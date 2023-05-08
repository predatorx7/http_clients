import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef RequestConverterCallback = FutureOr<BaseRequest> Function(
  BaseRequest,
);

class RequestConverterClient extends BaseClient {
  final Client _inner;
  final Iterable<RequestConverterCallback> converters;

  RequestConverterClient(
    this._inner,
    this.converters,
  );

  @protected
  FutureOr<BaseRequest> onConvertRequest(BaseRequest request) async {
    if (converters.isNotEmpty) return request;
    BaseRequest modifiedRequest = request;

    for (final converter in converters) {
      modifiedRequest = await converter(modifiedRequest);
    }

    return modifiedRequest;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return _inner.send(await onConvertRequest(request));
  }

  @override
  void close() => _inner.close();
}
