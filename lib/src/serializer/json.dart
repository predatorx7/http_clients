import 'dart:async';

import 'package:handle/src/utils/compute.dart';
import 'package:quiver/core.dart' as quiver;
import '../utils/utils.dart';

typedef FromJsonCallback<T> = T? Function(dynamic json);

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

  @override
  bool operator ==(Object? other) {
    return other is JsonDeserializerOf<T> &&
        other.deserializeFromJson == deserializeFromJson;
  }

  @override
  int get hashCode => quiver.hash2(T, deserializeFromJson);
}

/// A class that serializes and deserializes JSON objects to and from
/// Dart classes.
///
/// {@category Configuration}
/// {@category Get started}
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
      _deserializers.remove(List<T>);
    }
    return _deserializers.remove(T) as JsonDeserializerOf<T>?;
  }

  T? deserialize<T>(Object? json) {
    final jsonBody = json is String ? (tryDecodeJson(json) ?? json) : json;
    final deserializer = getDeserializer<T>();
    return deserializer(jsonBody);
  }

  FutureOr<T?> deserializeAsync<T>(String body) {
    return compute(() {
      return deserialize<T>(body);
    }, debugName: 'deserializeAsync<$T>');
  }

  /// A common [JsonModelSerializer].
  static final common = JsonModelSerializer();

  /// Creates and returns a new copy of JsonModelSerializer
  /// which includes serializers from both `this` and [other].
  JsonModelSerializer merge([JsonModelSerializer? other]) {
    final serializers = JsonModelSerializer();
    serializers.apply(this);
    serializers.apply(common);
    if (other != null) {
      serializers.apply(other);
    }
    return serializers;
  }
}
