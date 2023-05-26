import 'strategy/path_join.dart';
import 'utils/utils.dart';

typedef PathJoinCallback = Iterable<String> Function(
  Uri otherUrl,
  Uri currentUrl,
);

/// Returns a url after joining [current] and [other].
///
/// [String] only [Uri] component from [other] is preferred because during usage,
/// this will be the last [Uri] received when making a request.
///
/// Merging of paths is decided with the [onJoinPath] callback. Check [PathJoinStrategy]
/// for more details.
Uri joinUrls(
  Uri other,
  Uri? current,
  PathJoinCallback onJoinPath,
) {
  if (current == null) return other;

  return Uri(
    scheme: whereStringNotBlankElseNull([other.scheme, current.scheme]),
    userInfo: whereStringNotBlankElseNull([other.userInfo, current.userInfo]),
    host: whereStringNotBlankElseNull([other.host, current.host]),
    port: other.host.isNotEmpty ? other.port : current.port,
    pathSegments: onJoinPath(
      other,
      current,
    ),
    queryParameters: mergeMapIfNotEmptyElseNull([
      other.queryParameters,
      current.queryParameters,
    ]),
    fragment: whereStringNotBlankElseNull([other.fragment, current.fragment]),
  );
}
