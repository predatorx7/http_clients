import 'package:http_client_conformance_tests/http_client_conformance_tests.dart';
import 'package:http_clients/src/clients/clients.dart';
import 'package:http/http.dart' as http;

T _returnSame<T>(T object) => object;

void main() {
  testAll(() => RestClient(http.Client()));
  testAll(() => RequestClient(http.Client()));
  testAll(
    () => InterceptorClient(
      http.Client(),
      requestInterceptors: [_returnSame],
      responseInterceptors: [_returnSame],
    ),
  );
  testAll(() => RequestInterceptorClient(http.Client(), [_returnSame]));
  testAll(() => ResponseInterceptorClient(http.Client(), [_returnSame]));
  testAll(
    () => ConverterClient(
      http.Client(),
      requestConverters: [_returnSame],
      responseConverters: [_returnSame],
    ),
  );
  testAll(() => RequestConverterClient(http.Client(), [_returnSame]));
  testAll(() => ResponseConverterClient(http.Client(), [_returnSame]));
}
