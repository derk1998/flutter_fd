import 'context.dart';
import 'contextual_object.dart';
import 'disposable.dart';
import 'listener.dart';
import 'listener_handler.dart';

class ConditionalObject<T extends Disposable> extends ContextualObject {
  ConditionalObject(this._creator, {this.dependencies});

  ListenerHandler<WeakReference<T>>? _listenerHandler;
  List<ConditionalObject<dynamic>>? dependencies;
  List<WeakReference<dynamic>>? _objects;
  final T Function(List<dynamic>? dependencies) _creator;
  T? _object;

  bool _areDependenciesRetrieved() {
    return _objects!.length == dependencies!.length;
  }

  void _createObject() {
    _object = _creator(_objects);
    _listenerHandler!.publish(WeakReference(_object!));
  }

  void addListener(Listener<void Function(WeakReference<T>)> listener) {
    _listenerHandler ??= ListenerHandler<WeakReference<T>>(
      onUpdate: Listener(({required callback, required data}) {
        if (data.target != null) {
          callback.call(data);
        }
      }, this),
      onActive: Listener(() {
        if (dependencies != null) {
          _objects = [];
          for (final dependency in dependencies!) {
            dependency.addListener(Listener((object) {
              _objects!.add(object);
              if (_areDependenciesRetrieved()) {
                _createObject();
              }
            }, this));
          }
        } else {
          _createObject();
        }
      }, this),
      onInactive: Listener(() {
        _listenerHandler = null;
        _object!.dispose();
        _object = null;
        _objects?.clear();
      }, this),
      retainLastPublishedValue: true,
      removeListenerWhenExpires: true,
    );

    _listenerHandler!.addListener(listener);
  }

  void removeListener(WeakReference<Context> context) {
    _listenerHandler?.removeListener(context);

    if (dependencies != null) {
      for (final dependency in dependencies!) {
        dependency.removeListener(context);
      }
    }
  }
}
