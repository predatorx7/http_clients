import 'package:http/http.dart' as http;
import 'package:http_clients/http_clients.dart';

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

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  @override
  String toString() {
    final String status = completed ? 'completed' : 'pending';
    return 'Todo #$id "$title" is $status by user#$userId';
  }
}

final jsonPlaceholderClient = RequestClient(
  http.Client(),
  url: Uri.https('jsonplaceholder.typicode.com'),
);

class TodoService {
  TodoService({this.createClient});

  final http.Client Function(http.Client)? createClient;

  late final _client = RestClient(
    RequestClient(
      createClient?.call(jsonPlaceholderClient) ?? jsonPlaceholderClient,
      url: Uri(path: '/todos'),
    ),
    serializer: JsonModelSerializer(deserializers: {
      TodoModel: (json) => TodoModel.fromJson(json),
    })
      ..addJsonListDeserializerOf<TodoModel>(),
  );

  Future<TodoModel> getTodoById(int id) async {
    // https://jsonplaceholder.typicode.com/todos/:id
    final response = await _client.get(Uri(path: '/$id'));
    return (await response.deserializeBodyAsync<TodoModel>())!;
  }

  Future<List<TodoModel>> getTodos() async {
    // https://jsonplaceholder.typicode.com/todos/:id
    final response = await _client.get(Uri());
    return (await response.deserializeBodyAsync<List<TodoModel>>())!;
  }

  Future<RestResponse> postTodo(TodoModel body) async {
    // https://jsonplaceholder.typicode.com/todos/:id
    return _client.post(Uri(), body: body);
  }

  Future<RestResponse> putTodo(TodoModel body) async {
    // https://jsonplaceholder.typicode.com/todos/:id
    return _client.put(Uri(path: '/${body.id}'), body: body);
  }

  Future<RestResponse> patchTodo(TodoModel body) async {
    // https://jsonplaceholder.typicode.com/todos/:id
    return _client.patch(Uri(path: '/${body.id}'), body: body);
  }

  Future<RestResponse> deleteTodo(int id) async {
    // https://jsonplaceholder.typicode.com/todos/:id
    return _client.delete(Uri(path: '/$id'));
  }

  void dispose() => _client.close();
}

Future<void> example1() async {
  final service = TodoService();

  final ids = List.generate(10, (index) => index + 1);

  final futures = <Future>[];
  for (final id in ids) {
    futures.add(service.getTodoById(id).then((data) {
      print(data);
    }));
  }

  futures.add(service.getTodos().then((data) {
    print(data);
  }));

  await Future.wait(futures);
}

Future<void> example2() async {
  final service = TodoService(
    createClient: (client) => ResponseInterceptorClient(client, [
      (response) {
        print({
          'statusCode': response.statusCode,
          'method': response.request?.method,
          'url': response.request?.url,
        });
      },
    ]),
  );

  final futures = <Future>[
    service.postTodo(TodoModel(2, 2, 'title', true)),
    service.putTodo(TodoModel(2, 2, 'title', true)),
    service.patchTodo(TodoModel(2, 2, 'title', true)),
    service.deleteTodo(2),
  ];

  await Future.wait(futures);
}

void main() async {
  await example1();
  await example2();
}
