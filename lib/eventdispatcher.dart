part of compass;

class EventDispatcher<T> extends Stream<T> {
  dynamic _trigger;
  List<_EventSubscription> _subscriptions = [];
  bool _dispatched = false;
  T _data;
  
  EventDispatcher(trigger) {
    _trigger = trigger;
  }

  StreamSubscription<T> listen(onData, {void onError(error), void onDone(), bool cancelOnError:false}) {
      var subscription = new _EventSubscription<T>(this, onData);
      _subscriptions.add(subscription);
      return subscription;
  }
  
  StreamSubscription<T> then(onData) {
    var subscription = listen(onData);
    if(_dispatched)
      subscription._invoke(_trigger, _data);
    return subscription;
  }
  
  void once(onData) {
    (then(onData) as _EventSubscription)._once = true;
  }
  
  cancelSubscription(_EventSubscription<T> eventSubscription) {
    if (eventSubscription._canceled) return;
    var subscriptions = [];
    for(var i = 0; i < _subscriptions.length; i++) {
      var subscription = _subscriptions[i];
      if (identical(subscription, eventSubscription)) {
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
        if(?data)
          subscription._invoke(_trigger, data);
        else
          subscription._invoke(_trigger);
      }
    }
  }
}










