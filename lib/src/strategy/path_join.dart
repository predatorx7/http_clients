import 'package:http_clients/src/utils.dart';

class PathJoinStrategy {
  PathJoinStrategy._();

  static Iterable<String> originalOnly(
    Uri url,
    Uri original,
  ) {
    return original.pathSegments;
  }

  static Iterable<String> newOnly(
    Uri url,
    Uri original,
  ) {
    return url.pathSegments;
  }

  static Iterable<String> newBeforeOriginal(
    Uri url,
    Uri original,
  ) {
    return [
      ...url.pathSegments,
      ...original.pathSegments,
    ];
  }

  static Iterable<String> originalBeforeNew(
    Uri url,
    Uri original,
  ) {
    return [
      ...original.pathSegments,
      ...url.pathSegments,
    ];
  }

  /// Returns an array of path segments.
  ///
  /// Path segments of [originalUrl] is returned if [originalUrl] has host else
  /// returns path segments of both [url] and [originalUrl] where [url] is placed first.
  static Iterable<String> originalOnlyIfHasHost(
    Uri url,
    Uri originalUrl,
  ) {
    final hasHostInOriginal = !isNullOrBlank(originalUrl.host);

    return [
      if (hasHostInOriginal) ...originalUrl.pathSegments,
      if (!hasHostInOriginal) ...url.pathSegments,
      if (!hasHostInOriginal) ...originalUrl.pathSegments,
    ];
  }
}
