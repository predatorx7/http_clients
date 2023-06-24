import 'package:handle/handle.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../request.fake.dart';

void main() {
  group('RequestClient mock', () {
    test('Add properties to a request', () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {'some-header': 'some-value'},
      );

      await client.get(Uri(path: '/hello'));

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('some-value'));
      expect(receivedRequest?.url, equals(Uri.https('example.com', '/hello')));
    });

    test('Added properties can be overriden by requests', () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {'some-header': 'some-value'},
      );

      await client.get(
        Uri.https('other-example.com', '/hello'),
        headers: {'some-header': 'other-value'},
      );

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('other-value'));
      expect(
        receivedRequest?.url,
        equals(Uri.https('other-example.com', '/hello')),
      );
    });

    test('Add properties to a multipart request', () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {'some-header': 'some-value'},
      );

      await client.send(http.MultipartRequest('GET', Uri(path: '/hello')));

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('some-value'));
      expect(receivedRequest?.url, equals(Uri.https('example.com', '/hello')));
    });

    test('Added properties can be overriden by multipart requests', () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {'some-header': 'some-value'},
      );

      await client.send(http.MultipartRequest(
        'GET',
        Uri.https(
          'other-example.com',
          '/hello',
        ),
      )..headers.addAll({'some-header': 'other-value'}));

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('other-value'));
      expect(
        receivedRequest?.url,
        equals(Uri.https('other-example.com', '/hello')),
      );
    });

    test('Add properties to a streamed request', () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {'some-header': 'some-value'},
      );

      await client.send(
        http.StreamedRequest('GET', Uri(path: '/hello'))
          ..contentLength = 10
          ..sink.add([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
          ..sink.close(),
      );

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('some-value'));
      expect(receivedRequest?.url, equals(Uri.https('example.com', '/hello')));
    });

    test('Added properties can be overriden by streamed requests', () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {'some-header': 'some-value'},
      );

      await client.send(
        http.StreamedRequest(
          'GET',
          Uri.https(
            'other-example.com',
            '/hello',
          ),
        )
          ..contentLength = 10
          ..sink.add([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
          ..sink.close()
          ..headers.addAll({'some-header': 'other-value'}),
      );

      expect(receivedRequest, isNotNull);
      expect(receivedRequest?.headers['some-header'], equals('other-value'));
      expect(
        receivedRequest?.url,
        equals(Uri.https('other-example.com', '/hello')),
      );
    });

    test(
        "updateHeaderIf can prevent 'content-type': 'application/json' from being overriden in POST request",
        () async {
      http.BaseRequest? receivedRequest;
      late RequestClient client = RequestClient(
        RequestTestClient((request) {
          receivedRequest = request;
        }),
        url: Uri.https('example.com'),
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'some-header': 'some-value',
        },
        updateHeaderIf: (requestHeaders, header) {
          if (header.key == 'content-type') return true;
          return updateHeaderIfAbsent(requestHeaders, header);
        },
      );

      await client.post(Uri(path: '/hello'), body: '{"ok": true}');

      expect(receivedRequest, isNotNull);
      expect(
        receivedRequest?.headers['content-type'],
        contains('application/json; charset=utf-8'),
      );
      expect(receivedRequest?.headers['some-header'], equals('some-value'));
      expect(receivedRequest?.url, equals(Uri.https('example.com', '/hello')));
    });
  });
}
