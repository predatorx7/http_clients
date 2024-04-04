import 'package:http/http.dart' as http;
import 'package:handle/handle.dart';

final http.Client jsonPlaceholderClient = RequestClient(
  http.Client(),
  url: Uri.https('jsonplaceholder.typicode.com'),
);

void addAllDeserializers() {
  // You can add deserializers to the common JsonModelSerializer so that every
  // rest response can use it.
  JsonModelSerializer.common.addDeserializers({
    JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
  });
}

class TodoService extends RestService {
  TodoService(super.client)
      : super(
          builder: (client) {
            return RequestClient(
              client,
              // we don't have to write the full base url. Request client can
              // merge these with url and headers from the wrapper clients.
              url: Uri(path: '/todos'),
            );
          },
          // Pass a serializer here if you want it to be used only within this
          // TodoService. If not null, this service will create a new serializer
          // from this and [JsonModelSerializer.common].
          serializer: null,
        );

  Future<TodoModel?> getTodo(int id) {
    return client.get(Uri(path: '$id')).dataAsync();
  }

  Future<List<TodoModel>?> getTodos() {
    return client.get(Uri()).dataAsync();
  }
}

void main() async {
  // You must add deserializers before you get a deserialized response from the
  // RestClient.
  addAllDeserializers();

  // This is an example of service usage. You can use any other pattern that
  // fits your need.
  //
  // By giving it a client, we have atleast 2 advantages:
  //  1. This client can already have information about the base url, auth, etc.
  //  2. It can be reused by other services.
  final service = TodoService(jsonPlaceholderClient);

  // Below, we creating a list of futures where we are waiting to getTodo
  // for ids between 1-10.
  await Future.wait(<Future>[
    // Create 10 request to get todo for ids between 1-10 at the same time.
    for (final id in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
      service.getTodo(id).then(print),
  ]);

  // another request to get all todos in single request.
  // We'll print the response.
  await service.getTodos().then(print);

  // Don't forget to dispose the service after usage.
  // Set `keepHttpClientAlive` to true if the
  // underlying client, which was provided when creating TodoService, must not
  // be disposed
  service.dispose(keepHttpClientAlive: false);
}

// A simple json serializable class
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
