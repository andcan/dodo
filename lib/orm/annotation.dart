part of orm;

/**
 * Mixin for [IntPersistable] and [IntId]
 */
abstract class _IntPersistable implements Persistable<num> {
  
  bool validate (int value) {
    if (value == null) {
      return nullable;
    }
    value >= min && value <= max;
  }
}

/**
 * Mixin for [NumPersistable] and [NumId]
 */
abstract class _NumPersistable implements Persistable<num> {
  
  bool validate (num value) {
    if (value == null) {
      return nullable;
    }
    value >= min && value <= max;
  }
}

/**
 * Mixin for [StringPersistable] and [StringId]
 */
abstract class _StringPersistable implements Persistable<String> {
  
  bool validate (String value) {
    if (value == null) {
      return nullable;
    }
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
  final bool nullable;
  
  const Persistable ({this.name: null, this.max, this.min, bool nullable: true}) :
    this.nullable = nullable;
  
  bool validate (Comparable<T> value) {
    if (value == null) {
      return nullable;
    }
    return min.compareTo(value) <= 0 && value.compareTo(max) <= 0;
  }
}

/**
 * Annotation for [int] fields
 */
class IntPersistable extends Persistable<num> {
  const IntPersistable ({String name, num max, num min, bool nullable: true}) :
    super (name: name, max: max, min: min, nullable: nullable);
  
  bool validate (int value) {
    if (value == null) {
      return nullable;
    }
    value >= min && value <= max;
  }
}

/**
 * Annotation for [num] fields
 */
class NumPersistable extends Persistable<num> {
  const NumPersistable ({String name, num max, num min, bool nullable: true}) :
    super (name: name, max: max, min: min, nullable: nullable);
  
  bool validate (num value) {
    if (value == null) {
      return nullable;
    }
    value >= min && value <= max;
  }
}

/**
 * Annotation for [String] fields
 */
class StringPersistable extends Persistable<String> {
  final String match;
  
  const StringPersistable ({String name, num max, num min, bool nullable: true, this.match}) :
    super (name: name, max: max, min: min, nullable: nullable);
  
  bool validate (String value) {
    if (value == null) {
      return nullable;
    }
    int length = value.length;
    return length >= min && length <= max;
  }
}

/**
 * Base id class. All id annotations used to mark ids implement and/or extend this class.
 * Provides an implementation for objects that implement [Comparable]
 */
class Id<T> extends Persistable<T> {
  const Id({String name: null, num max: null, num min: null}) :
    super (name: name, max: max, min: min, nullable: false);
}

/**
 * Annotation for [int] ids
 */
class IntId extends Id<num> {
  
  const IntId ({String name, num max, num min}) :
    super (name: name, max: max, min: min);
  
  bool validate (int value) {
    if (value == null) {
      return nullable;
    }
    value >= min && value <= max;
  }
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
class StringId extends Id<String> {
  final RegExp match;
  
  const StringId ({String name, num max, num min, this.match}) :
    super (name: name, max: max, min: min);
  
  bool validate (String value) {
    if (value == null) {
      return nullable;
    }
    int length = value.length;
    return length >= min && length <= max;
  }
}