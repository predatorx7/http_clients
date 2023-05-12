import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../serializer/json.dart';
import '../utils.dart';

/// A HTTP response for REST HTTP apis.
///
/// This will use only [serializer], and [JsonModelSerializer.common]
/// when deserializing a response body.
class RestResponse extends Response {
  /// Create a new HTTP rest response with a byte array body.
  RestResponse.bytes(
    List<int> bodyBytes,
    int statusCode, {
    BaseRequest? request,
    Map<String, String> headers = const {},
    bool isRedirect = false,
    bool persistentConnection = true,
    String? reasonPhrase,
    JsonModelSerializer? serializer,
  })  : serializer = JsonModelSerializer.common.merge(serializer),
        super.bytes(
          bodyBytes,
          statusCode,
          request: request,
          headers: headers,
          isRedirect: isRedirect,
          persistentConnection: persistentConnection,
          reasonPhrase: reasonPhrase,
        );

  final JsonModelSerializer serializer;

  /// Returns the Json object by parsing the response body string.
  /// The response is json decoded synchronously.
  ///
  /// For large response body, try [jsonBodyAsync].
  Object? get jsonBody {
    return tryDecodeJson(body);
  }

  /// Returns the Json object by parsing the response body string.
  /// The response is json decoded asynchronously in an isolate.
  ///
  /// For small response body, try [jsonBody].
  Future<Object?> get jsonBodyAsync {
    return runInIsolate(() => tryDecodeJson(body));
  }

  /// Returns [T] by deserializing the response body to it.
  /// The response is deserialized synchronously.
  ///
  /// For large response body, try [deserializeBodyAsync].
  T? deserializeBody<T>() {
    if (!serializer.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    return serializer.deserialize<T>(body);
  }

  /// Returns [T] by deserializing the response body to it.
  /// The response is deserialized asynchronously in an isolate.
  ///
  /// For small response body, try [deserializeBody].
  Future<T?> deserializeBodyAsync<T>() {
    if (!serializer.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    return serializer.deserializeAsync<T>(body);
  }

  /// Creates a new HTTP Rest response by waiting for the full body to become
  /// available from a [Response].
  factory RestResponse.fromResponse(
    Response response, [
    JsonModelSerializer? serializer,
  ]) {
    return RestResponse.bytes(
      response.bodyBytes,
      response.statusCode,
      serializer: serializer,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

/// Creates a client that returns [RestResponse] for a request.
///
/// The [RestResponse] will use only [serializer], and [JsonModelSerializer.common]
/// when deserializing a response body.
class RestClient extends BaseClient {
  final Client _inner;
  final JsonModelSerializer? serializer;

  RestClient(
    this._inner, {
    this.serializer,
  });

  @override
  Future<RestResponse> head(Uri url, {Map<String, String>? headers}) =>
      _makeRest(super.head(url, headers: headers));

  @override
  Future<RestResponse> get(Uri url, {Map<String, String>? headers}) =>
      _makeRest(super.get(url, headers: headers));

  @override
  Future<RestResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _makeRest(
      super.post(
        url,
        headers: headers,
        body: processForHttpBody(body),
        encoding: encoding,
      ),
    );
  }

  @override
  Future<RestResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _makeRest(
      super.put(
        url,
        headers: headers,
        body: processForHttpBody(body),
        encoding: encoding,
      ),
    );
  }

  @override
  Future<RestResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _makeRest(
      super.patch(
        url,
        headers: headers,
        body: processForHttpBody(body),
        encoding: encoding,
      ),
    );
  }

  @override
  Future<RestResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _makeRest(
      super.delete(
        url,
        headers: headers,
        body: processForHttpBody(body),
        encoding: encoding,
      ),
    );
  }

  Future<RestResponse> _makeRest(Future<Response> response) async {
    return RestResponse.fromResponse(await response, serializer);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
