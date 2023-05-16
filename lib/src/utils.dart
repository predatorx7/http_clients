import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

bool isNullOrBlank(String? value) {
  return value == null ||
      value.isEmpty ||
      value.replaceAll(RegExp(r'\s+'), '').isEmpty;
}

String? whereStringNotBlankElseNull(Iterable<String> strings) {
  for (final it in strings) {
    if (!isNullOrBlank(it)) return it;
  }
  return null;
}

Map<T, V>? mergeMapIfNotEmptyElseNull<T, V>(Iterable<Map<T, V>> lists) {
  final Map<T, V> items = {};
  for (final list in lists) {
    if (list.isNotEmpty) {
      items.addAll(list);
    }
  }

  if (items.isNotEmpty) return items;
  return null;
}

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
    throw ArgumentError('Invalid request body of type "${body.runtimeType}". Body must be a json supported object/');
  }
}

Future<R> runInIsolate<R>(
  FutureOr<R> Function() computation, {
  String? debugName,
}) {
  var result = Completer<R>();
  var resultPort = RawReceivePort();
  resultPort.handler = (response) {
    resultPort.close();
    if (response == null) {
      // onExit handler message, isolate terminated without sending result.
      result.completeError(RemoteError("Computation ended without result", ""),
          StackTrace.empty);
      return;
    }
    var list = response as List<Object?>;
    if (list.length == 2) {
      var remoteError = list[0];
      var remoteStack = list[1];
      if (remoteStack is StackTrace) {
        // Typed error.
        result.completeError(remoteError!, remoteStack);
      } else {
        // onError handler message, uncaught async error.
        // Both values are strings, so calling `toString` is efficient.
        var error = RemoteError(remoteError.toString(), remoteStack.toString());
        result.completeError(error, error.stackTrace);
      }
    } else {
      assert(list.length == 1);
      result.complete(list[0] as R);
    }
  };
  try {
    Isolate.spawn(_RemoteRunner._remoteExecute,
            _RemoteRunner<R>(computation, resultPort.sendPort),
            onError: resultPort.sendPort,
            onExit: resultPort.sendPort,
            errorsAreFatal: true,
            debugName: debugName)
        .then<void>((_) {}, onError: (error, stack) {
      // Sending the computation failed asynchronously.
      // Do not expect a response, report the error asynchronously.
      resultPort.close();
      result.completeError(error, stack);
    });
  } on Object {
    // Sending the computation failed synchronously.
    // This is not expected to happen, but if it does,
    // the synchronous error is respected and rethrown synchronously.
    resultPort.close();
    rethrow;
  }
  return result.future;
}

// ignore: sdk_version_since
/// Parameter object used by [Isolate.run] and [runInIsolate].
///
/// The [_remoteExecute] function is run in a new isolate with a
/// [_RemoteRunner] object as argument.
class _RemoteRunner<R> {
  /// User computation to run.
  final FutureOr<R> Function() computation;

  /// Port to send isolate computation result on.
  ///
  /// Only one object is ever sent on this port.
  /// If the value is `null`, it is sent by the isolate's "on-exit" handler
  /// when the isolate terminates without otherwise sending value.
  /// If the value is a list with one element,
  /// then it is the result value of the computation.
  /// Otherwise it is a list with two elements representing an error.
  /// If the error is sent by the isolate's "on-error" uncaught error handler,
  /// then the list contains two strings. This also terminates the isolate.
  /// If sent manually by this class, after capturing the error,
  /// the list contains one non-`null` [Object] and one [StackTrace].
  final SendPort resultPort;

  _RemoteRunner(this.computation, this.resultPort);

  /// Run in a new isolate to get the result of [computation].
  ///
  /// The result is sent back on [resultPort] as a single-element list.
  /// A two-element list sent on the same port is an error result.
  /// When sent by this function, it's always an object and a [StackTrace].
  /// (The same port listens on uncaught errors from the isolate, which
  /// sends two-element lists containing [String]s instead).
  static void _remoteExecute(_RemoteRunner<Object?> runner) {
    runner._run();
  }

  void _run() async {
    R result;
    try {
      var potentiallyAsyncResult = computation();
      if (potentiallyAsyncResult is Future<R>) {
        result = await potentiallyAsyncResult;
      } else {
        result = potentiallyAsyncResult;
      }
    } catch (e, s) {
      // If sending fails, the error becomes an uncaught error.
      Isolate.exit(resultPort, _list2(e, s));
    }
    Isolate.exit(resultPort, _list1(result));
  }

  /// Helper function to create a one-element non-growable list.
  static List<Object?> _list1(Object? value) => List.filled(1, value);

  /// Helper function to create a two-element non-growable list.
  static List<Object?> _list2(Object? value1, Object? value2) =>
      List.filled(2, value1)..[1] = value2;
}
