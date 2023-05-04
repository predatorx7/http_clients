import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'strategy/join_strategy.dart';
import 'typedefs.dart';
import 'uri.dart';

/// A client that overrides [url], [headers] of the request.
///
/// Use [onJoinPath] to decide path joining strategy.
class ClientWith extends BaseClient {
  /// If not null, this will merge with the url in the request.
  ///
  /// Every part of the url that is not blank will override.
  final Uri? url;

  /// If not null, this will override the headers to override in the request.
  final Map<String, String>? headers;
  final Client _inner;

  /// Decides path joining strategy.
  /// Defaults to [PathJoinStrategy.originalOnlyIfHasHost].
  final PathJoinCallback onJoinPath;

  ClientWith(
    this._inner, {
    this.url,
    this.headers,
    this.onJoinPath = PathJoinStrategy.originalOnlyIfHasHost,
  });


  /// Returns a copy of [original] with the given [Request.body] where url 
  /// and headers are overriden.
  @protected
  StreamedRequest updateRequest(BaseRequest original) {
    final Stream<List<int>> body = original.finalize();
    final request = StreamedRequest(original.method, joinUrls(url, original.url, onJoinPath))
      ..contentLength = original.contentLength
      ..followRedirects = original.followRedirects
      ..headers.addAll(original.headers)
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;

    if (headers != null) {
      request.headers.addAll(headers!);
    }

    body.listen(
      request.sink.add,
      onError: request.sink.addError,
      onDone: request.sink.close,
      cancelOnError: true,
    );

    return request;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(updateRequest(request));
  }
}
