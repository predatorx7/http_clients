import 'package:handle/src/serializer/json.dart';
import 'package:test/test.dart';

class _A {
  factory _A.fromJson(Object? object) {
    throw UnimplementedError();
  }
}

class _B {
  factory _B.fromJson(Object? object) {
    throw UnimplementedError();
  }
}

void main() {
  group('JsonModelSerializer', () {
    test('addition', () {
      final serializer = JsonModelSerializer(
        deserializers: {
          JsonDeserializerOf<_A>(_A.fromJson),
        },
      );

      expect(serializer.contains<_A>(), isTrue);
      expect(serializer.contains<List<_A>>(), isTrue);
      expect(serializer.contains<_B>(), isFalse);
      expect(serializer.contains<List<_B>>(), isFalse);

      serializer.addDeserializers({JsonDeserializerOf<_B>(_B.fromJson)});
      expect(serializer.contains<_B>(), isTrue);
      expect(serializer.contains<List<_B>>(), isTrue);
    });

    test('unknown deserializer', () {
      final serializer = JsonModelSerializer();

      expect(
        () => serializer.getDeserializer<_A>(),
        throwsA(isA<JsonModelSerializerError>()),
      );
    });

    test('merge', () {
      final serializerA = JsonModelSerializer(
        deserializers: {
          JsonDeserializerOf<_A>(_A.fromJson),
        },
      );
      final serializerB = JsonModelSerializer(
        deserializers: {
          JsonDeserializerOf<_B>(_B.fromJson),
        },
      );

      final serializerAB = serializerA.merge(serializerB);
      expect(serializerAB.contains<_A>(), isTrue);
      expect(serializerAB.contains<_B>(), isTrue);

      final serializerBA = serializerB.merge(serializerA);
      expect(serializerBA.contains<_A>(), isTrue);
      expect(serializerBA.contains<_B>(), isTrue);
    });
  });

  test('removal', () {
    final serializer = JsonModelSerializer(
      deserializers: {
        JsonDeserializerOf<_A>(_A.fromJson),
        JsonDeserializerOf<_B>(_B.fromJson),
      },
    );

    serializer.removeDeserializer<_A>();
    expect(serializer.contains<_A>(), isFalse);
    expect(serializer.contains<List<_A>>(), isFalse);

    serializer.removeDeserializer<_B>(false);
    expect(serializer.contains<_B>(), isFalse);
    expect(serializer.contains<List<_B>>(), isTrue);
  });
}
