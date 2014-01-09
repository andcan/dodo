part of sjs;

class SjsType extends Object with HasType {
  
  /**
   * [Map] containing fields
   */
  final Map<String, Field> fields;
  
  SjsType(this.fields, String type) {
    this.type = type;
  }
  
  int get hashCode => Util.hash([fields]);
  
  operator == (SjsType t) => fields == t.fields;
}