import 'dart:async';

import 'package:http/http.dart' as http;

import '../clients/rest.dart';

/// Extensions on [Future<http.Response>] to allow usage of some methods from
/// [RestResponse] as a shortcut.
extension ResponseFuture on Future<http.Response> {
  static RestResponse _toRest(http.Response response) {
    if (response is RestResponse) {
      return response;
    } else {
      return RestResponse.fromResponse(response);
    }
  }

  Future<R> thenRest<R>(FutureOr<R> Function(RestResponse) onValue) {
    return then((response) => onValue(_toRest(response)));
  }

  /// Returns the deserialized response body by calling
  /// [RestResponse.deserializeBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.deserializeBody<T>}
  Future<T?> data<T>() {
    return thenRest((restResponse) {
      return restResponse.deserializeBody<T>();
    });
  }

  /// Returns the asynchronously deserialized response body by calling
  /// [RestResponse.deserializeBodyAsync] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.deserializeBodyAsync<T>}
  Future<T?> dataAsync<T>() {
    return thenRest((restResponse) {
      return restResponse.deserializeBodyAsync<T>();
    });
  }

  /// Returns the json object decoded from response body by calling
  /// [RestResponse.jsonBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.jsonBody}
  Future<Object?> get jsonBody {
    return thenRest((restResponse) {
      return restResponse.jsonBody;
    });
  }

  /// Returns the json object decoded asynchronously from response body by
  /// calling [RestResponse.jsonBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.jsonBodyAsync}
  Future<Object?> get jsonBodyAsync {
    return thenRest((restResponse) {
      return restResponse.jsonBodyAsync;
    });
  }
}

extension StreamedResponseFuture on Future<http.StreamedResponse> {
  static Future<RestResponse> _toRest(http.StreamedResponse response) {
    return RestResponse.fromStream(response);
  }

  Future<R> thenRest<R>(FutureOr<R> Function(RestResponse) onValue) {
    return then((response) => _toRest(response).then(onValue));
  }

  /// Returns the deserialized response body by calling
  /// [RestResponse.deserializeBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.deserializeBody<T>}
  Future<T?> data<T>() {
    return thenRest((restResponse) {
      return restResponse.deserializeBody<T>();
    });
  }

  /// Returns the asynchronously deserialized response body by calling
  /// [RestResponse.deserializeBodyAsync] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.deserializeBodyAsync<T>}
  Future<T?> dataAsync<T>() {
    return thenRest((restResponse) {
      return restResponse.deserializeBodyAsync<T>();
    });
  }

  /// Returns the json object decoded from response body by calling
  /// [RestResponse.jsonBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.jsonBody}
  Future<Object?> get jsonBody {
    return thenRest((restResponse) {
      return restResponse.jsonBody;
    });
  }

  /// Returns the json object decoded asynchronously from response body by
  /// calling [RestResponse.jsonBody] after converting the response to
  /// [RestResponse].
  ///
  /// {@macro RestResponse.jsonBodyAsync}
  Future<Object?> get jsonBodyAsync {
    return thenRest((restResponse) {
      return restResponse.jsonBodyAsync;
    });
  }
}
