import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart';
import 'package:http_clients/src/typedefs.dart';

Object? _tryDecodeJson(String source) {
  if (source.isEmpty) return null;
  try {
    return json.decode(source);
  } catch (_) {
    return null;
  }
}

class JsonModelSerializer {
  const JsonModelSerializer(
    Map<Type, FromJsonCallback<Object>> serializers,
  ) : _serializers = serializers;

  final Map<Type, FromJsonCallback<Object>> _serializers;

  FromJsonCallback<T> get<T>() {
    return _serializers[T] as FromJsonCallback<T>;
  }

  bool contains<T>() {
    return _serializers.containsKey(T);
  }

  FromJsonCallback<T> add<T>(FromJsonCallback<T> fromJson) {
    assert(T != dynamic);
    _serializers[T] = fromJson;

    return fromJson;
  }

  void addAll(Map<Type, FromJsonCallback<Object>> other) {
    _serializers.addAll(other);
  }

  void merge(JsonModelSerializer serializers) {
    _serializers.addAll(serializers._serializers);
  }

  FromJsonCallback<T>? remove<T>() {
    assert(T != dynamic);
    return _serializers.remove(T) as FromJsonCallback<T>?;
  }

  FromJsonCallback<T> putIfAbsent<T>(FromJsonCallback<T> Function() ifAbsent) {
    assert(T != dynamic);
    return _serializers.putIfAbsent(T, ifAbsent) as FromJsonCallback<T>;
  }

  T? deserialize<T>(Object? json) {
    final jsonBody = json is String ? (_tryDecodeJson(json) ?? json) : json;
    final serializer = get<T>();
    return serializer(jsonBody);
  }

  Future<T?> deserializeAsync<T>(String body) {
    return Isolate.run(() {
      return deserialize(body);
    }, debugName: 'deserializeAsync<$T>');
  }

  static final common = JsonModelSerializer({});

  factory JsonModelSerializer.from(JsonModelSerializer? other) {
    final serializers = JsonModelSerializer({});
    serializers.merge(common);
    if (other != null) {
      serializers.merge(other);
    }
    return serializers;
  }
}

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
    JsonModelSerializer? serializers,
  })  : serializers = JsonModelSerializer.from(serializers),
        super.bytes();

  final JsonModelSerializer serializers;

  Object? getJsonBody() {
    return _tryDecodeJson(body);
  }

  Future<Object?> getJsonBodyAsync() {
    return Isolate.run(() => _tryDecodeJson(body));
  }

  T? deserializeBody<T>() {
    if (!serializers.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    return serializers.deserialize<T>(body);
  }

  Future<T?> deserializeBodyAsync<T>() {
    if (!serializers.contains<T>()) {
      throw ClientException('No serializers found for type `$T`.');
    }
    return serializers.deserializeAsync<T>(body);
  }

  /// Creates a new HTTP Rest response by waiting for the full body to become
  /// available from a [Response].
  static Future<RestResponse> fromResponse(
    Future<Response> futureResponse,
    JsonModelSerializer? serializers,
  ) async {
    final response = await futureResponse;
    return RestResponse.bytes(
      response.bodyBytes,
      response.statusCode,
      serializers: serializers,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

class RestClient extends BaseClient {
  final BaseClient _inner;
  final JsonModelSerializer? serializers;

  RestClient(
    this._inner, {
    this.serializers,
  });

  @override
  Future<RestResponse> head(Uri url, {Map<String, String>? headers}) =>
      _makeRest(super.head(url, headers: headers));

  @override
  Future<RestResponse> get(Uri url, {Map<String, String>? headers}) =>
      _makeRest(super.get(url, headers: headers));

  @override
  Future<RestResponse> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _makeRest(
          super.post(url, headers: headers, body: body, encoding: encoding));

  @override
  Future<RestResponse> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _makeRest(
          super.put(url, headers: headers, body: body, encoding: encoding));

  @override
  Future<RestResponse> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _makeRest(
          super.patch(url, headers: headers, body: body, encoding: encoding));

  @override
  Future<RestResponse> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _makeRest(
          super.delete(url, headers: headers, body: body, encoding: encoding));

  Future<RestResponse> _makeRest(Future<Response> response) {
    throw RestResponse.fromResponse(response, serializers);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }
}
