import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../strategy/path_join.dart';
import '../uri.dart';
import 'force_closable.dart';

/// A client that overrides [url], [headers] of the request.
///
/// Use [onJoinPath] to decide path joining strategy.
class RequestClient extends ParentClient {
  /// If not null, this will merge with the url in the request.
  ///
  /// Every part of the url that is not blank will override.
  final Uri? url;

  /// If not null, this will override the headers to override in the request.
  final Map<String, String>? headers;

  /// Decides path joining strategy.
  /// Defaults to [PathJoinStrategy.originalOnlyIfHasHost].
  final PathJoinCallback onJoinPath;

  /// Creates a [RequestClient] http client that can update the url
  /// and headers of a [BaseRequest] with [url], and [headers].
  RequestClient(
    Client client, {
    this.url,
    this.headers,
    this.onJoinPath = PathJoinStrategy.originalOnlyIfHasHost,
  }) : super(client);

  bool needsRequestUpdate({
    required Uri originalUrl,
    required Uri newUrl,
    required Map<String, String> originalHeaders,
  }) {
    final originalUrlString = originalUrl.toString();
    final newUrlString = newUrl.toString();
    final urlNeedsUpdate = originalUrlString != newUrlString;
    if (urlNeedsUpdate) return true;
    final headersNeedUpdate =
        !(const MapEquality().equals(headers, originalHeaders));

    return headersNeedUpdate;
  }

  /// Returns an updated copy of [original] with the given [Request.body]
  /// where url and headers are overriden. If url and headers is same as
  /// request or both are null then the original request is returned.
  @protected
  BaseRequest updateRequest(BaseRequest original) {
    if (url == null && (headers == null || headers!.isEmpty)) return original;
    final newUrl = joinUrls(original.url, url, onJoinPath);
    final hasEqualUrls = original.url.toString() == newUrl.toString();
    final hasEqualHeaders =
        const MapEquality().equals(headers, original.headers);
    if (hasEqualUrls && hasEqualHeaders) return original;

    final BaseRequest request;
    // Todo: Check if copying based on Request Type is faster
    // compared copying as StreamedRequest from finalized BaseRequest.
    if (original is Request) {
      request = Request(original.method, newUrl)
        ..bodyBytes = original.bodyBytes
        ..encoding = original.encoding
        ..followRedirects = original.followRedirects
        ..headers.addAll(original.headers)
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
    } else if (original is MultipartRequest) {
      request = MultipartRequest(original.method, newUrl)
        ..fields.addAll(original.fields)
        ..files.addAll(original.files)
        ..followRedirects = original.followRedirects
        ..headers.addAll(original.headers)
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
    } else {
      final Stream<List<int>> body = original.finalize();
      // This makes a copy of the request data in order to support
      // resending it. This can cause a lot of memory usage when sending a large
      // [StreamedRequest].
      request = StreamedRequest(
          original.method, joinUrls(original.url, url, onJoinPath))
        ..contentLength = original.contentLength
        ..followRedirects = original.followRedirects
        ..headers.addAll(original.headers)
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;

      request as StreamedRequest;

      body.listen(
        request.sink.add,
        onError: request.sink.addError,
        onDone: request.sink.close,
        cancelOnError: true,
      );
    }

    if (headers != null) {
      request.headers.addAll(headers!);
    }

    return request;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return client.send(updateRequest(request));
  }
}
