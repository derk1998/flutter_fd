import 'dart:async';

import 'package:flutter_fd/src/subscription/context.dart';
import 'package:flutter_fd/src/subscription/listener.dart';
import 'package:flutter_fd/src/subscription/listener_handler.dart';
import 'package:test/test.dart';

void main() {
  test(
      'Verify if on update listener is triggered when listener is added with retain last published value',
      () async {
    final onUpdatelistenerContext = Context();

    final completer = Completer<void>();
    bool onUpdateListenerCalled = false;
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(({required callback, required data}) {
          onUpdateListenerCalled = true;
          completer.complete();
        }, onUpdatelistenerContext),
        retainLastPublishedValue: true,
        removeListenerWhenExpires: false);

    final listenerContext = Context();
    listenerHandler.publish(1);
    listenerHandler
        .addListener(Listener.context((int data) {}, listenerContext));

    await completer.future;

    expect(onUpdateListenerCalled, isTrue);
  });

  test(
      'Verify if on update listener is triggered when listener is added and data is published',
      () async {
    final onUpdatelistenerContext = Context();

    final completer = Completer<void>();
    bool onUpdateListenerCalled = false;
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(({required callback, required data}) {
          onUpdateListenerCalled = true;
          completer.complete();
        }, onUpdatelistenerContext),
        retainLastPublishedValue: false,
        removeListenerWhenExpires: false);

    final listenerContext = Context();
    listenerHandler
        .addListener(Listener.context((int data) {}, listenerContext));
    listenerHandler.publish(1);

    await completer.future;

    expect(onUpdateListenerCalled, isTrue);
  });

  test('Verify if callback in on update listener is same as in add listener',
      () async {
    final onUpdatelistenerContext = Context();

    final completer = Completer<void>();
    callback(int data) {}
    void Function(int)? capturedCallback;
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(({required callback, required data}) {
          capturedCallback = callback;
          completer.complete();
        }, onUpdatelistenerContext),
        retainLastPublishedValue: true,
        removeListenerWhenExpires: false);

    final listenerContext = Context();
    listenerHandler.publish(1);
    listenerHandler.addListener(Listener.context(callback, listenerContext));

    await completer.future;

    expect(capturedCallback, callback);
  });

  test('Verify if value in on update listener is same as in publish', () async {
    final onUpdatelistenerContext = Context();

    final completer = Completer<void>();
    callback(int data) {}
    int? capturedData;
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(({required callback, required data}) {
          capturedData = data;
          completer.complete();
        }, onUpdatelistenerContext),
        retainLastPublishedValue: true,
        removeListenerWhenExpires: false);

    final listenerContext = Context();
    int originalData = 1;
    listenerHandler.publish(originalData);
    listenerHandler.addListener(Listener.context(callback, listenerContext));

    await completer.future;

    expect(originalData, capturedData);
  });

  test('Verify if on active listener is called when first listener is added',
      () async {
    final onUpdatelistenerContext = Context();

    final onActiveListenerContext = Context();
    bool onActiveListenerCalled = false;
    final completer = Completer<void>();
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(
            ({required callback, required data}) {}, onUpdatelistenerContext),
        onActive: Listener.context(() {
          onActiveListenerCalled = true;
          completer.complete();
        }, onActiveListenerContext),
        retainLastPublishedValue: false,
        removeListenerWhenExpires: false);

    final listenerContext = Context();
    listenerHandler.publish(1);
    listenerHandler
        .addListener(Listener.context((int data) {}, listenerContext));

    await completer.future;

    expect(onActiveListenerCalled, isTrue);
  });

  test('Verify if on inactive listener is called when last listener is removed',
      () async {
    final onUpdatelistenerContext = Context();

    final onInactiveListenerContext = Context();
    bool onInactiveListenerCalled = false;
    final completer = Completer<void>();
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(
            ({required callback, required data}) {}, onUpdatelistenerContext),
        onInactive: Listener.context(() {
          onInactiveListenerCalled = true;
          completer.complete();
        }, onInactiveListenerContext),
        retainLastPublishedValue: false,
        removeListenerWhenExpires: false);

    final listenerContext = Context();
    listenerHandler.publish(1);
    listenerHandler
        .addListener(Listener.context((int data) {}, listenerContext));
    listenerHandler.removeListener(WeakReference(listenerContext));

    await completer.future;

    expect(onInactiveListenerCalled, isTrue);
  });

  test(
      'Verify if on inactive listener is called when last listener is expired and remove listener when expires',
      () async {
    final onUpdatelistenerContext = Context();

    final onInactiveListenerContext = Context();
    bool onInactiveListenerCalled = false;
    final completer = Completer<void>();
    final listenerHandler = ListenerHandler<int>(
        onUpdate: Listener.context(
            ({required callback, required data}) {}, onUpdatelistenerContext),
        onInactive: Listener.context(() {
          onInactiveListenerCalled = true;
          completer.complete();
        }, onInactiveListenerContext),
        retainLastPublishedValue: false,
        removeListenerWhenExpires: true);

    final listenerContext = Context();
    listenerHandler.publish(1);
    listenerHandler
        .addListener(Listener.context((int data) {}, listenerContext));
    listenerContext.dispose();
    await completer.future;

    expect(onInactiveListenerCalled, isTrue);
  });
}
