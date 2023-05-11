# HTTP Clients

<p align="center">
<a href="https://pub.dev/packages/http_clients"><img src="https://img.shields.io/pub/v/http_clients.svg" alt="Pub"></a>
<a href="https://github.com/predatorx7/http_clients/actions/workflows/http_clients.yaml"><img src="https://github.com/predatorx7/http_clients/actions/workflows/http_clients.yaml/badge.svg" alt="http_clients"></a>
<a href="https://codecov.io/gh/predatorx7/http_clients" >
<img src="https://codecov.io/gh/predatorx7/http_clients/branch/main/graph/badge.svg?token=FIQIP0GYHK"/>
</a>
</p>

A composable, Future-based library for making HTTP requests.

This package makes it easier to create HTTP clients. It does this by providing a set of composable classes that can be used to build clients that extends [Client] from [package:http](https://pub.dev/packages/http).

Here are some of the benefits of using this package:

- **No code generation:** You don't have to write any code to create a client. This makes it much faster and easier to get started.
- **Composable:** The classes in this package are composable, which means you can combine them to create complex clients. This gives you a lot of flexibility in how you build your clients.
- **Easy to use:** The classes in this package are easy to use. They have simple APIs that are easy to understand.

This makes it a great alternative to other client generators like Chopper and Retrofit. If you're looking for a way to make it easier to create HTTP clients in Flutter, then this package is a great option. It's fast, easy to use, available on multiple-platforms and gives you a lot of flexibility.

## Available Http Clients

- A **RestClient** that de/serializes models on request and response.
- A **RequestClient** that lets you modify request url and headers.
- **InterceptorClient**, **RequestInterceptorClient**, and **ResponseInterceptorClient** where the interceptors are called on request, and response.
- **ConverterClient**, **RequestConverterClient**, and **ResponseConverterClient** where the converters are called before request, and after response to modify them.

## Install

Add to your app or package

### Install with git

Add to your dependencies in `pubspec.yaml`
```yaml
  http_clients:
    git: 
      url: https://github.com/predatorx7/http_clients.git
```

## Use

### RequestClient

A client that can be used to update url and headers of a request body.

```dart
final client = RequestClient(
  client,
  url: Uri.https('api.example.com'),
  headers: {
    'Authorization': 'Bearer xyzsome_sample_tokenabc'
  },
);

final httpResponse = service.get(Uri(path: '/sample'))
```

### RestClient

- Any request returns a [RestResponse] which has a `deserialize<T>()` & `deserializeAsync<T>()` for getting json string data from the request as a class.
- Deserializer for any type `T` must be added to the [JsonModelSerializer] in [RestClient]'s contructor or in [JsonModelSerializer.common].

Below is a simple use of this client. 
```dart
// Create a client with url and serializer
final service = RestClient(
  RequestClient(
    client,
    url: Uri.https('api.example.com'),
  ),
  serializer: JsonModelSerializer(deserializers: {
    TodoModel: (json) => TodoModel.fromJson(json),
  })
  // Calling the below ethod will add a List<TodoModel> deserializer
  // if TodoModel already has a deserializer
  ..addJsonListDeserializerOf<TodoModel>(),
);

// Make an API call
final response = await service.get(Uri(path: '/todos'));

// Deserialize body as json to a model class.
final List<TodoModel>? data = await response.deserializeBodyAsync<List<TodoModel>>();
```

## Additional information

- One good way to use this package is to create service using RestClient, RequestClient, etc

```dart

class TodoService {
  TodoService([http.Client? client])
      : _client = RestClient(
          RequestClient(
            client ?? http.Client(),
            url: Uri.https('jsonplaceholder.typicode.com', '/todos'),
          ),
          serializer: JsonModelSerializer(deserializers: {
            TodoModel: (json) => TodoModel.fromJson(json),
          })
            ..addJsonListDeserializerOf<TodoModel>(),
        );

  final RestClient _client;

  Future<TodoModel> getTodoById(int id) async {
    final response = await _client.get(Uri(path: '/$id'));
    return (await response.deserializeBodyAsync<TodoModel>())!;
  }

  Future<List<TodoModel>> getTodos() async {
    final response = await _client.get(Uri());
    return (await response.deserializeBodyAsync<List<TodoModel>>())!;
  }

  void dispose() => _client.close();
}
```

- For comparing client performance from this package, I've included benchmarks for these clients, and Client() from the http package with no external dependency in `benchmarks/` directory.

### Latest benchmark results

```
HttpClientListSerializationBenchmark(RunTime): 11139330.0 us.
RestClientListSerializationBenchmark(RunTime): 11221641.0 us.
RestClientListAsyncSerializationBenchmark(RunTime): 11289030.0 us.
HttpClientSingleSerializationBenchmark(RunTime): 316030.85714285716 us.
RestClientSingleSerializationBenchmark(RunTime): 317782.0 us.
RestClientSingleAsyncSerializationBenchmark(RunTime): 329862.4285714286 us.
```