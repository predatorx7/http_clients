import 'package:http/http.dart' as http;

class RequestTestClient extends http.BaseClient {
  final void Function(http.BaseRequest request) onRequest;

  RequestTestClient(this.onRequest);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    onRequest(request);
    return Future.value(http.StreamedResponse(Stream.empty(), 200));
  }
}
