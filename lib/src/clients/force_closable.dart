import 'package:http/http.dart' show BaseClient, Client, ClientException;
import 'package:meta/meta.dart';

abstract class ParentClient extends BaseClient {
  ParentClient(Client? client) : _inner = client;

  /// Inner [Client] of this [ParentClient].
  Client? _inner;

  @protected
  Client getClient([Uri? url]) {
    final inner = _inner;
    if (inner == null) {
      throw ClientException(
        'HTTP request failed. Client is already closed.',
        url,
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
  /// If [force] is `false` (the default) the [ParentClient] might
  /// not close the inner client.
  void close({bool force = false}) {
    if (!force) return;
    final client = _inner;
    if (client == null) return;
    if (client is ParentClient) {
      client.close(force: force);
    } else {
      client.close();
    }
    _inner = null;
  }
}
