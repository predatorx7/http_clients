import 'package:handle/handle.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class DisposeTestClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  bool isClosed = false;

  @override
  void close() {
    isClosed = true;
  }
}

class TestWrapperClient extends WrapperClient {
  TestWrapperClient(super.client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  bool isClosed = false;

  @override
  void close({
    bool force = true,
    http.Client? keepAliveHttpClient,
  }) {
    isClosed = true;
    return super.close(force: force, keepAliveHttpClient: keepAliveHttpClient);
  }
}

void main() {
  test('HttpServiceException', () {
    expect(
      HttpServiceException('Some Exception').toString(),
      equals('HttpServiceException: Some Exception'),
    );
  });
  group('HttpService', () {
    test('invalid creation', () {
      final service = HttpService<RequestClient>(
        http.Client(),
      );

      expect(() => service.client, throwsA(isA<HttpServiceException>()));
    });

    test('dispose with wrapper client', () {
      final testClient = DisposeTestClient();
      late TestWrapperClient testWrapperClient;

      final service = HttpService<TestWrapperClient>(
        testClient,
        builder: (http.Client client) {
          testWrapperClient = TestWrapperClient(client);
          return testWrapperClient;
        },
      );

      service.dispose(keepHttpClientAlive: true);
      expect(testClient.isClosed, isFalse);
      expect(testWrapperClient.isClosed, isTrue);

      service.dispose(keepHttpClientAlive: false);
      expect(testClient.isClosed, isTrue);
      expect(testWrapperClient.isClosed, isTrue);
    });

    test('dispose with base client', () {
      final testClient = DisposeTestClient();

      final service = HttpService<DisposeTestClient>(
        http.Client(),
        builder: (http.Client client) {
          return testClient;
        },
      );

      service.dispose(keepHttpClientAlive: true);
      expect(testClient.isClosed, isTrue);

      service.dispose(keepHttpClientAlive: false);
      expect(testClient.isClosed, isTrue);
    });
  });
}
