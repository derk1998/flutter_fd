import 'package:flutter/material.dart';
import 'package:flutter_fd/src/flow/flow_view_model.dart';
import 'package:flutter_fd/src/mvvm/screen_view.dart';

class FlowScreen extends StatefulScreenView<FlowScreenViewModel> {
  const FlowScreen({super.key, required super.viewModel});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState
    extends StatefulScreenViewState<FlowScreen, FlowScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        viewModel.onPopInvoked();
      },
      child: StreamBuilder<FlowScreenState>(
        stream: viewModel.state,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.hasData ? snapshot.data!.title : ''),
            ),
            body: !snapshot.hasData || snapshot.data!.view == null
                ? const Center(child: CircularProgressIndicator())
                : snapshot.data!.view,
          );
        },
      ),
    );
  }
}
