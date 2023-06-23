import 'dart:async';

import 'package:async/async.dart';
import 'package:http/http.dart';

typedef FinalizedBodyStream = Stream<List<int>>;

typedef FinalizedBodyStreamCallback = FinalizedBodyStream Function();

extension FinalizedBodyStreamExtension on FinalizedBodyStream {
  StreamSubscription<List<int>> addStreamToSinks(
    Iterable<EventSink<List<int>>> sinks,
  ) {
    void onAdd(List<int> bytes) {
      for (final sink in sinks) {
        sink.add(bytes);
      }
    }

    void onAddError(Object error, [StackTrace? stackTrace]) {
      for (final sink in sinks) {
        sink.addError(error, stackTrace);
      }
    }

    void onDone() {
      for (final sink in sinks) {
        sink.close();
      }
    }

    return listen(
      onAdd,
      onError: onAddError,
      onDone: onDone,
      cancelOnError: true,
    );
  }
}

extension CopyRequestExtension on BaseRequest {
  /// Finalizes the request and returns a single-subscription stream of body
  /// as bytes.
  ///
  /// Calling this on a finalized request or a request with no body will return
  /// an empty stream.
  FinalizedBodyStream get finalizedBodyStream {
    if (finalized) {
      return const Stream.empty();
    }
    return StreamSplitter(finalize()).split();
  }

  /// Returns a new copy of this [BaseRequest] which can be used to retry
  /// sending an HTTP request.
  ///
  /// The new request gets a body from [bodyStream].
  BaseRequest createCopy([Stream<List<int>>? bodyStream]) {
    final request = StreamedRequest(method, url)
      ..contentLength = contentLength
      ..followRedirects = followRedirects
      ..headers.addAll(headers)
      ..maxRedirects = maxRedirects
      ..persistentConnection = persistentConnection;

    if (bodyStream != null) {
      bodyStream.listen(
        request.sink.add,
        onError: request.sink.addError,
        onDone: request.sink.close,
        cancelOnError: true,
      );
    }

    return request;
  }
}
