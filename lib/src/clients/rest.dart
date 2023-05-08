import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart';

import '../serializer/json.dart';
import '../utils.dart';

class RestResponse extends Response {
  /// Create a new HTTP response with a byte array body.
  RestResponse.bytes(
    super.bodyBytes,
    super.statusCode, {
    super.request,
    super.headers,
    super.isRedirect,
    super.persistentConnection,
    super.reasonPhrase,
    JsonModelSerializer? serializer,
  })  : serializer = JsonModelSerializer.from(serializer),
        super.bytes();

  final JsonModelSerializer serializer;

  Object? get jsonBody {
    return tryDecodeJson(body);
  }

  Future<Object?> get jsonBodyAsync {
    return Isolate.run(() => tryDecodeJson(body));
  }

  T? deserializeBody<T>() {
    if (!serializer.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    return serializer.deserialize<T>(body);
  }

  Future<T?> deserializeBodyAsync<T>() {
    if (!serializer.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    return serializer.deserializeAsync<T>(body);
  }

  /// Creates a new HTTP Rest response by waiting for the full body to become
  /// available from a [Response].
  static Future<RestResponse> fromResponse(
    Future<Response> futureResponse,
    JsonModelSerializer? serializer,
  ) async {
    final response = await futureResponse;
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
      super.post(url, headers: headers, body: body, encoding: encoding),
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
      super.put(url, headers: headers, body: body, encoding: encoding),
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
      super.patch(url, headers: headers, body: body, encoding: encoding),
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
      super.delete(url, headers: headers, body: body, encoding: encoding),
    );
  }

  Future<RestResponse> _makeRest(Future<Response> response) {
    return RestResponse.fromResponse(response, serializer);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
