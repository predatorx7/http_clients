import 'package:handle/src/utils/utils.dart';

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
  /// returns path segments of both [otherUrl] and [originalUrl] where [otherUrl] is placed first.
  static Iterable<String> originalOnlyIfHasHost(
    Uri originalUrl,
    Uri otherUrl,
  ) {
    final hasHostInOriginal = !isNullOrBlank(originalUrl.host);
    if (hasHostInOriginal) {
      return [
        ...originalUrl.pathSegments,
      ];
    }
    return [
      ...otherUrl.pathSegments,
      ...originalUrl.pathSegments,
    ];
  }
}
