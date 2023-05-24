import 'package:handle/src/strategy/path_join.dart';
import 'package:handle/src/uri.dart';

import 'package:test/test.dart';

void main() {
  group('joinUrls', () {
    test('join with PathJoinStrategy.originalOnlyIfHasHost', () {
      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com'),
          PathJoinStrategy.originalOnlyIfHasHost,
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com'),
          PathJoinStrategy.originalOnlyIfHasHost,
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com', '/hello'),
          PathJoinStrategy.originalOnlyIfHasHost,
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com', '/hello'),
          PathJoinStrategy.originalOnlyIfHasHost,
        ).toString(),
        Uri.https('api.example.com', '/hello/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri(path: '/hello'),
          Uri.parse('https://api.example.com/products/1'),
          PathJoinStrategy.originalOnlyIfHasHost,
        ).toString(),
        Uri.https('api.example.com', '/products/1/hello').toString(),
      );
    });
  });
}
