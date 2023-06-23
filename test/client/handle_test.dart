import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:handle/handle.dart';
import 'package:test/test.dart';

void main() {
  group('HandleClient', () {
    test('retry on client exception and response errors', () async {
      const token = 'jnasjds';
      const body = 'HELLO WORLD';
      String? latestRequestBody;

      int retriedCount = 0;

      final testClient = http_testing.MockClient((request) async {
        retriedCount++;
        if (!request.headers.containsKey('authorization')) {
          throw http.ClientException('Fake error');
        }
        if (request.headers['authorization'] != token) {
          return http.Response('', 401);
        }

        latestRequestBody = request.body;

        return http.Response('ok', 200);
      });

      final client = Handle.client(
        testClient,
        when: (response, count) {
          return response.statusCode == 401;
        },
        whenError: (e, s, count) => true,
        updateRequest: (original, last, bodyStream, response, count) {
          final request = last.createCopy(bodyStream());

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
        client
            .send(http.Request('GET', Uri())..body = body)
            .then((value) => http.Response.fromStream(value))
            .then((value) => value.statusCode),
        completion(equals(200)),
      );

      expect(retriedCount, equals(3));

      expect(latestRequestBody, body);
    });

    test('stop on HandleException without retries', () async {
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

    test('throws HandleRetryLimitExceededException when retried to many times',
        () async {
      final testClient = http_testing.MockClient((request) async {
        return http.Response(request.method, 500);
      });

      final client = Handle.client(
        testClient,
        when: (response, retries) => true,
      );

      await expectLater(
        client.send(http.Request('GET', Uri())),
        throwsA(isA<HandleRetryLimitExceededException>()),
      );
    });
  });
}
