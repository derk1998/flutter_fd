import 'dart:developer';

class FlowState {
  FlowState(
      {required String name, void Function()? onEntry, void Function()? onExit})
      : _name = name,
        _onEntry = onEntry,
        _onExit = onExit;

  final String _name;
  final void Function()? _onEntry;
  final void Function()? _onExit;

  void entry() {
    log('$_name -> entry()');
    _onEntry?.call();
  }

  void exit() {
    log('$_name -> exit()');
    _onExit?.call();
  }
}
