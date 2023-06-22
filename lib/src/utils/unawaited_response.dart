import 'dart:async';

import 'package:http/http.dart';

/// Make sure the response stream is listened to so that we don't leave
/// dangling connections.
void unawaitedResponse(StreamedResponse response) {
  return unawaited(response.stream.listen((_) {}).cancel().catchError((_) {}));
}
