import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/failure.dart';

class NotifierState<T> {
  T? value;
  Failure? failure;
  RequestState state;

  NotifierState({
    this.value,
    this.failure,
    this.state = RequestState.initial,
  });

  bool stateSuccess() {
    return state == RequestState.success;
  }

  bool stateError() {
    return state == RequestState.error;
  }

  bool stateLoading() {
    return state == RequestState.loading;
  }

  bool stateInitial() {
    return state == RequestState.initial;
  }

  void setLoading() {
    state = RequestState.loading;
  }

  void setSuccess({T? value}) {
    if (value != null) this.value = value;
    state = RequestState.success;
  }

  void setError({Failure? failure}) {
    this.failure = failure;
    state = RequestState.error;
  }

  void setInitial() {
    state = RequestState.initial;
  }

  void reset() {
    state = RequestState.initial;
    failure = null;
    value = null;
  }
}
