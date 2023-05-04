import 'strategy/join_strategy.dart';
import 'typedefs.dart';
import 'utils.dart';

/// Returns a url after joining [left] and [right].
/// 
/// [String] only [Uri] component from [right] is preferred because during usage,
/// this will be the last [Uri] received when making a request.
/// 
/// Merging of paths is decided with the [onJoinPath] callback. Check [PathJoinStrategy]
/// for more details.
Uri joinUrls(
  Uri? left,
  Uri right,
  PathJoinCallback onJoinPath,
) {
  if (left == null) return right;

  return Uri(
    scheme: whereStringNotBlankElseNull([right.scheme, left.scheme]),
    userInfo: whereStringNotBlankElseNull([right.userInfo, left.userInfo]),
    host: whereStringNotBlankElseNull([right.host, left.host]),
    port: right.host.isNotEmpty ? right.port : left.port,
    pathSegments: onJoinPath(
      left,
      right,
    ),
    queryParameters: mergeMapIfNotEmptyElseNull([
      right.queryParameters,
      left.queryParameters,
    ]),
    fragment: whereStringNotBlankElseNull([right.fragment, left.fragment]),
  );
}
