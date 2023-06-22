import 'package:async/async.dart';
import 'package:http/http.dart';

extension CopyRequestExtension on BaseRequest {
  /// Returns a new copy of this [BaseRequest] which can be used to retry
  /// sending an HTTP request.
  ///
  /// Body is copied from this when [copyBody] is `true`.
  ///
  /// Note: A copy must be created before a [BaseRequest] is finalized.
  BaseRequest createCopy([bool copyBody = true]) {
    final request = StreamedRequest(method, url)
      ..contentLength = contentLength
      ..followRedirects = followRedirects
      ..headers.addAll(headers)
      ..maxRedirects = maxRedirects
      ..persistentConnection = persistentConnection;
    if (copyBody) {
      final body = StreamSplitter(finalize()).split();

      body.listen(
        request.sink.add,
        onError: request.sink.addError,
        onDone: request.sink.close,
        cancelOnError: true,
      );
    }

    return request;
  }
}
