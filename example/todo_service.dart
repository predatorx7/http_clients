import 'package:http/http.dart' as http;
import 'package:http_clients/http_clients.dart';

final http.Client jsonPlaceholderClient = RequestClient(
  http.Client(),
  url: Uri.https('jsonplaceholder.typicode.com'),
);

void addAllDeserializers() {
  JsonModelSerializer.common.addAllDeserializers({
    TodoModel: (json) => TodoModel.fromJson(json),
  });
}

class TodoService {
  TodoService(http.Client client)
      : _client = RequestClient(
          client,
          url: Uri(path: '/todos'),
        );

  final http.Client _client;

  Future<TodoModel?> getTodo(int id) {
    return _client.get(Uri(path: '/$id')).dataAsync();
  }

  Future<TodoModel?> getTodos() {
    return _client.get(Uri()).dataAsync();
  }
}

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
