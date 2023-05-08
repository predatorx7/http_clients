import 'dart:isolate';

import '../utils.dart';

typedef FromJsonCallback<T> = T? Function(Object? json);

class JsonModelSerializerError implements Exception {
  final String message;

  const JsonModelSerializerError(this.message);

  @override
  String toString() {
    return 'JsonModelSerializerError: $message';
  }
}

class JsonModelSerializer {
  const JsonModelSerializer(
    Map<Type, FromJsonCallback<Object>> serializers,
  ) : _serializers = serializers;

  final Map<Type, FromJsonCallback<Object>> _serializers;

  FromJsonCallback<T> get<T>() {
    final serializer = _serializers[T];
    if (serializer != null) {
      return serializer as FromJsonCallback<T>;
    }
    throw JsonModelSerializerError('No serializer found for type `$T`');
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
    _serializers.remove(Iterable<T>);
    return _serializers.remove(T) as FromJsonCallback<T>?;
  }

  FromJsonCallback<T> putIfAbsent<T>(FromJsonCallback<T> Function() ifAbsent) {
    assert(T != dynamic);
    return _serializers.putIfAbsent(T, ifAbsent) as FromJsonCallback<T>;
  }

  T? deserialize<T>(Object? json) {
    final jsonBody = json is String ? (tryDecodeJson(json) ?? json) : json;
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

  FromJsonCallback<List<T>> addListSerializer<T>() {
    return add<List<T>>(getJsonListSerializer<T>(get<T>()));
  }
}

FromJsonCallback<List<T>> getJsonListSerializer<T>(
  FromJsonCallback<T> fromJson,
) {
  return (object) {
    if (object is! Iterable) return null;
    return object.map(fromJson).whereType<T>().toList();
  };
}
