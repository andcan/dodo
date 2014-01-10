part of sjs;

class SjsType extends Object with HasType {
  
  /**
   * [Map] containing fields
   */
  final Map<String, Field> fields;
  
  SjsType(this.fields, String type) {
    this.type = type;
  }
  
  int get hashCode => fields.hashCode;
  
  operator == (SjsType t) => fields == t.fields;
}