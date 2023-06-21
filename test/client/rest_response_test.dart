import 'dart:convert';

import 'package:handle/handle.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../service/todo.dart';

void main() {
  group('RestResponse', () {
    test('deserialization on unknown type parameters', () async {
      final model = TodoModel(1, 1, 'sample', true);
      final modelJsonString = json.encode(model);
      RestResponse response = RestResponse.fromResponse(
        http.Response(modelJsonString, 200),
      );
      expect(
        () => response.deserializeBody(),
        throwsA(
          isA<http.ClientException>(),
        ),
      );
      expectLater(
        response.deserializeBodyAsync(),
        throwsA(isA<http.ClientException>()),
      );
      expect(
        () => response.deserializeBody<TodoModel>(),
        throwsA(
          isA<http.ClientException>(),
        ),
      );
      expectLater(
        response.deserializeBodyAsync<TodoModel>(),
        throwsA(isA<http.ClientException>()),
      );
      response = RestResponse.fromResponse(
        http.Response(modelJsonString, 200),
        JsonModelSerializer(deserializers: {
          JsonDeserializerOf<TodoModel>(TodoModel.fromJson),
        }),
      );
      expect(
        response.deserializeBody<TodoModel>(),
        isA<TodoModel>(),
      );
      expectLater(
        response.deserializeBodyAsync<TodoModel>(),
        completion(isA<TodoModel>()),
      );
    });
  });
}
