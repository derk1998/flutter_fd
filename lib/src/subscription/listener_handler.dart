import 'dart:async';

import 'context.dart';
import 'contextual_object.dart';
import 'listener.dart';
import 'weak_key.dart';
import 'package:rxdart/rxdart.dart';

class ListenerHandler<T extends Object> extends ContextualObject {
  Subject<T>? _subject;
  void Function({required T data, required void Function(T) callback})?
      _onUpdate;
  void Function()? _onInactive;
  void Function()? _onActive;
  final bool _retainLastPublishedValue;
  final bool _removeListenerWhenExpires;
  final bool _synchronous;
  bool _clearingResources = false;

  final Map<WeakKey<Context>, StreamSubscription<T>> _subscriptions = {};

  ListenerHandler(
      {required void Function(
              {required T data, required void Function(T) callback})
          onUpdate,
      Function()? onActive,
      Function()? onInactive,
      required bool retainLastPublishedValue,
      required bool removeListenerWhenExpires,
      bool synchronous = false})
      : _onUpdate = onUpdate,
        _onActive = onActive,
        _onInactive = onInactive,
        _retainLastPublishedValue = retainLastPublishedValue,
        _removeListenerWhenExpires = removeListenerWhenExpires,
        _synchronous = synchronous;

  void publish(T data) {
    _createSubject();

    _subject?.add(data);
  }

  void _createSubject() {
    if (_retainLastPublishedValue) {
      _subject ??= BehaviorSubject(
          onCancel: _onCancel, onListen: _onListen, sync: _synchronous);
    } else {
      _subject ??= PublishSubject(
          onCancel: _onCancel, onListen: _onListen, sync: _synchronous);
    }
  }

  void addListener(Listener<void Function(T)> listener) {
    _createSubject();

    final context = listener.getContext();
    if (context.target != null) {
      if (_removeListenerWhenExpires) {
        context.target!.addExpiringListener(Listener((ctx) {
          removeListener(ctx);
        }, this));
      }

      final callback = listener.lock();
      _subscriptions[WeakKey(context)]?.cancel();
      _subscriptions[WeakKey(context)] = _subject!.listen((object) {
        _onUpdate!.call(data: object, callback: callback!);
      });
      listener.dispose();
    }
  }

  void _onCancel() {
    _onInactive?.call();
    _clearResources();
  }

  void _onListen() {
    _onActive?.call();
  }

  void removeListener(WeakReference<Context> context) {
    _subscriptions[WeakKey(context)]?.cancel();
    _subscriptions.remove(WeakKey(context));
  }

  void _clearResources() {
    //When the last subscription is canceled, it will trigger this method.
    //There is no need to perform a clear twice, so it will be ignored.
    if (!_clearingResources) {
      _clearingResources = true;

      for (final subscription in _subscriptions.values) {
        subscription.cancel();
      }

      _subscriptions.clear();
      _subject?.close();
      _subject = null;

      _clearingResources = false;
    }
  }

  @override
  void dispose() {
    _clearResources();
    _onUpdate = null;
    _onActive = null;
    _onInactive = null;

    super.dispose();
  }
}
