import 'dart:developer';

class FlowState {
  FlowState(
      {required String name,
      void Function()? onEntry,
      void Function()? onExit,
      void Function()? onPop})
      : _name = name,
        _onEntry = onEntry,
        _onExit = onExit,
        _onPop = onPop;

  final String _name;
  final void Function()? _onEntry;
  final void Function()? _onExit;
  final void Function()? _onPop;

  void entry() {
    log('$_name -> entry()');
    _onEntry?.call();
  }

  void exit() {
    log('$_name -> exit()');
    _onExit?.call();
  }

  bool pop() {
    if (_onPop == null) return false;

    _onPop.call();
    return true;
  }
}
