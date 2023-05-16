import 'package:http/http.dart' show BaseClient, Client, ClientException;
import 'package:meta/meta.dart';

/// An abstract class that wraps a [Client].
///
/// Implementors of [WrapperClient] class provides additional functionality to a
/// [Client] without having to modify the [Client] class itself. For example, a
/// [WrapperClient] could be used to add logging or caching functionality to a
/// [Client].
abstract class WrapperClient extends BaseClient {
  /// Creates a new [WrapperClient] with the given [client].
  ///
  /// The [client] must be a non-null [Client].
  WrapperClient(Client client) : _inner = client;

  /// Inner [Client] of this [WrapperClient].
  Client? _inner;

  /// The inner [Client] of this [WrapperClient].
  ///
  /// The inner [Client] is used to make HTTP requests.
  ///
  /// This will throw [ClientException] if [close] is called with `force` as
  /// `true` on this client.
  @protected
  Client get client {
    final inner = _inner;
    if (inner == null) {
      throw ClientException(
        'HTTP request failed. Client is already closed.',
      );
    }
    return inner;
  }

  @override
  @mustCallSuper

  /// Closes the client and cleans up any resources associated with it.
  ///
  /// It's important to close each client when it's done being used; failing to
  /// do so can cause the Dart process to hang.
  ///
  /// Once [close] is called, no other methods should be called. If [close] is
  /// called while other asynchronous methods are running, the behavior is
  /// undefined.
  ///
  /// If [force] is `true` (the default) the [WrapperClient] might
  /// not close the inner client.
  void close({bool force = true}) {
    if (!force) return;
    final client = _inner;
    if (client == null) return;
    if (client is WrapperClient) {
      client.close(force: force);
    } else {
      client.close();
    }
    _inner = null;
  }
}
