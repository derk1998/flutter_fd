import 'context.dart';
import 'contextual_object.dart';
import 'disposable.dart';

class Listener<T extends Object> implements IContextualObject, Disposable {
  Listener(T listener, IContextualObject contextualObject)
      : _listener = listener,
        _context = contextualObject.getContext();

  Listener.context(T listener, Context context)
      : _listener = listener,
        _context = WeakReference(context);

  T? _listener;
  final WeakReference<Context> _context;

  T? lock() {
    if (_context.target != null) {
      return _listener;
    }

    return null;
  }

  @override
  WeakReference<Context> getContext() {
    return _context;
  }

  @override
  void dispose() {
    _listener = null;
  }
}
