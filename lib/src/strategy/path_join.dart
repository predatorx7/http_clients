import 'package:http/http.dart' show Client;
import 'package:handle/src/utils/utils.dart';
import '../clients/request.dart' show RequestClient;
import '../uri.dart' show PathJoinCallback;

typedef PathJoinStrategyCallback = PathJoinStrategy Function(
  Uri otherUri,
  Uri currentUri,
);

/// Returns a path segment by resolving (or merging) [otherUri] and
/// [currentUri]. Implementors of this class must resolve the 2 urls based on a
/// strategy so that those classes can be used as a [PathJoinCallback].
abstract class PathJoinStrategy {
  /// This is a [Uri] that is inherited from wrapped (or child) [Client]s.
  Uri get otherUri;

  /// This is a [Uri] that was given to the [RequestClient] which used this
  /// strategy.
  Uri get currentUri;

  /// Returns a path segment as [Iterable<String>] by resolving (or merging)
  /// [otherUri] and [currentUri]. This is used in the [RequestClient] where
  /// [otherUri] is inherited from wrapped (or child) [Client]s.
  Iterable<String> resolve();

  static PathJoinCallback onJoinPath(
    PathJoinStrategyCallback strategy,
  ) {
    Iterable<String> resolve(
      Uri otherUri,
      Uri currentUri,
    ) {
      return strategy(otherUri, currentUri).resolve();
    }

    return resolve;
  }

  /// {@macro DefaultPathJoinStrategy}
  const factory PathJoinStrategy(
    Uri otherUri,
    Uri currentUri,
  ) = DefaultPathJoinStrategy;

  /// {@macro CurrentOnlyPathJoinStrategy}
  const factory PathJoinStrategy.currentOnly(
    Uri otherUri,
    Uri currentUri,
  ) = CurrentOnlyPathJoinStrategy;

  /// {@macro OtherOnlyPathJoinStrategy}
  const factory PathJoinStrategy.otherOnly(
    Uri otherUri,
    Uri currentUri,
  ) = OtherOnlyPathJoinStrategy;

  /// {@macro OtherFirstPathJoinStrategy}
  const factory PathJoinStrategy.otherFirst(
    Uri otherUri,
    Uri currentUri,
  ) = OtherFirstPathJoinStrategy;

  /// {@macro CurrentFirstPathJoinStrategy}
  const factory PathJoinStrategy.currentFirst(
    Uri otherUri,
    Uri currentUri,
  ) = CurrentFirstPathJoinStrategy;
}

abstract class _PathJoinStrategy implements PathJoinStrategy {
  const _PathJoinStrategy(this.otherUri, this.currentUri);

  @override
  final Uri otherUri;

  @override
  final Uri currentUri;
}

/// {@template DefaultPathJoinStrategy}
/// Returns an array of path segments.
///
/// Path segments of [otherUri] is returned if [otherUri] has host else
/// returns path segments of both [currentUri] and [otherUri] where [currentUri]
/// is placed first.
/// {@endtemplate}
class DefaultPathJoinStrategy extends _PathJoinStrategy {
  const DefaultPathJoinStrategy(super.otherUri, super.currentUri);

  @override
  Iterable<String> resolve() {
    final hasHostInOriginal = !isNullOrBlank(otherUri.host);
    if (hasHostInOriginal) {
      return [
        ...otherUri.pathSegments,
      ];
    }
    return [
      ...currentUri.pathSegments,
      ...otherUri.pathSegments,
    ];
  }
}

/// {@template CurrentOnlyPathJoinStrategy}
/// A path join strategy that only returns the currentUri passed to it.
/// {@endtemplate}
class CurrentOnlyPathJoinStrategy extends _PathJoinStrategy {
  const CurrentOnlyPathJoinStrategy(super.otherUri, super.currentUri);

  @override
  Iterable<String> resolve() {
    return currentUri.pathSegments;
  }
}

/// {@template OtherOnlyPathJoinStrategy}
/// A path join strategy that only returns the otherUri passed to it.
/// {@endtemplate}
class OtherOnlyPathJoinStrategy extends _PathJoinStrategy {
  const OtherOnlyPathJoinStrategy(super.otherUri, super.currentUri);

  @override
  Iterable<String> resolve() {
    return otherUri.pathSegments;
  }
}

/// {@template OtherFirstPathJoinStrategy}
/// A path join strategy that returns path segments where the path segments of
/// [otherUri] is ordered before [currentUri] passed to it.
/// {@endtemplate}
class OtherFirstPathJoinStrategy extends _PathJoinStrategy {
  const OtherFirstPathJoinStrategy(super.otherUri, super.currentUri);

  @override
  Iterable<String> resolve() {
    return [
      ...otherUri.pathSegments,
      ...currentUri.pathSegments,
    ];
  }
}

/// {@template CurrentFirstPathJoinStrategy}
/// A path join strategy that returns path segments where the path segments of
/// [currentUri] is ordered before [otherUri] passed to it.
/// {@endtemplate}
class CurrentFirstPathJoinStrategy extends _PathJoinStrategy {
  const CurrentFirstPathJoinStrategy(super.otherUri, super.currentUri);

  @override
  Iterable<String> resolve() {
    return [
      ...currentUri.pathSegments,
      ...otherUri.pathSegments,
    ];
  }
}
