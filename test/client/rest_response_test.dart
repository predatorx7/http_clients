import 'dart:convert';

import 'package:handle/handle.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../service/todo.dart';

class _TestException {
  const _TestException();
}

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
    });
    test('deserialization on registered deserializer', () async {
      final model = TodoModel(1, 1, 'sample', true);
      final modelJsonString = json.encode(model);
      final response = RestResponse.fromResponse(
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
    test('deserialization errors', () async {
      final model = TodoModel(1, 1, 'sample', true);
      final modelJsonString = json.encode(model);
      final response = RestResponse.fromResponse(
        http.Response(modelJsonString, 200),
        JsonModelSerializer(deserializers: {
          JsonDeserializerOf<TodoModel>((json) {
            throw _TestException();
          }),
        }),
      );
      expect(
        () => response.deserializeBody<TodoModel>(),
        throwsA(
          isA<RestResponseException>(),
        ),
      );
      expectLater(
        response.deserializeBodyAsync<TodoModel>(),
        throwsA(isA<RestResponseException>()),
      );
    });
  });
}
