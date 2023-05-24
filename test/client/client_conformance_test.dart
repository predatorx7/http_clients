import 'package:http_client_conformance_tests/http_client_conformance_tests.dart';
import 'package:handle/src/clients/clients.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

T _returnSame<T>(T object) => object;

void main() {
  group('RestClient', () {
    testAll(() => RestClient(http.Client()));
  });
  group('RequestClient', () {
    testAll(() => RequestClient(http.Client()));
  });
  group('InterceptorClient', () {
    testAll(
      () => InterceptorClient(
        http.Client(),
        requestInterceptors: [_returnSame],
        responseInterceptors: [_returnSame],
      ),
    );
  });
  group('RequestInterceptorClient', () {
    testAll(() => RequestInterceptorClient(http.Client(), [_returnSame]));
  });
  group('ResponseInterceptorClient', () {
    testAll(() => ResponseInterceptorClient(http.Client(), [_returnSame]));
  });
  group('ConverterClient', () {
    testAll(() {
      return ConverterClient(
        http.Client(),
        requestConverters: [_returnSame],
        responseConverters: [_returnSame],
      );
    });
  });
  group('RequestConverterClient', () {
    testAll(() => RequestConverterClient(http.Client(), [_returnSame]));
  });
  group('ResponseConverterClient', () {
    testAll(() => ResponseConverterClient(http.Client(), [_returnSame]));
  });
}
