import 'package:http/http.dart';

class ConverterException implements ClientException {
  @override
  final String message;
  @override
  final Uri? uri;
  final Object? innerException;
  final StackTrace? innerStackTrace;

  const ConverterException(
    this.message, {
    this.uri,
    this.innerException,
    this.innerStackTrace,
  });
}
