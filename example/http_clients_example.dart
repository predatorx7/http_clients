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

  @override
  String toString() {
    final String status = completed ? 'completed' : 'pending';
    return 'Todo #$id "$title" is $status by user#$userId';
  }
}

class JsonPlaceholderService {
  final _client = RestClient(
    ClientWith(
      http.Client(),
      url: Uri.https('jsonplaceholder.typicode.com'),
    ),
    serializers: JsonModelSerializer({
      TodoModel: TodoModel.fromJson,
    }),
  );

  Future<TodoModel> getTodoById(int id) async {
    final response = await _client.get(Uri(path: '/todos/$id'));
    return (await response.deserializeBodyAsync<TodoModel>())!;
  }
}

void main() async {
  final service = JsonPlaceholderService();

  final ids = List.generate(10, (index) => index + 1);

  for (final id in ids) {
    service.getTodoById(id).then((data) {
      print(data);
    });
  }
}
