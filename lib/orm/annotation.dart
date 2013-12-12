part of orm;

/**
 * Mixin for [IntField] and [IntId]
 */
abstract class _IntPersistable implements Persistable<num> {
  
  bool validate (int value) => value >= min && value <= max;
}

/**
 * Mixin for [NumField] and [NumId]
 */
abstract class _NumPersistable implements Persistable<num> {
  
  bool validate (num value) => value >= min && value <= max;
}

/**
 * Mixin for [StringField] and [StringId]
 */
abstract class _StringPersistable implements Persistable<String> {
  
  bool validate (String value) {
    int length = value.length;
    return length >= min && length <= max;
  }
}

/**
 * Base annotation class. All annotations used to mark fields implement and/or extend this class.
 * Provides an implementation for objects that implement [Comparable]
 */
class Persistable<T> {
  final String name;
  final num max;
  final num min;
  
  const Persistable ({this.name: null, this.max, this.min});
  
  bool validate (Comparable<T> value) {
    return min.compareTo(value) <= 0 && value.compareTo(max) <= 0;
  }
}

/**
 * Annotation for [int] fields
 */
class IntField extends Persistable<num> with _IntPersistable {
  const IntField ({String name, num max, num min}) :
    super (name: name, max: max, min: min);
}

/**
 * Annotation for [num] fields
 */
class NumField extends Persistable<num> with _NumPersistable {
  const NumField ({String name, num max, num min}) :
    super (name: name, max: max, min: min);
}

/**
 * Annotation for [String] fields
 */
class StringField extends Persistable<String> with _StringPersistable {
  final RegExp match;
  
  const StringField ({String name, num max, num min, this.match}) :
    super (name: name, max: max, min: min);
}

/**
 * Base id class. All id annotations used to mark ids implement and/or extend this class.
 * Provides an implementation for objects that implement [Comparable]
 */
class Id<T> extends Persistable<T> {
  const Id({String name: null, num max: null, num min: null}) :
    super (name: name, max: max, min: min);
}

/**
 * Annotation for [int] ids
 */
class IntId extends Id<num> with _IntPersistable {
  
  const IntId ({String name, num max, num min}) :
    super (name: name, max: max, min: min);
}

/**
 * Annotation for [num] ids
 */
class NumId extends Id<num> with _NumPersistable {
  
  const NumId ({String name, num max, num min}) :
    super (name: name, max: max, min: min);
}

/**
 * Annotation for [String] ids
 */
class StringId extends Id<String> with _StringPersistable {
  final RegExp match;
  
  const StringId ({String name, num max, num min, this.match}) :
    super (name: name, max: max, min: min);
}