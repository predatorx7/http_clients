import 'package:http/http.dart' as http;

import '../clients/rest.dart';

RestResponse _toRest(http.Response response) {
  if (response is RestResponse) {
    return response;
  } else {
    return RestResponse.fromResponse(response);
  }
}

/// Extensions on [Future<http.Response>] to allow usage of some methods from
/// [RestResponse] as a shortcut.
extension ResponseFuture on Future<http.Response> {
  /// Returns the deserialized response body by calling
  /// [RestResponse.deserializeBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.deserializeBody<T>}
  Future<T?> data<T>() {
    return then((response) {
      return _toRest(response).deserializeBody<T>();
    });
  }

  /// Returns the asynchronously deserialized response body by calling
  /// [RestResponse.deserializeBodyAsync] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.deserializeBodyAsync<T>}
  Future<T?> dataAsync<T>() {
    return then((response) {
      return _toRest(response).deserializeBodyAsync<T>();
    });
  }

  /// Returns the json object decoded from response body by calling
  /// [RestResponse.jsonBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.jsonBody}
  Future<Object?> get jsonBody {
    return then((response) {
      return _toRest(response).jsonBody;
    });
  }

  /// Returns the json object decoded asynchronously from response body by
  /// calling [RestResponse.jsonBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.jsonBodyAsync}
  Future<Object?> get jsonBodyAsync {
    return then((response) {
      return _toRest(response).jsonBodyAsync;
    });
  }
}
