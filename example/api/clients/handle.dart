import 'dart:async';

import 'package:handle/handle.dart';
import 'package:http/http.dart';

import '../../../test/test_server.dart';

void main() async {
  // some local server that declare 2 http api routes
  final server = await startTestHttpServer((router) {
    router.get('/hello', (ServerRequest request) {
      if (request.headers['authorization'] == 'newtoken') {
        return ServerResponse.unauthorized(null);
      }
      return ServerResponse.ok('hello world!');
    });
    // Returns an authorization token
    router.get('/auth', (ServerRequest request) {
      return ServerResponse.ok('newtoken');
    });
  });

  final someClient = Client();

  String token = 'oldtoken';

  // using a completer lock here would be better
  Future<bool> acquireToken() async {
    // send request to server to acquire token
    final response = await someClient.get(server.uri.replace(path: '/auth'));
    if (response.statusCode == 200) {
      // update token and return it
      token = response.body;
      return true;
    }
    return false;
  }

  final client = Handle.client(
    someClient,
    when: (response, count) async {
      return response.statusCode == 401 && await acquireToken();
    },
    updateRequest: (
      originalRequest,
      lastRequest,
      bodyStream,
      response,
      retryCount,
    ) {
      return lastRequest.createCopy(bodyStream())
        ..headers['authorization'] = token;
    },
  );

  // send request to localhost:8000/hello api that needs some authorization token
  client
      .get(server.uri.replace(path: '/hello'), headers: {
        'authorization': token,
      })
      .then((it) => print(it.body))
      .then((_) {
        client.close();
        // ignore the below line. Just here to close the server used in this demo.
        server.server.close();
      });
}
