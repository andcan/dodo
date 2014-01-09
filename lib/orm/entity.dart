part of orm;

abstract class Entity<T> {
  
  Optional<StreamController<ContentChangeEvent>> _changeStreamController = 
      new Optional<StreamController<ContentChangeEvent>>.absent();
  ContentChangeEvent _last;
  
  Symbol get idFieldName;
  
  List asArray ();
  
  void propertyChanged (Symbol field) {
    if (_changeStreamController == null) {
      throw new StateError('invalid stream');
    } else if (_changeStreamController.isNotNull) {
      if (_last == null) {
        _last = new ContentChangeEvent(this, field);
        _changeStreamController.value.add(_last);
      } else {
        if (_last.sinked) {
          _last = new ContentChangeEvent(this, field);
          _changeStreamController.value.add(_last);
        } /*else {
          //Nothing to do: object already need to be updated, update operations will be executed once
        }*/
      }
    } /*else {
      //Nothing to do: object must be persisted first
    }*/
  }
}