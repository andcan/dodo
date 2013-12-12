part of orm;

abstract class Entity<T> {
  
  Optional<StreamController<ContentChangeEvent>> changeStreamController = 
      new Optional<StreamController<ContentChangeEvent>>.absent();
  ContentChangeEvent _last;
  
  Symbol get idFieldName;
  
  void propertyChanged (Symbol field) {
    if (changeStreamController == null) {
      throw new StateError('invalid stream');
    } else if (changeStreamController.isNotNull) {
      if (_last == null) {
        _last = new ContentChangeEvent(this, field);
        changeStreamController.value.add(_last);
      } else {
        if (_last.sinked) {
          _last = new ContentChangeEvent(this, field);
          changeStreamController.value.add(_last);
        } /*else {
          //Nothing to do: object already need to be updated, update operations will be executed once
        }*/
      }
    } /*else {
      //Nothing to do: object must be persisted first
    }*/
  }
}