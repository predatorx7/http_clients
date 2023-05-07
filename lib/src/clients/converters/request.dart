import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

typedef RequestConvertorCallback = FutureOr<BaseRequest> Function(
  BaseRequest,
);

class RequestConvertorClient extends BaseClient {
  final BaseClient _inner;
  final Iterable<RequestConvertorCallback> convertors;

  RequestConvertorClient(
    this._inner,
    this.convertors,
  );

  @protected
  FutureOr<BaseRequest> onConvertRequest(BaseRequest request) async {
    if (convertors.isNotEmpty) return request;
    BaseRequest modifiedRequest = request;

    for (final convertor in convertors) {
      modifiedRequest = await convertor(modifiedRequest);
    }

    return modifiedRequest;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return _inner.send(await onConvertRequest(request));
  }
}
