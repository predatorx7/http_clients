import '../utils/utils.dart';

typedef FromJsonCallback<T> = T? Function(Object? json);

class JsonModelSerializerError implements Exception {
  final String message;

  const JsonModelSerializerError(this.message);

  @override
  String toString() {
    return 'JsonModelSerializerError: $message';
  }
}

/// A class that serializes and deserializes JSON objects to and from
/// Dart classes.
class JsonModelSerializer {
  JsonModelSerializer({
    Map<Type, FromJsonCallback<Object>> deserializers = const {},
  }) : _deserializers = {...deserializers};

  final Map<Type, FromJsonCallback<Object>> _deserializers;

  FromJsonCallback<T> getDeserializer<T>() {
    final deserializer = _deserializers[T];
    if (deserializer != null) {
      return deserializer as FromJsonCallback<T>;
    }
    throw JsonModelSerializerError('No deserializer found for type `$T`');
  }

  bool contains<T>() {
    return _deserializers.containsKey(T);
  }

  FromJsonCallback<T> addDeserializer<T>(FromJsonCallback<T> fromJson) {
    assert(T != dynamic);
    _deserializers[T] = fromJson;
    return fromJson;
  }

  void addAllDeserializers(Map<Type, FromJsonCallback<Object>> other) {
    _deserializers.addAll(other);
  }

  void apply(JsonModelSerializer serializer) {
    _deserializers.addAll(serializer._deserializers);
  }

  FromJsonCallback<T>? removeDeserializer<T>() {
    assert(T != dynamic);
    final type = _getTypeFrom<List<T>>();
    _deserializers.remove(type);
    return _deserializers.remove(T) as FromJsonCallback<T>?;
  }

  FromJsonCallback<T> putDeserializerIfAbsent<T>(
      FromJsonCallback<T> Function() ifAbsent) {
    assert(T != dynamic);
    return _deserializers.putIfAbsent(T, ifAbsent) as FromJsonCallback<T>;
  }

  T? deserialize<T>(Object? json) {
    final jsonBody = json is String ? (tryDecodeJson(json) ?? json) : json;
    final deserializer = getDeserializer<T>();
    return deserializer(jsonBody);
  }

  Future<T?> deserializeAsync<T>(String body) {
    return runInIsolate(() {
      return deserialize<T>(body);
    }, debugName: 'deserializeAsync<$T>');
  }

  /// A common [JsonModelSerializer].
  static final common = JsonModelSerializer();

  /// Creates and returns a new copy of JsonModelSerializer
  /// which includes serializers from both `this` and [other].
  JsonModelSerializer merge([JsonModelSerializer? other]) {
    final serializers = JsonModelSerializer();
    serializers.apply(common);
    if (other != null) {
      serializers.apply(other);
    }
    return serializers;
  }

  FromJsonCallback<List<T>> addJsonListDeserializerOf<T>() {
    assert(T != dynamic);
    return addDeserializer<List<T>>(
      getJsonListSerializer<T>(getDeserializer<T>()),
    );
  }
}

Type _getTypeFrom<T>() {
  return T;
}

FromJsonCallback<List<T>> getJsonListSerializer<T>(
  FromJsonCallback<T> fromJson,
) {
  return (object) {
    if (object is! Iterable) return null;
    return object.map(fromJson).whereType<T>().toList();
  };
}
