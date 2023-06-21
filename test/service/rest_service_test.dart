import 'package:handle/handle.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import '../request.fake.dart';

class NoopHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }
}

class _A {
  factory _A.fromJson(Object? object) {
    throw UnimplementedError();
  }
}

class _B {
  factory _B.fromJson(Object? object) {
    throw UnimplementedError();
  }
}

void main() {
  group('RestServiceConfig', () {
    test('merges serializers', () {
      final config = RestServiceConfig(
        RestClient(
          NoopHttpClient(),
          serializer: JsonModelSerializer(
            deserializers: {
              JsonDeserializerOf<_A>(_A.fromJson),
            },
          ),
        ),
        null,
        JsonModelSerializer(
          deserializers: {
            JsonDeserializerOf<_B>(_B.fromJson),
          },
        ),
      );
      final builtClient = config.builder?.call(config.client);
      expect(builtClient?.serializer?.contains<_A>(), isTrue);
      expect(builtClient?.serializer?.contains<_B>(), isTrue);
    });
  });

  group('RestService', () {
    test('creation with builder', () async {
      http.BaseRequest? receivedRequest;
      final service = RestService(RequestTestClient((request) {
        receivedRequest = request;
      }), builder: (client) {
        return RequestClient(
          client,
          url: Uri.https('example.com'),
          headers: {'some-header': 'some-value'},
        );
      });

      await service.client.post(Uri(path: '/hello'), body: {
        'hello': 'world',
        'count': 1,
      });

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('some-value'));
      expect(receivedRequest?.url, equals(Uri.https('example.com', '/hello')));
    });
  });
}
