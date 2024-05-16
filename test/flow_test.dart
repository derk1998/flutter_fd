import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:test/test.dart';

enum StateId {
  start,
  stop,
}

enum Event {
  onEntryStartState,
  onExitStartState,
  onEntryStopState,
  onExitStopState,
}

class TestFlow extends Flow<StateId> {
  TestFlow({super.onCompleted, super.onCanceled});

  void add({required FlowState state, required StateId stateId}) {
    addState(state: state, stateId: stateId);
  }

  void setStartState(StateId stateId) {
    setInitialState(stateId);
  }

  void set(StateId stateId) {
    setState(stateId);
  }

  void cancelFlow() {
    cancel();
  }

  void completeFlow() {
    complete();
  }

  @override
  String name() {
    return '';
  }
}

void main() {
  test('Verify if on entry initial state is called when initializing',
      () async {
    final flow = TestFlow();

    bool onEntryStartStateCalled = false;
    final completer = Completer<void>();
    final startState = FlowState(
      name: 'start',
      onEntry: () {
        onEntryStartStateCalled = true;
        completer.complete();
      },
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();

    await completer.future;

    expect(onEntryStartStateCalled, isTrue);
  });

  test('Verify if on exit current state is called when disposing', () async {
    final flow = TestFlow();

    bool onExitStartStateCalled = false;
    final completer = Completer<void>();
    final startState = FlowState(
      name: 'start',
      onExit: () {
        onExitStartStateCalled = true;
        completer.complete();
      },
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();
    flow.dispose();

    await completer.future;

    expect(onExitStartStateCalled, isTrue);
  });

  test('Verify if on exit current state is called when canceled', () async {
    final flow = TestFlow();

    bool onExitStartStateCalled = false;
    final completer = Completer<void>();
    final startState = FlowState(
      name: 'start',
      onExit: () {
        onExitStartStateCalled = true;
        completer.complete();
      },
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();
    flow.cancelFlow();

    await completer.future;

    expect(onExitStartStateCalled, isTrue);
  });

  test('Verify if on exit current state is called when completed', () async {
    final flow = TestFlow();

    bool onExitStartStateCalled = false;
    final completer = Completer<void>();
    final startState = FlowState(
      name: 'start',
      onExit: () {
        onExitStartStateCalled = true;
        completer.complete();
      },
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();
    flow.completeFlow();

    await completer.future;

    expect(onExitStartStateCalled, isTrue);
  });

  test('Verify if on onCancel is called when canceled', () async {
    bool onCancelCalled = false;
    final completer = Completer<void>();

    final flow = TestFlow(
      onCanceled: () async {
        onCancelCalled = true;
        completer.complete();
      },
    );

    final startState = FlowState(
      name: 'start',
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();
    flow.cancelFlow();

    await completer.future;

    expect(onCancelCalled, isTrue);
  });

  test('Verify if on onCancel is called when popped', () async {
    bool onCancelCalled = false;
    final completer = Completer<void>();

    final flow = TestFlow(
      onCanceled: () async {
        onCancelCalled = true;
        completer.complete();
      },
    );

    final startState = FlowState(
      name: 'start',
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();
    flow.onPopInvoked();

    await completer.future;

    expect(onCancelCalled, isTrue);
  });

  test('Verify if on onComplete is called when completed', () async {
    bool onCompleteCalled = false;
    final completer = Completer<void>();

    final flow = TestFlow(
      onCompleted: () async {
        onCompleteCalled = true;
        completer.complete();
      },
    );

    final startState = FlowState(
      name: 'start',
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.setStartState(StateId.start);

    flow.init();
    flow.completeFlow();

    await completer.future;

    expect(onCompleteCalled, isTrue);
  });

  test('Verify if on exit current state is called when next state is set',
      () async {
    final flow = TestFlow();

    bool onExitStartStateCalled = false;
    final completer = Completer<void>();
    final startState = FlowState(
      name: 'start',
      onExit: () {
        onExitStartStateCalled = true;
        completer.complete();
      },
    );

    final stopState = FlowState(
      name: 'stop',
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.add(state: stopState, stateId: StateId.stop);

    flow.setStartState(StateId.start);

    flow.init();
    flow.set(StateId.stop);

    await completer.future;

    expect(onExitStartStateCalled, isTrue);
  });

  test('Verify if on entry next state is called when next state is set',
      () async {
    final flow = TestFlow();

    bool onEntryStopStateCalled = false;
    final completer = Completer<void>();
    final startState = FlowState(
      name: 'start',
    );

    final stopState = FlowState(
      name: 'stop',
      onEntry: () {
        onEntryStopStateCalled = true;
        completer.complete();
      },
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.add(state: stopState, stateId: StateId.stop);

    flow.setStartState(StateId.start);

    flow.init();
    flow.set(StateId.stop);

    await completer.future;

    expect(onEntryStopStateCalled, isTrue);
  });

  test('Verify if on entry is called before on exit', () async {
    final completer = Completer<void>();
    final flow = TestFlow(
      onCompleted: () async {
        completer.complete();
      },
    );

    final List<Event> events = [];

    final startState = FlowState(
      name: 'start',
      onEntry: () {
        events.add(Event.onEntryStartState);
      },
      onExit: () {
        events.add(Event.onExitStartState);
      },
    );

    final stopState = FlowState(
      name: 'stop',
      onEntry: () {
        events.add(Event.onEntryStopState);
      },
      onExit: () {
        events.add(Event.onExitStopState);
      },
    );

    flow.add(state: startState, stateId: StateId.start);
    flow.add(state: stopState, stateId: StateId.stop);

    flow.setStartState(StateId.start);

    flow.init();
    flow.set(StateId.stop);
    flow.completeFlow();

    await completer.future;

    expect(events.length, 4);

    expect(events[0], Event.onEntryStartState);
    expect(events[1], Event.onExitStartState);
    expect(events[2], Event.onEntryStopState);
    expect(events[3], Event.onExitStopState);
  });

  test('Verify if view is reset when loading', () async {
    final flow = TestFlow();

    final startState = FlowState(
      name: 'start',
    );

    flow.add(state: startState, stateId: StateId.start);

    flow.setStartState(StateId.start);

    flow.init();
    flow.loading();

    final viewState = await flow.viewChangeSubject.first;

    expect(viewState, null);
  });
}
