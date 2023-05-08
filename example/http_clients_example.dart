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

final jsonPlaceholderClient = ClientWith(
  http.Client(),
  url: Uri.https('jsonplaceholder.typicode.com'),
);

class TodoService {
  final _client = RestClient(
    ClientWith(
      jsonPlaceholderClient,
      url: Uri(path: '/todos'),
    ),
    serializers: JsonModelSerializer({
      TodoModel: TodoModel.fromJson,
    }),
  );

  Future<TodoModel> getTodoById(int id) async {
    // https://jsonplaceholder.typicode.com/todos/:id
    final response = await _client.get(Uri(path: '/$id'));
    return (await response.deserializeBodyAsync<TodoModel>())!;
  }

  void dispose() => _client.close();
}

void main() async {
  final service = TodoService();

  final ids = List.generate(10, (index) => index + 1);

  final futures = <Future>[];
  for (final id in ids) {
    futures.add(service.getTodoById(id).then((data) {
      print(data);
    }));
  }

  await Future.wait(futures);

  service.dispose();
}
