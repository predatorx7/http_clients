import 'package:handle/handle.dart';
import 'package:http/http.dart';

import '../todo.dart';

void main() async {
  // You can add deserializers to the common JsonModelSerializer so that every
  // rest response can use it.
  JsonModelSerializer.common.addDeserializers({
    JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
  });

  Object? interceptedException;

  final jsonPlaceholderClient = InterceptorClient(
    RequestClient(
      Client(),
      url: Uri.https('someinvalidurl.example.org'),
    ),
    clientExceptionInterceptors: [
      (request, error, stackTrace) {
        // getting intercepted error.
        interceptedException = error;
      }
    ],
  );

  try {
    final todos = await jsonPlaceholderClient
        .get(Uri(path: '/todos'))
        .dataAsync<List<TodoModel>>();

    for (final todo in todos!) {
      print(todo);
    }
  } catch (_) {
    print('! some error did happen. (This was already intercepted in this example).');
  } finally {
    print('* Intercepted exception: $interceptedException');

    // Close client after usage to clean up resources
    jsonPlaceholderClient.close();
  }
}
