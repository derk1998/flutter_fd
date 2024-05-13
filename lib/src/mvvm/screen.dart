import 'package:flutter/material.dart';
import 'package:flutter_fd/src/mvvm/screen_view_model.dart';

class Screen {
  Screen({required this.view, required this.viewModel});

  Widget view;
  ScreenViewModel viewModel;
}
