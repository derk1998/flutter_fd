import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:test/test.dart';

void main() {
  test('Verify if onEntry is called when entry is called', () async {
    bool onEntryCalled = false;
    final completer = Completer<void>();
    final state = FlowState(
      name: '',
      onEntry: () {
        onEntryCalled = true;
        completer.complete();
      },
    );

    state.entry();

    await completer.future;

    expect(onEntryCalled, isTrue);
  });

  test('Verify if onExit is called when exit is called', () async {
    bool onExitCalled = false;
    final completer = Completer<void>();
    final state = FlowState(
      name: '',
      onExit: () {
        onExitCalled = true;
        completer.complete();
      },
    );

    state.exit();

    await completer.future;

    expect(onExitCalled, isTrue);
  });
}
