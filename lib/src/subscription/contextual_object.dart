import 'context.dart';
import 'disposable.dart';

abstract class IContextualObject {
  WeakReference<Context> getContext();
}

class ContextualObject implements IContextualObject, Disposable {
  Context? _context;

  @override
  WeakReference<Context> getContext() {
    _context ??= Context();
    return WeakReference(_context!);
  }

  @override
  void dispose() {
    _context?.dispose();
    _context = null;
  }
}
