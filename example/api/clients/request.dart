import 'package:handle/handle.dart';
import 'package:http/http.dart';

import '../todo.dart';

void main() async {
  // You can add deserializers to the common JsonModelSerializer so that every
  // rest response can use it.
  JsonModelSerializer.common.addDeserializers({
    JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
  });

  final jsonPlaceholderClient = RequestClient(
    Client(),
    url: Uri.https('jsonplaceholder.typicode.com'),
  );

  final todos = await jsonPlaceholderClient
      .get(Uri(path: '/todos'))
      .dataAsync<List<TodoModel>>();

  for (final todo in todos!) {
    print(todo);
  }

  // Close client after usage to clean up resources
  jsonPlaceholderClient.close();
}
