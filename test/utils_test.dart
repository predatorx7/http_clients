import 'package:http_clients/src/utils.dart';
import 'package:test/test.dart';

class _JsonEncodable {
  const _JsonEncodable();

  Map<String, Object?> toJson() {
    return {'hello': 'world'};
  }
}

class _JsonUnencodable {
  const _JsonUnencodable();
}

void main() {
  group('processForHttpBody', () {
    test('valid body', () {
      expect(processForHttpBody('true'), equals('true'));
      expect(
        processForHttpBody(<Object, Object>{'hello': 'world'}),
        isA<Map<String, String>>(),
      );
      expect(
        processForHttpBody(<Object>[2, 3, 4, 5, 8]),
        isA<List<int>>(),
      );
      expect(
        processForHttpBody(<Object, Object>{'hello': true}),
        isA<String>(),
      );
      expect(
        processForHttpBody(<Object>[2, true, '4', 5, 8]),
        isA<String>(),
      );
      expect(processForHttpBody(_JsonEncodable()), isA<String>());
      expect(processForHttpBody([_JsonEncodable()]), isA<String>());
    });

    test('invalid body', () {
      expect(() => processForHttpBody({'true'}), throwsArgumentError);
      expect(() => processForHttpBody(_JsonUnencodable()), throwsArgumentError);
      expect(() => processForHttpBody([_JsonUnencodable()]), throwsArgumentError);
    });
  });
}
