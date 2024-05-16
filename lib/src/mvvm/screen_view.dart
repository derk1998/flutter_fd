import 'package:flutter/material.dart';
import 'package:flutter_fd/src/mvvm/screen_view_model.dart';

abstract class StatelessScreenView<VM extends ScreenViewModel>
    extends StatelessWidget {
  const StatelessScreenView({super.key, required this.viewModel});

  final VM viewModel;
}

abstract class StatefulScreenView<VM extends StatefulScreenViewModel>
    extends StatefulWidget {
  const StatefulScreenView({super.key, required this.viewModel});

  final VM viewModel;
}

abstract class StatefulScreenViewState<V extends StatefulScreenView<VM>,
    VM extends StatefulScreenViewModel> extends State<V> {
  VM get viewModel => widget.viewModel;

  @override
  void initState() {
    widget.viewModel.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}
