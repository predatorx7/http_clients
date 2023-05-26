import 'package:handle/handle.dart';
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

class TodoService extends RestService {
  TodoService([http.Client? client])
      : super(
          RequestClient(
            client ?? http.Client(),
            url: Uri.https('jsonplaceholder.typicode.com', '/todos'),
          ),
          serializer: JsonModelSerializer(deserializers: {
            JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
          }),
        );

  Future<TodoModel?> getTodoById(int id) async {
    return client.get(Uri(path: '/$id')).dataAsync();
  }

  Future<List<TodoModel>?> getTodos() async {
    return client.get(Uri()).dataAsync();
  }
}
