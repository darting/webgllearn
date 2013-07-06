part of compass;

class EventDispatcher<T> extends Stream<T> {
  dynamic _trigger;
  List<_EventStreamSubscription> _subscriptions = [];
  bool _dispatched = false;
  T _data;
  
  EventDispatcher(trigger) {
    _trigger = trigger;
  }

  StreamSubscription<T> listen(onData, {void onError(error), void onDone(), bool cancelOnError:false}) {
      var eventStreamSubscription = new _EventStreamSubscription<T>(this, onData);
      _subscriptions.add(eventStreamSubscription);
      return eventStreamSubscription;
  }
  
  StreamSubscription<T> then(onData) {
    var eventStreamSubscription = listen(onData);
    if(_dispatched) 
      eventStreamSubscription._invoke(_trigger, _data);
    return eventStreamSubscription;
  }
  
  void once(onData) {
    var eventStreamSubscription = listen((t, d) {
      onData(t, d);
      eventStreamSubscription.cancel();
    });
  }
  
  cancelSubscription(_EventStreamSubscription<T> eventStreamSubscription) {
    if (eventStreamSubscription._canceled) return;
    var subscriptions = [];
    for(var i = 0; i < _subscriptions.length; i++) {
      var subscription = _subscriptions[i];
      if (identical(subscription, eventStreamSubscription)) {
        subscription._canceled = true;
      } else {
        subscriptions.add(subscription);
      }
    }
    _subscriptions = subscriptions;
  }
  
  cancelSubscriptions() {
    for(var i = 0; i < _subscriptions.length; i++) {
      var subscription = _subscriptions[i];
      subscription._canceled = true;
    }
    _subscriptions = [];
  }

  dispatch([T data])  {
    _dispatched = true;
    var subscriptions = _subscriptions;
    var subscriptionsLength = _subscriptions.length;
    for(var i = 0; i < subscriptionsLength; i++) {
      var subscription = subscriptions[i];
      if (subscription._canceled == false) {
        subscription._invoke(_trigger, data);
      }
    }
  }
}










