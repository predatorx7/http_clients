import 'strategy/path_join.dart';
import 'utils/utils.dart';

typedef PathJoinCallback = Iterable<String> Function(
  Uri originalUrl,
  Uri otherUrl,
);

/// Returns a url after joining [other] and [it].
///
/// [String] only [Uri] component from [it] is preferred because during usage,
/// this will be the last [Uri] received when making a request.
///
/// Merging of paths is decided with the [onJoinPath] callback. Check [PathJoinStrategy]
/// for more details.
Uri joinUrls(
  Uri it,
  Uri? other,
  PathJoinCallback onJoinPath,
) {
  if (other == null) return it;

  return Uri(
    scheme: whereStringNotBlankElseNull([it.scheme, other.scheme]),
    userInfo: whereStringNotBlankElseNull([it.userInfo, other.userInfo]),
    host: whereStringNotBlankElseNull([it.host, other.host]),
    port: it.host.isNotEmpty ? it.port : other.port,
    pathSegments: onJoinPath(
      it,
      other,
    ),
    queryParameters: mergeMapIfNotEmptyElseNull([
      it.queryParameters,
      other.queryParameters,
    ]),
    fragment: whereStringNotBlankElseNull([it.fragment, other.fragment]),
  );
}
