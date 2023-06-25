import 'dart:async';
import 'dart:isolate';

const bool _kIsWeb = bool.fromEnvironment('dart.library.js_util');

FutureOr<R> compute<R>(FutureOr<R> computation(), {String? debugName}) {
  if (_kIsWeb) {
    return computation();
  }
  return Isolate.run(computation, debugName: debugName);
}
