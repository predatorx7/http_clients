import 'package:http/http.dart';

class InterceptorException implements ClientException {
  @override
  final String message;
  @override
  final Uri? uri;
  final Object? innerException;
  final StackTrace? innerStackTrace;

  const InterceptorException(
    this.message, {
    this.uri,
    this.innerException,
    this.innerStackTrace,
  });
}
