import 'package:handle/handle.dart';
import 'package:http/http.dart';

import '../todo.dart';

class JsonplaceholderService extends RestService {
  JsonplaceholderService()
      : super(
          RequestClient(
            Client(),
            url: Uri.https('jsonplaceholder.typicode.com'),
          ),
          // Pass a serializer here if you want it to be used only within this
          // TodoService. If not null, this service will create a new serializer
          // from this and [JsonModelSerializer.common].
          serializer: null,
        );

  Future<List<TodoModel>?> getTodos() {
    return client.get(Uri(path: '/todos')).dataAsync<List<TodoModel>>();
  }
}

void main() async {
  // You can add deserializers to the common JsonModelSerializer so that every
  // rest response can use it.
  JsonModelSerializer.common.addDeserializers({
    JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
  });

  final service = JsonplaceholderService();

  final todos = await service.getTodos();

  for (final todo in todos!) {
    print(todo);
  }

  // Dispose the service after usage to clean up resources
  service.dispose();
}
