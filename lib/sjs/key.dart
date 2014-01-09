part of sjs;

typedef bool KeyValidator(value);

class Key<T> {
  
  final T defaultValue;
  final String name;
  final KeyValidator validate;
  
  Key._(this.name, this.defaultValue, this.validate);
  
  static final Key<bool> CASE_SENSITIVE = new Key._('caseSensitive', true, isBool);
  
  static final Key<Map> FIELDS = new Key._('fields', {},
      (value) => value is Map<String, Field>);
  
  static final Key<String> FORMAT = new Key._('format', [], 
      (value) => value is String || value is List<String>);
  
  static final Key<String> FORMAT_DECLARATION = new Key._('format', {}, 
      (value) => value is Map<String, dynamic>);
  
  static final Key<Map<String, Format>> FORMATS = new Key._('formats', {}, 
      (value) => value is Map<String, Format>);
  
  static final Key<num> MATCH = new Key._('match', null, isString);
  
  static final Key<int> MAX_INT = new Key._('max', null, isInt);
  
  static final Key<num> MAX_NUM = new Key._('max', null, isNum);
  
  static final Key<int> MIN_INT= new Key._('min', null, isInt);
  
  static final Key<num> MIN_NUM = new Key._('min', null, isNum);
  
  static final Key<bool> MULTI_LINE = new Key._('multiLine', false, isBool);
  
  static final Key<String> NAME = new Key._('name', null, isString);
  
  static final Key REQUIRED = new Key._('required', true, isBool);
  
  static final Key TYPE_FORMAT = new Key._('type', 'string', isString);
  
  static final Key TYPE_SCHEMA = new Key._('type', 'object', isString);
  
  static final Key TYPE_TYPE = new Key._('type', 'object', isString);
  
  static final Key TYPES = new Key._('types', const {},
      (value) => value is Map<String, Type>);
}