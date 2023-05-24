import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../clients/rest.dart';
import '../serializer/json.dart';
import 'http.dart';

class RestService extends HttpService<RestClient> {
  RestService(
    http.Client client, {
    JsonModelSerializer? serializer,
    WrapperClientBuilder? builder,
  }) : super(client, serializer, builder);

  RestService.fromConfig(ServiceConfig config) : super.fromConfig(config);

  @override
  @protected
  RestClient buildClient(
    ServiceConfig config,
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
