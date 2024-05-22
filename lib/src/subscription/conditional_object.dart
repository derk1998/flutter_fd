import 'context.dart';
import 'disposable.dart';
import 'listener.dart';
import 'listener_handler.dart';

class ConditionalObject<T extends Disposable> {
  ConditionalObject(this._creator,
      {List<ConditionalObject<dynamic>>? dependencies})
      : _dependencies = dependencies;

  ListenerHandler<WeakReference<T>>? _listenerHandler;
  final List<ConditionalObject<dynamic>>? _dependencies;
  List<WeakReference<dynamic>>? _objects;
  final T Function(List<dynamic>? dependencies) _creator;
  T? _object;

  bool _areDependenciesRetrieved() {
    return _objects!.length == _dependencies!.length;
  }

  void _createObject() {
    _object = _creator(_objects);
    _listenerHandler!.publish(WeakReference(_object!));
  }

  void addListener(Listener<void Function(WeakReference<T>)> listener) {
    _listenerHandler ??= ListenerHandler<WeakReference<T>>(
      onUpdate: ({required callback, required data}) {
        if (data.target != null) {
          callback.call(data);
        }
      },
      onActive: () {
        if (_dependencies != null) {
          _objects = [];
          for (final dependency in _dependencies) {
            dependency.addListener(Listener((object) {
              _objects!.add(object);
              if (_areDependenciesRetrieved()) {
                _createObject();
              }
            }, listener));
          }
        } else {
          _createObject();
        }
      },
      onInactive: () {
        _object!.dispose();
        _object = null;
        _objects?.clear();

        _listenerHandler?.dispose();
        _listenerHandler = null;
      },
      retainLastPublishedValue: true,
      removeListenerWhenExpires: true,
    );

    _listenerHandler!.addListener(listener);
  }

  void removeListener(WeakReference<Context> context) {
    _listenerHandler?.removeListener(context);

    if (_dependencies != null) {
      for (final dependency in _dependencies) {
        dependency.removeListener(context);
      }
    }
  }
}
