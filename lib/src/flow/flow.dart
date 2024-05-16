import 'dart:developer';

import 'package:fd_dart/fd_dart.dart';
import 'package:flutter_fd/src/flow/flow_state.dart';
import 'package:flutter_fd/src/mvvm/screen.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

enum FlowStatus {
  canceled,
  completed,
  idle,
}

abstract class Flow<ID> extends ContextualObject {
  final viewChangeSubject = BehaviorSubject<Screen?>();
  final Map<ID, FlowState> _states = {};
  late FlowState _currentState;
  final Future<void> Function()? _onCompleted;
  final Future<void> Function()? _onCanceled;
  FlowStatus _status = FlowStatus.idle;

  Flow(
      {Future<void> Function()? onCompleted,
      Future<void> Function()? onCanceled})
      : _onCompleted = onCompleted,
        _onCanceled = onCanceled;

  String name();

  @mustCallSuper
  void init() {
    log('${name()} init');
    _currentState.entry();
  }

  @override
  void dispose() {
    if (_status == FlowStatus.idle) {
      cancel();
    }

    viewChangeSubject.close();
    log('${name()} dispose');
    super.dispose();
  }

  @protected
  void addState({required FlowState state, required ID stateId}) {
    _states[stateId] = state;
  }

  void loading() {
    viewChangeSubject.add(null);
  }

  @protected
  void complete() {
    if (_status == FlowStatus.idle) {
      _status = FlowStatus.completed;
      _currentState.exit();
      log('${name()} is completed');
      _onCompleted?.call();
    } else {
      log('${name()} cannot be completed because it is already completed or canceled');
    }
  }

  @protected
  bool isCurrentState(ID state) {
    return _states[state] == _currentState;
  }

  @protected
  void cancel() {
    if (_status == FlowStatus.idle) {
      _status = FlowStatus.canceled;
      _currentState.exit();
      log('${name()} is canceled');
      _onCanceled?.call();
    } else {
      log('${name()} cannot be canceled because it is already completed or canceled');
    }
  }

  void onPopInvoked() {
    cancel();
  }

  @protected
  void setInitialState(ID stateId) {
    _currentState = _states[stateId]!;
  }

  @protected
  void setState(ID stateId) {
    _currentState.exit();
    _currentState = _states[stateId]!;
    _currentState.entry();
  }
}
