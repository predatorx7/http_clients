import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../strategy/path_join.dart';
import '../uri.dart';
import 'wrapper.dart';

/// A client that overrides [url], [headers] of the request.
///
/// Use [pathJoinStrategy] to decide path joining strategy.
class RequestClient extends WrapperClient {
  /// If not null, this will merge with the url in the request.
  ///
  /// Every part of the url that is not blank will override.
  final Uri? url;

  /// If not null, this will override the headers to override in the request.
  final Map<String, String>? headers;

  /// Decides path joining strategy.
  /// Defaults to [DefaultPathJoinStrategy].
  final PathJoinStrategyCallback pathJoinStrategy;

  /// Creates a [RequestClient] http client that can update the url
  /// and headers of a [BaseRequest] with [url], and [headers].
  RequestClient(
    Client client, {
    this.url,
    this.headers,
    this.pathJoinStrategy = PathJoinStrategy.new,
  }) : super(client);

  /// Returns an updated copy of [original] with the given [Request.body]
  /// where url and headers are overriden. If url and headers is same as
  /// request or both are null then the original request is returned.
  @protected
  BaseRequest updateRequest(BaseRequest original) {
    if (url == null && (headers == null || headers!.isEmpty)) return original;
    final newUrl = joinUrls(
      original.url,
      url,
      PathJoinStrategy.onJoinPath(
        pathJoinStrategy,
      ),
    );
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
      request = StreamedRequest(original.method, newUrl)
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
    return inner.send(updateRequest(request));
  }
}
