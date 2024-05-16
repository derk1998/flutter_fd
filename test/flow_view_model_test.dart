import 'dart:async';

import 'package:flutter/material.dart' as material;
import 'package:flutter_fd/flutter_fd.dart';
import 'package:test/test.dart';

enum StateId {
  start,
}

class TestFlow extends Flow<StateId> {
  void Function()? onInit;
  void Function()? onDispose;
  void Function()? onPopped;

  TestFlow({this.onInit, this.onDispose, this.onPopped}) {
    addState(state: FlowState(name: 'start'), stateId: StateId.start);

    setInitialState(StateId.start);
  }

  @override
  void init() {
    super.init();
    onInit?.call();
  }

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }

  @override
  void onPopInvoked() {
    super.onPopInvoked();
    onPopped?.call();
  }

  @override
  String name() {
    return '';
  }
}

class TestViewModel extends ScreenViewModel {
  final String name;
  TestViewModel(this.name);

  @override
  String getTitle() {
    return name;
  }
}

void main() {
  test('Verify if flow is intialized when initializing', () async {
    bool onInitCalled = false;
    final completer = Completer<void>();
    final flow = TestFlow(
      onInit: () {
        onInitCalled = true;
        completer.complete();
      },
    );

    final viewModel = FlowScreenViewModel(flow);
    viewModel.init();

    await completer.future;

    expect(onInitCalled, isTrue);
  });

  test('Verify if flow is disposed when disposing', () async {
    bool onDisposeCalled = false;
    final completer = Completer<void>();
    final flow = TestFlow(
      onDispose: () {
        onDisposeCalled = true;
        completer.complete();
      },
    );

    final viewModel = FlowScreenViewModel(flow);
    viewModel.init();
    viewModel.dispose();

    await completer.future;

    expect(onDisposeCalled, isTrue);
  });

  test('Verify if flow is popped when pop invoked', () async {
    bool onPopped = false;
    final completer = Completer<void>();
    final flow = TestFlow(
      onPopped: () {
        onPopped = true;
        completer.complete();
      },
    );

    final viewModel = FlowScreenViewModel(flow);
    viewModel.init();
    viewModel.onPopInvoked();

    await completer.future;

    expect(onPopped, isTrue);
  });

  test('Verify if state view is initialized when initializing', () async {
    final flow = TestFlow();

    final flowViewModel = FlowScreenViewModel(flow);
    flowViewModel.init();

    final state = await flowViewModel.state.first;

    expect(state.view, null);
    expect(state.title, '');
  });

  test('Verify if state view updates when flow view change subject changes',
      () async {
    final flow = TestFlow();

    final flowViewModel = FlowScreenViewModel(flow);
    flowViewModel.init();

    var state = await flowViewModel.state.first;

    final viewModel = TestViewModel('');
    final screen = Screen(view: const material.Center(), viewModel: viewModel);
    flow.viewChangeSubject.add(screen);

    state = await flowViewModel.state.firstWhere(
      (element) {
        return element.view == screen.view;
      },
    );

    expect(state.view, screen.view);
  });
}
