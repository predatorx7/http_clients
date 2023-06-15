# Clients

## Available HTTP Clients

- **RestClient**: A client for REST requests that de/serializes models on request and response.
- **RequestClient**: A client that lets you modify request url and headers.
- **InterceptorClient**: A client that allows you to add interceptors to requests and responses.
- **RequestInterceptorClient**, and **ResponseInterceptorClient** to individually intercept requests or responses.
- **ConverterClient**: A client that allows you to convert requests and responses before they are sent or received.
- **RequestConverterClient**, or **ResponseConverterClient** to individually modify requests or responses.

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

More detailed example: [Request Client Example](https://github.com/predatorx7/handle/blob/main/example/api/clients/request.dart)

Note: This could take more memory incase of big request body because it may create a copy of request. I'm still trying to figure out a way to measure and reduce this cost.

### RestClient

- Any request returns a [RestResponse](https://pub.dev/documentation/handle/latest/handle/RestResponse-class.html). [RestResponse](https://pub.dev/documentation/handle/latest/handle/RestResponse-class.html) has a `deserialize<T>()` & `deserializeAsync<T>()` for getting json string data from the request as a class.
- Deserializer for any type `T` must be added to the [JsonModelSerializer](https://pub.dev/documentation/handle/latest/handle/JsonModelSerializer-class.html) in [RestClient](https://pub.dev/documentation/handle/latest/handle/RestClient-class.html)'s contructor or in [JsonModelSerializer.common](https://pub.dev/documentation/handle/latest/handle/JsonModelSerializer/common.html).

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
