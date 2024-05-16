import 'dart:async';

import 'package:flutter_fd/src/subscription/context.dart';
import 'package:flutter_fd/src/subscription/contextual_object.dart';
import 'package:flutter_fd/src/subscription/listener.dart';
import 'package:test/test.dart';

void main() {
  test('Verify if get context points to contextual object', () async {
    final contextualObject = ContextualObject();

    final listener = Listener(() {}, contextualObject);

    expect(contextualObject.getContext().target, listener.getContext().target);
  });

  test('Verify if get context points to context', () async {
    final context = Context();

    final listener = Listener.context(() {}, context);

    expect(context, listener.getContext().target);
  });

  test('Verify if callback is called when listener is called', () async {
    final context = Context();

    bool listenerCalled = false;
    final completer = Completer<void>();
    final listener = Listener.context(() {
      listenerCalled = true;
      completer.complete();
    }, context);

    listener.lock()!.call();

    await completer.future;
    expect(listenerCalled, isTrue);
  });
}
