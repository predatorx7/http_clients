import 'package:http/http.dart' as http;

import '../clients/rest.dart';

RestResponse _toRest(http.Response response) {
  if (response is RestResponse) {
    return response;
  } else {
    return RestResponse.fromResponse(response);
  }
}

extension ResponseFuture on Future<http.Response> {
  /// Returns [T] by deserializing the response body to it.
  /// The response is deserialized synchronously.
  ///
  /// For large response body, try [deserializeBodyAsync].
  Future<T?> data<T>() {
    return then((response) {
      return _toRest(response).deserializeBody<T>();
    });
  }

  /// Returns [T] by deserializing the response body to it.
  /// The response is deserialized asynchronously in an isolate.
  ///
  /// For small response body, try [deserializeBody].
  Future<T?> dataAsync<T>() {
    return then((response) {
      return _toRest(response).deserializeBodyAsync<T>();
    });
  }
}
