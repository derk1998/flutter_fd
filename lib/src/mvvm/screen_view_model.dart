import 'package:rxdart/rxdart.dart';

abstract class ScreenViewModel {
  String getTitle();
}

abstract class StatefulScreenViewModel extends ScreenViewModel {
  void init();
  void dispose();
}

abstract class DataScreenViewModel<S> extends StatefulScreenViewModel {
  final _stateSubject = BehaviorSubject<S>();
  Stream<S> get state => _stateSubject;

  @override
  void init() {
    publish(getEmptyState());
  }

  S getEmptyState();

  @override
  void dispose() {
    _stateSubject.close();
  }

  void publish(S state) {
    _stateSubject.add(state);
  }

  S getLastPublishedValue() {
    return _stateSubject.value;
  }
}
