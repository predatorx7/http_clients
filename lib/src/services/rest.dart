import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../clients/rest.dart';
import '../serializer/json.dart';
import 'http.dart';

class RestServiceConfig extends HttpServiceConfig {
  /// {@macro RestClient.serializer}
  final JsonModelSerializer? serializer;

  const RestServiceConfig(
    http.Client client,
    WrapperClientBuilder? builder,
    this.serializer,
  ) : super(client, builder);
}

/// A service that can be used to make requests to a JSON Api. It wraps the
/// [client] with [RestClient] if necessary to return a [RestResponse]. It is
/// recommended to extend this class and add your methods to it where you use
/// [client] to make requests.
class RestService extends HttpService<RestClient> {
  RestService(
    http.Client client, {
    JsonModelSerializer? serializer,
    WrapperClientBuilder? builder,
  }) : super.fromConfig(
          RestServiceConfig(
            client,
            builder,
            serializer,
          ),
        );

  RestService.fromConfig(RestServiceConfig config) : super.fromConfig(config);

  RestServiceConfig get config => super.config as RestServiceConfig;

  @override
  @protected
  RestClient buildClient(
    covariant RestServiceConfig config,
  ) {
    final builder = config.builder;
    final client = builder != null ? builder(config.client) : config.client;
    final serializer = config.serializer;
    if (client is RestClient) {
      if (serializer != null) {
        final updatedSerializer = serializer.merge(client.serializer);
        client.serializer = updatedSerializer;
      }
      return client;
    }
    return RestClient(client, serializer: serializer);
  }
}
