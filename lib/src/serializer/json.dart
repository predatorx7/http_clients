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

class JsonDeserializerOf<T extends Object> {
  final FromJsonCallback<T> deserializeFromJson;

  const JsonDeserializerOf(this.deserializeFromJson);

  Type get objectType => T;

  T? call(Object? json) => deserializeFromJson(json);

  JsonDeserializerOf<List<T>> getJsonListSerializer() {
    List<T>? fromJsonList(Object? object) {
      if (object is! Iterable) return null;
      if (object.isEmpty) return <T>[];
      return object.map(deserializeFromJson).whereType<T>().toList();
    }

    return JsonDeserializerOf<List<T>>(fromJsonList);
  }

  static Map<Type, JsonDeserializerOf<Object>> from(
    Iterable<JsonDeserializerOf<Object>> deserializers,
  ) {
    return <Type, JsonDeserializerOf<Object>>{
      for (final deserializer in deserializers)
        deserializer.objectType: deserializer,
    };
  }
}

/// A class that serializes and deserializes JSON objects to and from
/// Dart classes.
class JsonModelSerializer {
  JsonModelSerializer({
    Iterable<JsonDeserializerOf<Object>> deserializers = const [],
    bool addListSerializer = true,
  }) : _deserializers = {} {
    addDeserializers(deserializers, addListSerializer: addListSerializer);
  }

  final Map<Type, JsonDeserializerOf<Object>> _deserializers;

  FromJsonCallback<T> getDeserializer<T>() {
    final deserializer = _deserializers[T];
    if (deserializer != null) {
      return deserializer.deserializeFromJson as FromJsonCallback<T>;
    }
    throw JsonModelSerializerError('No deserializer found for type `$T`');
  }

  bool contains<T>() {
    return _deserializers.containsKey(T);
  }

  void addDeserializers(
    Iterable<JsonDeserializerOf<Object>> deserializers, {
    bool addListSerializer = true,
  }) {
    if (addListSerializer) {
      final listDeserializers = [
        for (final deserializer in deserializers)
          deserializer.getJsonListSerializer(),
      ];
      _deserializers.addAll(JsonDeserializerOf.from(listDeserializers));
    }
    _deserializers.addAll(JsonDeserializerOf.from(deserializers));
  }

  void apply(JsonModelSerializer serializer) {
    _deserializers.addAll(serializer._deserializers);
  }

  JsonDeserializerOf<T>? removeDeserializer<T extends Object>([
    bool removeAssociatedListDeserializer = true,
  ]) {
    assert(T != dynamic);
    if (removeAssociatedListDeserializer) {
      final type = _getTypeFrom<List<T>>();
      _deserializers.remove(type);
    }
    return _deserializers.remove(T) as JsonDeserializerOf<T>?;
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
}

Type _getTypeFrom<T>() {
  return T;
}
