import 'package:http/http.dart' show BaseClient, Client, ClientException;
import 'package:meta/meta.dart';

/// An abstract class that wraps a [Client].
///
/// Implementors of [WrapperClient] class provides additional functionality to a
/// [Client] without having to modify the [Client] class itself. For example, a
/// [WrapperClient] could be used to add logging or caching functionality to a
/// [Client].
///
/// {@category Clients}
/// {@category Configuration}
/// {@category Error handling}
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
  Client get inner {
    final client = _inner;
    if (client == null) {
      throw ClientException(
        'HTTP request failed. Client is already closed.',
      );
    }
    return client;
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
  /// When [force] is `true` (the default), the [WrapperClient] might
  /// close the inner client. To avoid closing the inner client, set [force] to true.
  ///
  /// The optional [keepAliveHttpClient] parameter is used to specify an HTTP [Client]
  /// that should not be closed by this [close] method. This can be useful for
  /// HTTP clients that are used to make long-lived connections to remote
  /// servers. If it is not specified, all internal HTTP clients will be closed
  /// by this [close] method when [force] is `true`.
  ///
  /// Note: [force] is `true` by default to keep this [close]'s default
  /// behaviour consistent with [Client.close] because [BaseClient.close]
  /// doesn't have a parameter to avoid closing its inner client.
  void close({
    bool force = true,
    Client? keepAliveHttpClient,
  }) {
    if (!force) return;
    final client = _inner;
    if (client == null || client == keepAliveHttpClient) return;
    if (client is WrapperClient) {
      client.close(force: force, keepAliveHttpClient: keepAliveHttpClient);
    } else {
      client.close();
    }
    _inner = null;
  }
}
