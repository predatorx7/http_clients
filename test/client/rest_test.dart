import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../rest.mocks.dart';
import '../service/todo.dart';

void main() {
  group('RestClient', () {
    test('deserialized data from request', () async {
      final client = MockClient();

      final service = TodoService(client);

      when(
        client.send(any),
      ).thenAnswer(
        (_) async {
          return http.StreamedResponse(
            Stream.value(utf8.encode(
                '{ "userId": 3, "id": 1, "title": "sit reprehenderit omnis quia", "completed": false }')),
            200,
          );
        },
      );

      expect(service.getTodoById(1), completes);

      when(
        client.send(any),
      ).thenAnswer(
        (_) async {
          return http.StreamedResponse(
            Stream.value(
              utf8.encode(
                '''[
            {
              "userId": 3,
              "id": 48,
              "title": "sit reprehenderit omnis quia",
              "completed": false
            },
            {
              "userId": 3,
              "id": 49,
              "title": "ut necessitatibus aut maiores debitis officia blanditiis velit et",
              "completed": false
            }
          ]''',
              ),
            ),
            200,
          );
        },
      );

      expect(service.getTodos(), completes);

      when(
        client.send(any),
      ).thenAnswer(
        (_) async {
          throw http.ClientException('test');
        },
      );

      expectLater(service.getTodoById(1), throwsA(isA<http.ClientException>()));
    });
  });
}
