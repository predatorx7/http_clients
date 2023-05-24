import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../wrapper.dart';

typedef RequestConverterCallback = FutureOr<BaseRequest> Function(
  BaseRequest,
);

class RequestConverterClient extends WrapperClient {
  final Iterable<RequestConverterCallback> converters;

  RequestConverterClient(
    Client client,
    this.converters,
  ) : super(client);

  @protected
  FutureOr<BaseRequest> onConvertRequest(BaseRequest request) async {
    if (converters.isEmpty) return request;
    BaseRequest modifiedRequest = request;

    for (final converter in converters) {
      modifiedRequest = await converter(modifiedRequest);
    }

    return modifiedRequest;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return inner.send(await onConvertRequest(request));
  }
}
