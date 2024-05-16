import 'dart:async';

import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_fd/flutter_fd.dart';
import 'package:flutter_test/flutter_test.dart';

enum StateId {
  start,
}

class TestFlow extends Flow<StateId> {
  TestFlow() {
    addState(state: FlowState(name: 'start'), stateId: StateId.start);

    setInitialState(StateId.start);
  }

  @override
  String name() {
    return '';
  }
}

class TestApp extends material.StatelessWidget {
  const TestApp({super.key, required this.widget});

  final material.Widget widget;

  @override
  material.Widget build(material.BuildContext context) {
    return material.MaterialApp(
      home: widget,
    );
  }
}

class TestFlowScreenViewModel extends FlowScreenViewModel {
  TestFlowScreenViewModel(super.flow,
      {this.onInit, this.onDispose, this.onPopped});

  void Function()? onInit;
  void Function()? onDispose;
  void Function()? onPopped;

  @override
  void init() {
    super.init();
    onInit?.call();
  }

  @override
  void onPopInvoked() {
    onPopped?.call();
    super.onPopInvoked();
  }

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
}

void main() {
  testWidgets('Verify if view model init is called when initializing',
      (tester) async {
    bool onInitCalled = false;
    final completer = Completer<void>();
    final viewModel = TestFlowScreenViewModel(
      TestFlow(),
      onInit: () {
        onInitCalled = true;
        completer.complete();
      },
    );
    final view = FlowScreen(viewModel: viewModel);
    final app = TestApp(widget: view);

    await tester.pumpWidget(app);
    await completer.future;

    expect(onInitCalled, true);
  });

  testWidgets('Verify if view model dispose is called when disposing',
      (tester) async {
    bool onDisposeCalled = false;
    final completer = Completer<void>();
    final viewModel = TestFlowScreenViewModel(
      TestFlow(),
      onDispose: () {
        onDisposeCalled = true;
        completer.complete();
      },
    );
    final view = FlowScreen(viewModel: viewModel);
    final app = TestApp(widget: view);

    await tester.pumpWidget(app);
    await tester.pumpWidget(const TestApp(widget: widgets.Placeholder()));
    await completer.future;

    expect(onDisposeCalled, true);
  });

  testWidgets('Verify if view model pop invoked is called when popped',
      (tester) async {
    bool onPopped = false;
    final completer = Completer<void>();
    final viewModel = TestFlowScreenViewModel(
      TestFlow(),
      onPopped: () {
        onPopped = true;
        completer.complete();
      },
    );
    final view = FlowScreen(viewModel: viewModel);
    final app = TestApp(widget: view);

    await tester.pumpWidget(app);

    final dynamic widgetsAppState =
        tester.state(find.byType(material.WidgetsApp));
    await widgetsAppState.didPopRoute();
    await tester.pump();

    await completer.future;

    expect(onPopped, true);
  });
}
