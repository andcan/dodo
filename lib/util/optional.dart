part of util;

class Optional<T> {
  final bool _absent;
  final T value;
  
  Optional(this.value) :
    _absent = false;
  
  Optional.absent() :
    _absent = true,
    value = null;
  
  bool get isAbsent => _absent;
  
  bool get isNotAbsent => ! _absent;
}