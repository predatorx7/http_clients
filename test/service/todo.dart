import 'package:http_clients/http_clients.dart';
import 'package:http/http.dart' as http;

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

class TodoService {
  TodoService([http.Client? client])
      : _client = RestClient(
          RequestClient(
            client ?? http.Client(),
            url: Uri.https('jsonplaceholder.typicode.com', '/todos'),
          ),
          serializer: JsonModelSerializer(deserializers: {
            JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
          }),
        );

  final RestClient _client;

  Future<TodoModel> getTodoById(int id) async {
    final response = await _client.get(Uri(path: '/$id'));
    return (await response.deserializeBodyAsync<TodoModel>())!;
  }

  Future<List<TodoModel>> getTodos() async {
    final response = await _client.get(Uri());
    return (await response.deserializeBodyAsync<List<TodoModel>>())!;
  }

  void dispose() => _client.close();
}
