import 'context.dart';
import 'contextual_object.dart';

class Listener<T extends Object> extends IContextualObject {
  Listener(T listener, IContextualObject contextualObject)
      : _listener = WeakReference(listener),
        _context = contextualObject.getContext();

  Listener.context(T listener, Context context)
      : _listener = WeakReference(listener),
        _context = WeakReference(context);

  final WeakReference<T> _listener;
  final WeakReference<Context> _context;

  T? lock() {
    if (_context.target != null) {
      return _listener.target;
    }

    return null;
  }

  @override
  WeakReference<Context> getContext() {
    return _context;
  }
}
