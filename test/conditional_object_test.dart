import 'dart:async';

import 'package:flutter_fd/src/subscription/context.dart';
import 'package:flutter_fd/src/subscription/contextual_object.dart';
import 'package:flutter_fd/src/subscription/listener.dart';
import 'package:test/test.dart';

void main() {
  test('Verify if context is expiring when disposing', () async {
    final contextualObject = ContextualObject();
    final contextualObjectContext = contextualObject.getContext();

    final completer = Completer<void>();
    final listenerContext = Context();
    bool expiringListenerCalled = false;
    contextualObjectContext.target!
        .addExpiringListener(Listener.context((WeakReference<Context> ctx) {
      expiringListenerCalled = true;
      completer.complete();
    }, listenerContext));

    contextualObject.dispose();

    await completer.future;

    expect(expiringListenerCalled, isTrue);
  });
}
