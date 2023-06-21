import 'package:handle/handle.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import '../request.fake.dart';

void main() {
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
