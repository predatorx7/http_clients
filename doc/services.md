# Services

## Available Service classes

- **HttpService** helps you reduce boilerplate when using http client to make http services. 
- **RestService** helps you reduce boilerplate for writing service classes for rest http clients.

### RestService

Create service using RestService.

```dart
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
```

More detailed example: [Request Client Example](https://github.com/predatorx7/handle/blob/main/example/api/services/rest.dart)
