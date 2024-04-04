import 'package:http/http.dart' as http;
import '../clients/request.dart';
import '../clients/rest.dart';
import '../serializer/json.dart';
import 'http.dart';

class RestServiceConfig extends HttpServiceConfig<RestClient> {
  /// {@macro RestClient.serializer}
  final JsonModelSerializer? serializer;

  RestServiceConfig(
    http.Client client,
    WrapperClientBuilder? builder,
    this.serializer,
  ) : super(client, _builderWithProxy(builder, serializer));

  static WrapperClientBuilder<RestClient> _builderWithProxy(
    WrapperClientBuilder? proxyBuilder,
    JsonModelSerializer? configSerializer,
  ) {
    return (parentClient) {
      final builder = proxyBuilder;
      final client = builder != null ? builder(parentClient) : parentClient;
      final serializer = configSerializer;
      if (client is RestClient) {
        if (serializer != null) {
          final updatedSerializer = serializer.merge(client.serializer);
          client.serializer = updatedSerializer;
        }
        return client;
      }
      return RestClient(client, serializer: serializer);
    };
  }
}

/// A service that can be used to make requests to a JSON Api. It wraps the
/// [client] with [RestClient] if necessary to return a [RestResponse]. It is
/// recommended to extend this class and add your methods to it where you use
/// [client] to make requests.
///
/// {@category Configuration}
/// {@category Get started}
/// {@category Services}
class RestService extends HttpService<RestClient> {
  RestService(
    http.Client client, {
    JsonModelSerializer? serializer,
    WrapperClientBuilder? builder,
    bool includeJsonContentTypeHeader = true,
  }) : super.fromConfig(
          RestServiceConfig(
            RequestClient(
              client,
              headers: includeJsonContentTypeHeader
                  ? {'content-type': 'application/json; charset=utf-8'}
                  : null,
              updateHeaderIf: (requestHeaders, header) {
                if (header.key == 'content-type') return true;
                return updateHeaderIfAbsent(requestHeaders, header);
              },
            ),
            builder,
            serializer,
          ),
        );

  RestService.fromConfig(RestServiceConfig super.config) : super.fromConfig();

  @override
  RestServiceConfig get config => super.config as RestServiceConfig;
}
