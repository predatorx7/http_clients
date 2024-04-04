import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:http/http.dart' as http;

typedef TestServer = ({HttpServer server, Uri uri});
typedef ServerResponse = Response;
typedef ServerRequest = Request;

Future<TestServer> startTestHttpServer(
  void Function(Router router) onRouter,
) async {
  var app = Router();

  app.get('/ping', (Request request) {
    return Response.ok('pong');
  });

  onRouter(app);

  final server = await io.serve(app.call, 'localhost', 8080);

  final serverUri = Uri.http('${server.address.host}:${server.port}');

  return (server: server, uri: serverUri);
}

void main() async {
  final server = await startTestHttpServer((router) {
    router.get(
      '/hello/<something>',
      (Request request, String something) => Response.ok('Hello $something'),
    );
  });

  print('Server running on ${server.uri}');

  await http.get(server.uri.replace(path: '/ping')).then((value) {
    print('response `/ping`: ${value.body}');
  });

  server.server.close();
}
