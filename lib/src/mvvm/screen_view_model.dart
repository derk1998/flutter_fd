import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class ScreenViewModel {
  String getTitle();
}

abstract class StatefulScreenViewModel extends ScreenViewModel {
  @mustCallSuper
  void init();

  @mustCallSuper
  void dispose();
}

abstract class DataScreenViewModel<S> extends StatefulScreenViewModel {
  late BehaviorSubject<S> _stateSubject;
  Stream<S> get state => _stateSubject;

  DataScreenViewModel() {
    _stateSubject = BehaviorSubject<S>();
  }

  @override
  void init() {
    publish(getEmptyState());
  }

  @protected
  S getEmptyState();

  @override
  void dispose() {
    _stateSubject.close();
  }

  @protected
  void publish(S state) {
    _stateSubject.add(state);
  }

  @protected
  S getLastPublishedValue() {
    return _stateSubject.value;
  }
}
