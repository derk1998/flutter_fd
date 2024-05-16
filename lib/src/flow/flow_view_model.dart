import 'dart:async';

import 'package:flutter/material.dart' as material;
import 'package:flutter_fd/src/flow/flow.dart';
import 'package:flutter_fd/src/mvvm/screen.dart';
import 'package:flutter_fd/src/mvvm/screen_view_model.dart';

class FlowScreenState {
  FlowScreenState({required this.title, this.view});

  String title;
  material.Widget? view;
}

class FlowScreenViewModel extends DataScreenViewModel<FlowScreenState> {
  FlowScreenViewModel(this._flow);

  final Flow _flow;
  StreamSubscription<Screen?>? _viewChangeSubscription;

  void _onViewChanged(Screen? screen) {
    if (screen == null) {
      final value = getLastPublishedValue();
      publish(value..view = null);
    } else {
      publish(FlowScreenState(
          title: screen.viewModel.getTitle(), view: screen.view));
    }
  }

  @override
  void init() {
    super.init();
    _flow.init();
    _viewChangeSubscription = _flow.viewChangeSubject.listen(_onViewChanged);
  }

  void onPopInvoked() {
    _flow.onPopInvoked();
  }

  @override
  void dispose() {
    _viewChangeSubscription!.cancel();
    _flow.dispose();
    super.dispose();
  }

  @override
  String getTitle() {
    return '';
  }

  @override
  FlowScreenState getEmptyState() {
    return FlowScreenState(title: '');
  }
}
