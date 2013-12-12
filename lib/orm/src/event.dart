part of orm;

class Event {
  bool _sinked = false;
  
  bool get sinked => _sinked;
  
  void sink () {
    _sinked = true; 
  }
}

class ContentChangeEvent<T> extends Event {
  final T entity;
  final Symbol field;
  
  ContentChangeEvent(this.entity, this.field);
}