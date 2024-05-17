import 'dart:async';

import 'context.dart';
import 'disposable.dart';
import 'listener.dart';
import 'weak_key.dart';
import 'package:rxdart/rxdart.dart';

class ListenerHandler<T extends Object> extends Disposable {
  Subject<T>? _subject;
  final Listener<
          void Function({required T data, required void Function(T) callback})>
      _onUpdate;
  final Listener<void Function()>? _onInactive;
  final Listener<void Function()>? _onActive;
  final bool _retainLastPublishedValue;
  final bool _removeListenerWhenExpires;

  final Map<WeakKey<Context>, StreamSubscription<T>> _listeners = {};

  ListenerHandler(
      {required Listener<
              void Function(
                  {required T data, required void Function(T) callback})>
          onUpdate,
      Listener<void Function()>? onActive,
      Listener<void Function()>? onInactive,
      required bool retainLastPublishedValue,
      required bool removeListenerWhenExpires})
      : _onUpdate = onUpdate,
        _onActive = onActive,
        _onInactive = onInactive,
        _retainLastPublishedValue = retainLastPublishedValue,
        _removeListenerWhenExpires = removeListenerWhenExpires;

  void publish(T data) {
    _createSubject();

    _subject?.add(data);
  }

  void _createSubject() {
    if (_retainLastPublishedValue) {
      _subject ??= BehaviorSubject(onCancel: _onCancel, onListen: _onListen);
    } else {
      _subject ??= PublishSubject(onCancel: _onCancel, onListen: _onListen);
    }
  }

  void addListener(Listener<void Function(T)> listener) {
    _createSubject();

    final context = listener.getContext();
    if (context.target != null) {
      if (_removeListenerWhenExpires) {
        context.target!.addExpiringListener(Listener((ctx) {
          removeListener(ctx);
        }, listener));
      }

      final callback = listener.lock();
      _listeners[WeakKey(context)] = _subject!.listen((object) {
        _onUpdate.lock()?.call(data: object, callback: callback!);
      });
    }
  }

  void _onCancel() {
    _onInactive?.lock()?.call();
    _clearResources();
  }

  void _onListen() {
    _onActive?.lock()?.call();
  }

  void removeListener(WeakReference<Context> context) {
    _listeners[WeakKey(context)]?.cancel();
    _listeners.remove(WeakKey(context));
  }

  void _clearResources() {
    _subject?.close();
    _subject = null;
    _listeners.clear();
  }

  @override
  void dispose() {
    _clearResources();
    _onActive?.dispose();
    _onInactive?.dispose();
  }
}
