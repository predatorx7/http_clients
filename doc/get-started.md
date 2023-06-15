# Get Started

## Install

Follow the
[package installation instructions](https://pub.dev/packages/handle/install)

### Install from git

Add to your dependencies in `pubspec.yaml`

```yaml
handle:
  git: 
    url: https://github.com/predatorx7/handle.git
```

## Usage

Add handle package to your app and create your client to make an API request.

```dart
import 'package:handle/handle.dart';

// You can add deserializers to the common JsonModelSerializer so that every
// rest response can use it.
JsonModelSerializer.common.addDeserializers({
  JsonDeserializerOf<TodoModel>((json) => TodoModel.fromJson(json)),
});

final jsonPlaceholderClient = RequestClient(
  Client(),
  url: Uri.https('jsonplaceholder.typicode.com'),
);

final todos = await jsonPlaceholderClient.get(Uri(path: '/todos')).dataAsync<List<TodoModel>>();

for (final todo in todos!) {
  print(todo);
}
```

Alternatively, you can create a REST service too.

```dart
import 'package:handle/handle.dart';

class JsonplaceholderService extends RestService {
  JsonplaceholderService()
      : super(RequestClient(
          Client(),
          url: Uri.https('jsonplaceholder.typicode.com'),
        ));

  Future<List<TodoModel>?> getTodos() {
    return client.get(Uri(path: '/todos')).dataAsync<List<TodoModel>>();
  }
}

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
```

For a complete sample, see the [Rest Service & Request Client sample][] in the example directory.
For more on how to configure clients in `handle`, see [Configuration].

[Rest Service & Request Client sample]: https://github.com/predatorx7/handle/tree/main/example/api
[Configuration]: https://pub.dev/documentation/handle/latest/topics/Configuration-topic.html
