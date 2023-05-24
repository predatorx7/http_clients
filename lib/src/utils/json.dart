import 'dart:convert';

Object? tryDecodeJson(String source) {
  if (source.isEmpty) return null;
  try {
    return json.decode(source);
  } catch (_) {
    return null;
  }
}

Object? processForHttpBody(Object? body) {
  if (body == null) return null;
  if (body is String) {
    return body;
  }
  try {
    try {
      if (body is List) {
        if (body is List<int>) return body;
        final bodyT = body.cast<int>();
        // Test casting by iterating over all elements.
        for (var _ in bodyT) {}
        return bodyT;
      } else if (body is Map) {
        if (body is Map<String, String>) return body;
        final bodyT = body.cast<String, String>();
        // Test casting by iterating over all entries.
        bodyT.forEach((k, v) => false);
        return bodyT;
      }
      // Could be a json supported object
      // We'll try json encode out of this try-catch block.

      // ignore: deprecated_member_use
    } on TypeError {
      // .cast() or List or Map failed.
    }
    return json.encode(body);
  } on JsonUnsupportedObjectError {
    throw ArgumentError(
      'Invalid request body of type "${body.runtimeType}". Body must be a json supported object/',
    );
  }
}
