import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:handle/handle.dart';
import 'package:mockito/mockito.dart';

import '../../test/rest.mocks.dart';
import '../benchmark.dart';

class TodoModel {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  const TodoModel(this.userId, this.id, this.title, this.completed);

  factory TodoModel.fromJson(dynamic json) {
    return TodoModel(
      json['userId'],
      json['id'],
      json['title'],
      json['completed'],
    );
  }

  @override
  String toString() {
    final String status = completed ? 'completed' : 'pending';
    return 'Todo #$id "$title" is $status by user#$userId';
  }
}

void main() async {
  _loadFakeResponseBody();

  final runner = BenchmarkRunner(
    asyncBenchmarks: [
      HttpClientListSerializationBenchmark(),
      RestClientListSerializationBenchmark(),
      RestClientListAsyncSerializationBenchmark(),
      HttpClientSingleSerializationBenchmark(),
      RestClientSingleSerializationBenchmark(),
      RestClientSingleAsyncSerializationBenchmark(),
    ],
  );

  await runner.run();
}

late String _fakeResponseBodySingle;
late String _fakeResponseBodyList;
void _loadFakeResponseBody() {
  _fakeResponseBodySingle = json.encode({
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
  });
  _fakeResponseBodyList = json.encode([
    for (var i = 0; i < 10000; i++)
      {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false},
  ]);
}

String _getFakeResponseBodySingle() {
  return _fakeResponseBodySingle;
}

String _getFakeResponseBodyList() {
  return _fakeResponseBodyList;
}

Future<http.StreamedResponse> _createFakeSingleResponse() async {
  await Future.delayed(Duration(milliseconds: 10));
  return http.StreamedResponse(
    Stream.value(utf8.encode(_getFakeResponseBodySingle())),
    200,
  );
}

Future<http.StreamedResponse> _createFakeListResponse() async {
  await Future.delayed(Duration(milliseconds: 500));
  return http.StreamedResponse(
    Stream.value(utf8.encode(_getFakeResponseBodyList())),
    200,
  );
}

void _useData(List<TodoModel> models) {
  models.length;
}

class RestClientListAsyncSerializationBenchmark extends AsyncBenchmark {
  RestClientListAsyncSerializationBenchmark()
      : super('RestClientListAsyncSerializationBenchmark');
  late RestClient service;

  @override
  Future<void> setup() async {
    final client = MockClient();

    when(
      client.send(any),
    ).thenAnswer(
      (_) {
        return _createFakeListResponse();
      },
    );

    service = RestClient(
      RequestClient(
        client,
      ),
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await service.get(Uri());
    final data = (await response.deserializeBodyAsync<List<TodoModel>>())!;
    _useData(data);
  }

  @override
  Future<void> teardown() async {}
}

class RestClientListSerializationBenchmark extends AsyncBenchmark {
  RestClientListSerializationBenchmark()
      : super('RestClientListSerializationBenchmark');
  late RestClient service;

  @override
  Future<void> setup() async {
    final client = MockClient();

    when(
      client.send(any),
    ).thenAnswer((_) {
      return _createFakeListResponse();
    });

    service = RestClient(
      RequestClient(
        client,
      ),
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await service.get(Uri());
    final data = response.deserializeBody<List<TodoModel>>()!;
    _useData(data);
  }

  @override
  Future<void> teardown() async {}
}

class HttpClientListSerializationBenchmark extends AsyncBenchmark {
  HttpClientListSerializationBenchmark()
      : super('HttpClientListSerializationBenchmark');

  late MockClient client;
  @override
  Future<void> setup() async {
    client = MockClient();

    when(
      client.get(any),
    ).thenAnswer(
      (_) async {
        return http.Response.fromStream(await _createFakeListResponse());
      },
    );
  }

  @override
  Future<void> run() async {
    final response = await client.get(Uri());
    final jsonBody = json.decode(response.body);
    final data =
        (jsonBody as Iterable).map((json) => TodoModel.fromJson(json)).toList();
    _useData(data);
  }

  @override
  Future<void> teardown() async {}
}

class RestClientSingleAsyncSerializationBenchmark extends AsyncBenchmark {
  RestClientSingleAsyncSerializationBenchmark()
      : super('RestClientSingleAsyncSerializationBenchmark');
  late RestClient service;

  @override
  Future<void> setup() async {
    final client = MockClient();

    when(
      client.send(any),
    ).thenAnswer(
      (_) {
        return _createFakeSingleResponse();
      },
    );

    service = RestClient(
      RequestClient(
        client,
      ),
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await service.get(Uri());
    final data = (await response.deserializeBodyAsync<TodoModel>())!;
    _useData([data]);
  }

  @override
  Future<void> teardown() async {}
}

class RestClientSingleSerializationBenchmark extends AsyncBenchmark {
  RestClientSingleSerializationBenchmark()
      : super('RestClientSingleSerializationBenchmark');
  late RestClient service;

  @override
  Future<void> setup() async {
    final client = MockClient();

    when(
      client.send(any),
    ).thenAnswer((_) {
      return _createFakeSingleResponse();
    });

    service = RestClient(
      RequestClient(
        client,
      ),
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await service.get(Uri());
    final data = response.deserializeBody<TodoModel>()!;
    _useData([data]);
  }

  @override
  Future<void> teardown() async {}
}

class HttpClientSingleSerializationBenchmark extends AsyncBenchmark {
  HttpClientSingleSerializationBenchmark()
      : super('HttpClientSingleSerializationBenchmark');

  late MockClient client;
  @override
  Future<void> setup() async {
    client = MockClient();

    when(
      client.get(any),
    ).thenAnswer(
      (_) async {
        return http.Response.fromStream(await _createFakeSingleResponse());
      },
    );
  }

  @override
  Future<void> run() async {
    final response = await client.get(Uri());
    final jsonBody = json.decode(response.body);
    final data = TodoModel.fromJson(jsonBody);
    _useData([data]);
  }

  @override
  Future<void> teardown() async {}
}
