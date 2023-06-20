import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:handle/handle.dart';
import 'package:shelf/shelf.dart' show Response;

import '../../test/test_server.dart';
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

String _getFakeResponseBodySingle() {
  return json.encode({
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
  });
}

String _getFakeResponseBodyList() {
  return json.encode([
    for (var i = 0; i < 10000; i++)
      {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false},
  ]);
}

Future<void> responseDelay() => Future.delayed(Duration(milliseconds: 50));

Future<TestServer> _createFakeServer() {
  return startTestHttpServer((app) {
    app.get('/single', (_) async {
      await responseDelay();
      return Response.ok(_getFakeResponseBodySingle());
    });
    app.get('/list', (_) async {
      await responseDelay();
      return Response.ok(_getFakeResponseBodyList());
    });
  });
}

void _useData(List<TodoModel> models) {
  models.length;
}

class RestClientListAsyncSerializationBenchmark extends AsyncBenchmark {
  RestClientListAsyncSerializationBenchmark()
      : super('RestClientListAsyncSerializationBenchmark');
  late RestClient handleClient;
  late TestServer _server;

  @override
  Future<void> setup() async {
    _server = await _createFakeServer();
    final client = RequestClient(http.Client(), url: _server.uri);

    handleClient = RestClient(
      client,
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await handleClient.get(Uri(path: '/list'));
    final data = (await response.deserializeBodyAsync<List<TodoModel>>())!;
    _useData(data);
  }

  @override
  Future<void> teardown() async {
    handleClient.close();
    _server.server.close();
  }
}

class RestClientListSerializationBenchmark extends AsyncBenchmark {
  RestClientListSerializationBenchmark()
      : super('RestClientListSerializationBenchmark');
  late RestClient handleClient;
  late TestServer _server;

  @override
  Future<void> setup() async {
    _server = await _createFakeServer();
    final client = RequestClient(http.Client(), url: _server.uri);

    handleClient = RestClient(
      client,
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await handleClient.get(Uri(path: '/list'));
    final data = response.deserializeBody<List<TodoModel>>()!;
    _useData(data);
  }

  @override
  Future<void> teardown() async {
    handleClient.close();
    _server.server.close();
  }
}

class HttpClientListSerializationBenchmark extends AsyncBenchmark {
  HttpClientListSerializationBenchmark()
      : super('HttpClientListSerializationBenchmark');

  late http.Client client;
  late TestServer _server;

  @override
  Future<void> setup() async {
    _server = await _createFakeServer();
    client = http.Client();
  }

  @override
  Future<void> run() async {
    final response = await client.get(_server.uri.replace(
      path: '/list',
    ));
    final jsonBody = json.decode(response.body);
    final data =
        (jsonBody as Iterable).map((json) => TodoModel.fromJson(json)).toList();
    _useData(data);
  }

  @override
  Future<void> teardown() async {
    client.close();
    _server.server.close();
  }
}

class RestClientSingleAsyncSerializationBenchmark extends AsyncBenchmark {
  RestClientSingleAsyncSerializationBenchmark()
      : super('RestClientSingleAsyncSerializationBenchmark');
  late RestClient handleClient;
  late TestServer _server;

  @override
  Future<void> setup() async {
    _server = await _createFakeServer();
    final client = RequestClient(http.Client(), url: _server.uri);

    handleClient = RestClient(
      client,
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await handleClient.get(Uri(path: '/single'));
    final data = (await response.deserializeBodyAsync<TodoModel>())!;
    _useData([data]);
  }

  @override
  Future<void> teardown() async {
    handleClient.close();
    _server.server.close();
  }
}

class RestClientSingleSerializationBenchmark extends AsyncBenchmark {
  RestClientSingleSerializationBenchmark()
      : super('RestClientSingleSerializationBenchmark');
  late RestClient handleClient;
  late TestServer _server;

  @override
  Future<void> setup() async {
    _server = await _createFakeServer();
    final client = RequestClient(http.Client(), url: _server.uri);

    handleClient = RestClient(
      client,
      serializer: JsonModelSerializer(deserializers: {
        JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
      }),
    );
  }

  @override
  Future<void> run() async {
    final response = await handleClient.get(Uri(path: '/single'));
    final data = response.deserializeBody<TodoModel>()!;
    _useData([data]);
  }

  @override
  Future<void> teardown() async {
    handleClient.close();
    _server.server.close();
  }
}

class HttpClientSingleSerializationBenchmark extends AsyncBenchmark {
  HttpClientSingleSerializationBenchmark()
      : super('HttpClientSingleSerializationBenchmark');

  late http.Client client;
  late TestServer _server;

  @override
  Future<void> setup() async {
    _server = await _createFakeServer();
    client = http.Client();
  }

  @override
  Future<void> run() async {
    final response = await client.get(_server.uri.replace(
      path: '/single',
    ));
    final jsonBody = json.decode(response.body);
    final data = TodoModel.fromJson(jsonBody);
    _useData([data]);
  }

  @override
  Future<void> teardown() async {
    client.close();
    _server.server.close();
  }
}
