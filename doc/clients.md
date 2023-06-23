# Clients

## Available HTTP Clients

- **RestClient**: A client for REST requests that de/serializes models on request and response.
- **RequestClient**: A client that lets you modify request url and headers.
- **InterceptorClient**: A client that allows you to add interceptors to requests and responses.
- **RequestInterceptorClient**, and **ResponseInterceptorClient** to individually intercept requests or responses.
- **ConverterClient**: A client that allows you to convert requests and responses before they are sent or received.
- **RequestConverterClient**, or **ResponseConverterClient** to individually modify requests or responses.
- **HandleClient**: A client that allows retrying HTTP request with different request on response or errors.

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

### HandleClient or Handle.client

A client that allows retrying HTTP request with different request on response or errors. 

Following below is an example where we retry a request after updating authorization token if response returns 401 status code.

```dart
// handle cases where response returns status 401 when request has invalid authorization token
final client = Handle.client(
  someClient,
  when: (response, count) async {
    return response.statusCode == 401 && await acquireToken();
  },
  updateRequest: (
    originalRequest,
    lastRequest,
    bodyStream,
    response,
    retryCount,
  ) {
    return lastRequest.createCopy(bodyStream())
      ..headers['authorization'] = token;
  },
);

// send a request that needs authorization
client
.get(Uri.http('example.com', '/hello'), headers: {
  'authorization': token,
});
```

For a complete sample, see the [Handle client sample][] in the example directory.
For more on how to configure clients in `handle`, see [Configuration].

[Handle client sample]: https://github.com/predatorx7/handle/tree/main/example/api/clients/handle.dart
[Configuration]: https://pub.dev/documentation/handle/latest/topics/Configuration-topic.html
