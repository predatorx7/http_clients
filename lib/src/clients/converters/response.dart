import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../../utils/unawaited_response.dart';
import '../wrapper.dart';
import 'exception.dart';

typedef ResponseConverterCallback = FutureOr<StreamedResponse> Function(
  StreamedResponse,
);

class ResponseConverterException extends ConverterException {
  const ResponseConverterException(
    super.message, {
    super.uri,
    super.innerException,
    super.innerStackTrace,
  });
}

mixin ResponseConverterMixin {
  @protected
  Iterable<ResponseConverterCallback>? get responseConverters;

  @protected
  FutureOr<StreamedResponse> onConvertResponse(
    StreamedResponse response,
  ) async {
    final responseConverters = this.responseConverters;
    if (responseConverters == null || responseConverters.isEmpty) {
      return response;
    }

    StreamedResponse modifiedResponse = response;

    for (final converter in responseConverters) {
      try {
        modifiedResponse = await converter(modifiedResponse);
      } catch (e, s) {
        unawaitedResponse(response);
        throw ResponseConverterException(
          'Response Converter failed due to an error',
          uri: response.request?.url,
          innerException: e,
          innerStackTrace: s,
        );
      }
    }

    if (response != modifiedResponse) {
      unawaitedResponse(response);
    }

    return modifiedResponse;
  }
}

/// {@category Clients}
class ResponseConverterClient extends WrapperClient
    with ResponseConverterMixin {
  ResponseConverterClient(
    super.client,
    this.converters,
  );

  final Iterable<ResponseConverterCallback> converters;

  @override
  Iterable<ResponseConverterCallback> get responseConverters => converters;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await inner.send(request);
    final modifiedResponse = await onConvertResponse(response);
    return modifiedResponse;
  }
}
