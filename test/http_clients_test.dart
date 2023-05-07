import 'package:http_clients/src/strategy/path_join.dart';
import 'package:http_clients/src/uri.dart';

import 'package:test/test.dart';

void main() {
  group('joinUrls', () {
    test('join with PathJoinStrategy.originalFirstIfHasHost', () {
      expect(
        joinUrls(Uri.https('api.example.com'), Uri.parse('/products/1'),
                PathJoinStrategy.originalOnlyIfHasHost)
            .toString(),
        Uri.https('api.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
                Uri.https('api.example.com'),
                Uri.parse('https://api2.example.com/products/1'),
                PathJoinStrategy.originalOnlyIfHasHost)
            .toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
                Uri.https('api.example.com', '/hello'),
                Uri.parse('https://api2.example.com/products/1'),
                PathJoinStrategy.originalOnlyIfHasHost)
            .toString(),
        Uri.https('api2.example.com', '/products/1').toString(),
      );

      expect(
        joinUrls(
                Uri.https('api.example.com', '/hello'),
                Uri.parse('/products/1'),
                PathJoinStrategy.originalOnlyIfHasHost)
            .toString(),
        Uri.https('api.example.com', '/hello/products/1').toString(),
      );

      expect(
        joinUrls(
                Uri(path: '/hello'),
                Uri.parse('api.example.com/products/1'),
                PathJoinStrategy.originalOnlyIfHasHost)
            .toString(),
        Uri.https('api.example.com', '/products/1/hello').toString(),
      );
    });
  });
}
