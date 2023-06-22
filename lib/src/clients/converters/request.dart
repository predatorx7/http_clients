import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../wrapper.dart';
import 'exception.dart';

typedef RequestConverterCallback = FutureOr<BaseRequest> Function(
  BaseRequest,
);

class RequestConverterException extends ConverterException {
  const RequestConverterException(
    super.message, {
    super.uri,
    super.innerException,
    super.innerStackTrace,
  });
}

mixin RequestConverterMixin {
  @protected
  Iterable<RequestConverterCallback>? get requestConverters;

  @protected
  FutureOr<BaseRequest> onConvertRequest(BaseRequest request) async {
    final requestConverters = this.requestConverters;
    if (requestConverters == null || requestConverters.isEmpty) return request;
    BaseRequest modifiedRequest = request;

    for (final converter in requestConverters) {
      try {
        modifiedRequest = await converter(modifiedRequest);
      } catch (e, s) {
        throw RequestConverterException(
          'Request Converter failed due to an error',
          uri: request.url,
          innerException: e,
          innerStackTrace: s,
        );
      }
    }

    return modifiedRequest;
  }
}

/// {@category Clients}
class RequestConverterClient extends WrapperClient with RequestConverterMixin {
  RequestConverterClient(
    super.client,
    this.converters,
  );

  final Iterable<RequestConverterCallback> converters;

  @override
  Iterable<RequestConverterCallback> get requestConverters => converters;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final modifiedRequest = await onConvertRequest(request);
    return inner.send(modifiedRequest);
  }
}
