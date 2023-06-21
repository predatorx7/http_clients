import 'package:handle/src/strategy/path_join.dart';
import 'package:handle/src/uri.dart';

import 'package:test/test.dart';

void main() {
  group('joinUrls', () {
    test('Merge queryParameters', () {
      final mergedUri = joinUrls(
        Uri(queryParameters: {
          'hello': 'world',
        }),
        Uri(queryParameters: {
          'foo': 'bar',
        }),
        (a, b) => PathJoinStrategy(a, b).resolve(),
      );
      expect(mergedUri.queryParameters['hello'], equals('world'));
      expect(mergedUri.queryParameters['foo'], equals('bar'));
    });
  });

  group('PathJoinStrategy', () {
    test('default', () {
      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/hello/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri(path: '/hello'),
          Uri.parse('https://api.example.com/products/1'),
          (a, b) => PathJoinStrategy(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1/hello').toString(),
      );
    });

    test('otherFirst', () {
      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.otherFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.otherFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.otherFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1/hello').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.otherFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1/hello').toString(),
      );

      expect(
        joinUrls(
          Uri(path: '/hello'),
          Uri.parse('https://api.example.com/products/1'),
          (a, b) => PathJoinStrategy.otherFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/hello/products/1').toString(),
      );
    });

    test('currentFirst', () {
      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.currentFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.currentFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.currentFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/hello/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.currentFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/hello/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri(path: '/hello'),
          Uri.parse('https://api.example.com/products/1'),
          (a, b) => PathJoinStrategy.currentFirst(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1/hello').toString(),
      );
    });

    test('otherOnly', () {
      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.otherOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.otherOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.otherOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.otherOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
          Uri(path: '/hello'),
          Uri.parse('https://api.example.com/products/1'),
          (a, b) => PathJoinStrategy.otherOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/hello').toString(),
      );
    });

    test('currentOnly', () {
      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.currentOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com'),
          (a, b) => PathJoinStrategy.currentOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('https://api2.example.com/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.currentOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api2.example.com', '/hello').toString(),
      );

      expect(
        joinUrls(
          Uri.parse('/products/1'),
          Uri.https('api.example.com', '/hello'),
          (a, b) => PathJoinStrategy.currentOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/hello').toString(),
      );

      expect(
        joinUrls(
          Uri(path: '/hello'),
          Uri.parse('https://api.example.com/products/1'),
          (a, b) => PathJoinStrategy.currentOnly(a, b).resolve(),
        ).toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );
    });
  });
}
