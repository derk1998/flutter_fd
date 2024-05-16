import 'disposable.dart';
import 'listener_handler.dart';
import 'listener.dart';

class Context extends Disposable {
  ListenerHandler<WeakReference<Context>>? _listenerHandler;

  void addExpiringListener(
      Listener<void Function(WeakReference<Context>)> listener) {
    _listenerHandler ??= ListenerHandler<WeakReference<Context>>(
      onUpdate: Listener.context(({required callback, required data}) {
        if (data.target != null) {
          callback.call(data);
        }
      }, this),
      onInactive: Listener.context(() {
        _listenerHandler = null;
      }, this),
      retainLastPublishedValue: false,
      removeListenerWhenExpires: false,
    );

    _listenerHandler!.addListener(listener);
  }

  void removeExpiringListener(WeakReference<Context> context) {
    _listenerHandler!.removeListener(context);
  }

  @override
  void dispose() {
    _listenerHandler?.publish(WeakReference(this));
    _listenerHandler?.dispose();
    _listenerHandler = null;
  }
}
