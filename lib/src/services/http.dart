import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../clients/wrapper.dart';
import '../serializer/json.dart';

typedef WrapperClientBuilder = http.Client Function(http.Client client);

class ServiceConfig {
  final http.Client client;
  final JsonModelSerializer? serializer;
  final WrapperClientBuilder? builder;

  const ServiceConfig(
    this.client,
    this.serializer,
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

class HttpService<T extends http.Client> {
  HttpService(
    http.Client client,
    JsonModelSerializer? serializer,
    WrapperClientBuilder? builder,
  ) : config = ServiceConfig(
          client,
          serializer,
          builder,
        );

  HttpService.fromConfig(this.config);

  @protected
  final ServiceConfig config;

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
  T buildClient(ServiceConfig config) {
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
