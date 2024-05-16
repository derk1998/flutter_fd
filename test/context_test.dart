import 'dart:async';

import 'package:flutter_fd/src/subscription/context.dart';
import 'package:flutter_fd/src/subscription/listener.dart';
import 'package:test/test.dart';

void main() {
  test('Verify if expiring listener is triggered when disposed', () async {
    Context ctx = Context();
    final completer = Completer<void>();
    Context? capturedContext;

    Context listenerCtx = Context();
    final listener = Listener.context((WeakReference<Context> ctx) {
      capturedContext = ctx.target;
      completer.complete();
    }, listenerCtx);

    ctx.addExpiringListener(listener);
    ctx.dispose();
    await completer.future;

    expect(capturedContext, ctx);
  });
}
