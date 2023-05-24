import 'package:http/http.dart' as http;
import 'package:handle/handle.dart';

final http.Client jsonPlaceholderClient = RequestClient(
  http.Client(),
  url: Uri.https('jsonplaceholder.typicode.com'),
);

void addAllDeserializers() {
  JsonModelSerializer.common.addDeserializers({
    JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
  });
}

class TodoService extends RestService {
  TodoService(http.Client client)
      : super(client, builder: (client) {
          return RequestClient(
            client,
            url: Uri(path: '/todos'),
          );
        });

  Future<TodoModel?> getTodo(int id) {
    return client.get(Uri(path: '$id')).dataAsync();
  }

  Future<List<TodoModel>?> getTodos() {
    return client.get(Uri()).dataAsync();
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

void main() async {
  addAllDeserializers();

  final service = TodoService(jsonPlaceholderClient);

  final ids = List.generate(10, (index) => index + 1);

  final futures = <Future>[];
  for (final id in ids) {
    futures.add(service.getTodo(id).then((data) {
      print(data);
    }));
  }

  futures.add(service.getTodos().then((data) {
    print(data);
  }));

  await Future.wait(futures);

  service.dispose();
}
