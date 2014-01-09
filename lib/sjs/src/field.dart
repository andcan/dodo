part of sjs;

class Field extends SchemaEntity with HasType {
  /**
   * [Format] of this [Field].
   */
  final List<Format> format;
  /**
   * Max value for this field.
   */
  final int max;
  /**
   * Min value for this field.
   */
  final int min;
  /**
   * [:true:] if this [Field] is required
   */
  final bool required;
  
  Field (this.format, this.max, this.min, this.required, String type) {
    this.type = type;
  }
  
  int get hashCode {
    return Util.hash([format, max, min, required]);
  }
  
  String toString () =>
      '{\n\tformat: $format,\n\tmax: $max,\n\tmin: $min,\n\trequired: $required\n}';
  
  operator == (Field f) => 
      (format.isNotEmpty
          && format.length == f.format.length 
          && format.every((fmt) => f.format.contains(fmt))) 
        || (format.isEmpty && f.format.isEmpty)
      && max == f.max && min == f.min && required == f.required;
}