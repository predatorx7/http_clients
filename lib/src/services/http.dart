import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../clients/wrapper.dart';

typedef WrapperClientBuilder = http.Client Function(http.Client client);

class HttpServiceConfig {
  final http.Client client;
  final WrapperClientBuilder? builder;

  const HttpServiceConfig(
    this.client,
    this.builder,
  );
}

class HttpServiceException implements Exception {
  final String message;

  const HttpServiceException(this.message);

  @override
  String toString() {
    return 'HttpServiceException: $message';
  }
}

/// A service that uses [client] for making requests. It is recommend to extend
/// this class and add your method and use the [client] to make requests in the
/// methods to the server.
///
/// {@category Configuration}
/// {@category Get started}
/// {@category Services}
class HttpService<T extends http.Client> {
  /// Creates an http server class that uses [client] in its method to make http
  /// requests.
  ///
  /// The [builder] can be used to wrap [client] with wrapper http [http.Client]s.
  HttpService(
    http.Client client,
    WrapperClientBuilder? builder,
  ) : config = HttpServiceConfig(
          client,
          builder,
        );

  HttpService.fromConfig(this.config);

  @protected
  final HttpServiceConfig config;

  T? _innerClient;

  T get client {
    var client = _innerClient;
    client ??= _buildClient();
    return client;
  }

  T _buildClient() {
    final client = buildClient(config);
    _innerClient = client;
    return client;
  }

  @protected
  T buildClient(HttpServiceConfig config) {
    final builder = config.builder;
    final client = config.client;
    if (builder != null) {
      final builtClient = builder(client);
      if (builtClient is! T) {
        throw HttpServiceException(
          'The client built with `builder` should be of type `$T`',
        );
      }
      return builtClient;
    } else {
      final builtClient = client;
      if (builtClient is! T) {
        throw HttpServiceException(
          'The client should be of type `$T`',
        );
      }
      return builtClient;
    }
  }

  @mustCallSuper

  /// Closes the service and cleans up any resources associated with it.
  /// It is important to call dispose() to release any resources that are being
  /// used by this REST service, such as the HTTP client.
  ///
  /// If [keepHttpClientAlive] is set to true, the original HTTP client will be
  /// kept alive after calling dispose(). This can be useful if you are still
  /// using the same client and don't want to close it. However, it is important
  /// to note that keeping the HTTP client alive can consume resources, so you
  /// should only do this if necessary.
  void dispose({
    bool keepHttpClientAlive = false,
  }) {
    final currentClient = client;
    if (keepHttpClientAlive && currentClient == config.client) return;
    if (currentClient is WrapperClient) {
      return currentClient.close(
        force: true,
        keepAliveHttpClient: keepHttpClientAlive ? config.client : null,
      );
    } else {
      return currentClient.close();
    }
  }
}
