part of orm;

class Optional<T> {
  final T value;
  
  Optional (this.value);
  
  Optional.absent() :
    value = null;
  
  bool get isAbsent => value == null; 
  
  bool get isNotNull => value != null;
}