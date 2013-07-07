part of compass;

class _EventSubscription<T> extends StreamSubscription<T> {
  int _pauseCount = 0;
  bool _canceled = false;
  bool _once = false;
  
  EventDispatcher<T> _eventStream;
  Function _onData;
  _EventSubscription(this._eventStream, this._onData);

  void _invoke(trigger, [T data]) {
    if(?data)
      _onData(trigger, data);
    else
      _onData(trigger);
    if(_once){
      _canceled = true;
      cancel();
    }
  }

  void onData(void handleData(T data)) {
    _onData = handleData;
  }

  void cancel() {
    _eventStream.cancelSubscription(this);
  }

  void pause([Future resumeSignal]) {
    _pauseCount++;
    if (resumeSignal != null) {
      resumeSignal.whenComplete(resume);
    }
  }

  void resume()  {
    if (_pauseCount == 0) {
      throw new StateError("Subscription is not paused.");
    }
    _pauseCount--;
  }
  
  bool get isPaused => _pauseCount > 0;

  void onError(void handleError(error)) { }
  void onDone(void handleDone()) { }
  Future asFuture([var futureValue]) => null;
}