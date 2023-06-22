import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:handle/handle.dart';
import 'package:test/test.dart';

void main() {
  group('HandleClient', () {
    test('retry on client exception and response errors', () async {
      const token = 'jnasjds';

      int retriedCount = 0;

      final testClient = http_testing.MockClient((request) async {
        retriedCount++;
        if (!request.headers.containsKey('authorization')) {
          throw http.ClientException('Fake error');
        }
        if (request.headers['authorization'] != token) {
          return http.Response('', 401);
        }
        return http.Response('ok', 200);
      });

      final client = Handle.client(
        testClient,
        when: (response, count) {
          return response.statusCode == 403;
        },
        whenError: (e, s, count) => true,
        updateRequest: (original, last, response, count) {
          final request = last.createCopy();

          if (response == null) {
            return request..headers.addAll({'authorization': 'anything'});
          }

          if (response.statusCode == 401) {
            return request..headers.addAll({'authorization': token});
          }
          return last;
        },
      );

      await expectLater(
        client.send(http.Request('GET', Uri())),
        completion(isA<http.StreamedResponse>()),
      );

      expect(retriedCount, equals(2));
    });

    test('stop on handle exception without retries', () async {
      int retryCount = 0;

      final testClient = http_testing.MockClient((request) async {
        retryCount++;
        // an error that is not a client exception
        throw Exception('Fake error');
      });

      final client = Handle.client(
        testClient,
      );

      await expectLater(
        client.send(http.Request('GET', Uri())),
        throwsA(isA<HandleException>()),
      );

      expect(retryCount, equals(1));
    });
  });
}
