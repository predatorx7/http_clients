import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart';

import '../serializer/json.dart';
import '../utils/utils.dart';
import 'wrapper.dart';

/// {@category Clients}
class RestResponseException extends ClientException {
  final Object? innerException;
  final StackTrace? innerStackTrace;

  RestResponseException(
    String message, {
    Uri? uri,
    this.innerException,
    this.innerStackTrace,
  }) : super(
          message,
          uri,
        );

  @override
  String toString() {
    return 'RestResponseException: $message. $uri $innerException $innerStackTrace'
        .trim();
  }
}

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

  /// {@template RestResponse.jsonBody}
  /// Returns the Json object by parsing the response body string.
  /// The response is json decoded synchronously.
  ///
  /// For large response body, try [jsonBodyAsync].
  /// {@endtemplate}
  Object? get jsonBody {
    return tryDecodeJson(body);
  }

  /// {@template RestResponse.jsonBodyAsync}
  /// Returns the Json object by parsing the response body string.
  /// The response is json decoded asynchronously in an isolate.
  ///
  /// For small response body, try [jsonBody].
  /// {@endtemplate}
  Future<Object?> get jsonBodyAsync {
    return Isolate.run(() => tryDecodeJson(body));
  }

  /// {@template RestResponse.deserializeBody<T>}
  /// Returns [T] by deserializing the response body to it.
  /// The response is deserialized synchronously.
  ///
  /// For large response body, try [RestResponse.deserializeBodyAsync].
  /// {@endtemplate}
  T? deserializeBody<T extends Object>() {
    if (!serializer.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    try {
      return serializer.deserialize<T>(body);
    } catch (e, s) {
      throw RestResponseException(
        'Failed to deserialize body',
        uri: request?.url,
        innerException: e,
        innerStackTrace: s,
      );
    }
  }

  /// {@template RestResponse.deserializeBodyAsync<T>}
  /// Returns [T] by deserializing the response body to it.
  /// The response is deserialized asynchronously in an isolate.
  ///
  /// For small response body, try [RestResponse.deserializeBody].
  /// {@endtemplate}
  Future<T?> deserializeBodyAsync<T extends Object>() async {
    if (!serializer.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    try {
      return await serializer.deserializeAsync<T>(body);
    } catch (e, s) {
      // Todo: Replace with `Error.throwWithStackTrace(error, stackTrace);` in SDK 2.16.0.
      throw RestResponseException(
        'Failed to deserialize body asynchronously',
        uri: request?.url,
        innerException: e,
        innerStackTrace: s,
      );
    }
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

  /// Creates a new HTTP response by waiting for the full body to become
  /// available from a [StreamedResponse].
  static Future<RestResponse> fromStream(
    StreamedResponse response, [
    JsonModelSerializer? serializer,
  ]) async {
    final body = await response.stream.toBytes();
    return RestResponse.bytes(
      body,
      serializer: serializer,
      response.statusCode,
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
/// when deserializing a response body and it does not inherit from serializers
/// in the WrapperClient tree.
///
/// {@category Clients}
/// {@category Configuration}
/// {@category Get started}
class RestClient extends WrapperClient {
  /// {@template RestClient.serializer}
  /// The serializer that serializes and deserializes JSON objects to and from
  /// Dart classes.
  ///
  /// If null, the [RestResponse] will use [JsonModelSerializer.common] for
  /// deserialization. If not null, a [RestResponse] will create a new
  /// serializer from this and [JsonModelSerializer.common].
  /// {@endtemplate}
  JsonModelSerializer? serializer;

  RestClient(
    Client inner, {
    this.serializer,
  }) : super(inner);

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

  Future<RestResponse> multipart(
    MultipartRequest request,
  ) {
    return send(
      request,
    ).then((response) => RestResponse.fromStream(response, serializer));
  }

  Future<RestResponse> _makeRest(Future<Response> response) async {
    return RestResponse.fromResponse(await response, serializer);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return inner.send(request);
  }
}
