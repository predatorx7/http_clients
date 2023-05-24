# Handle HTTP Clients & Services

<p align="center">
<a href="https://pub.dev/packages/handle"><img src="https://img.shields.io/pub/v/handle.svg" alt="Pub"></a>
<a href="https://github.com/predatorx7/handle/actions/workflows/handle.yaml"><img src="https://github.com/predatorx7/handle/actions/workflows/handle.yaml/badge.svg" alt="handle"></a>
<a href="https://codecov.io/gh/predatorx7/handle" >
<img src="https://codecov.io/gh/predatorx7/handle/branch/main/graph/badge.svg?token=FIQIP0GYHK"/>
</a>
</p>

A simple library for composing HTTP clients, creating services to make HTTP requests. It's reliable, fast, easy to use, available on multiple-platforms and gives you a lot of flexibility.

- No code generation required, so you can get started quickly.
- Combine different clients to create the perfect HTTP client for your needs.
- Extensive test suite and benchmarks to ensure high performance.
- Every client extends dart's pub.dev/packages/http and this they're compatible with [Client] from package:http.

## Available HTTP Clients

- **RestClient**: A client for REST requests that de/serializes models on request and response.
- **RequestClient**: A client that lets you modify request url and headers.
- **InterceptorClient**: A client that allows you to add interceptors to requests and responses.
- **RequestInterceptorClient**, and **ResponseInterceptorClient** to individually intercept requests or responses.
- **ConverterClient**: A client that allows you to convert requests and responses before they are sent or received.
- **RequestConverterClient**, or **ResponseConverterClient** to individually modify requests or responses.

## Available Service classes

- **HttpService** helps you reduce boilerplate when using http client to make http services. 
- **RestService** helps you reduce boilerplate for writing service classes for rest http clients.

## Install

Add this package to your app or package

### Install with pub.dev

Run `dart pub add handle`

### Install with git

Add to your dependencies in `pubspec.yaml`
```yaml
  handle:
    git: 
      url: https://github.com/predatorx7/handle.git
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

final httpResponse = service.get(Uri(path: '/sample')).jsonBody;
```

Note: This could take more memory incase of big request body because it may create a copy of request. I'm still trying to figure out a way to measure and reduce this cost.

### RestClient

- Any request returns a [RestResponse]. [RestResponse] has a `deserialize<T>()` & `deserializeAsync<T>()` for getting json string data from the request as a class.
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
    JsonModelSerializer<TodoModel>((json) => TodoModel.fromJson(json)),
  }),
);

// Make an API call
final response = await service.get(Uri(path: '/todos'));

// Deserialize body as json to a model class.
final List<TodoModel>? data = await response.data<List<TodoModel>>();
```

## Additional information

- One good way to use this package is to create service using RestService.

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