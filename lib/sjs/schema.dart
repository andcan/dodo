part of sjs;

class Schema {
  /**
   * [Map] containing fields
   */
  final Map<String, Field> fields;
  /**
   * name of this [Schema]
   */
  final String name;
  /**
   * [Map] containing formats
   */
  final Map<String, Format> formats;
  /**
   * type of this [Schema]
   */
  final String type;
  /**
   * [Map] containing types
   */
  final Map<String, SjsType> types;
  
  Schema (this.fields, this.name, this.formats, this.type, this.types);
  
  factory Schema.fromMap (Map schema) {
    var fmts;
    if (!schema.containsKey(Key.FORMATS.name)) {
      fmts = Key.FORMATS.defaultValue;
    } else {
      fmts = schema[Key.FORMATS.name];
    }
    Map<String, Format> formats = parseFormats(fmts);
    
    var fs;
    if (!schema.containsKey(Key.FIELDS.name)) {
      fs = Key.FIELDS.defaultValue;
    } else {
      fs = schema[Key.FIELDS.name];
    }
    Map<String, Field> fields = parseFields(fs, formats);
    
    var name;
    if (!schema.containsKey(Key.NAME.name)) {
      name = Key.NAME.defaultValue;
    } else {
      name = schema[Key.NAME.name];
    }
    
    var type;
    if (!schema.containsKey(Key.TYPE_SCHEMA.name)) {
      type = Key.TYPE_SCHEMA.defaultValue;
    } else {
      type = schema[Key.TYPE_SCHEMA.name];
    }
    
    var ts;
    if (!schema.containsKey(Key.TYPES.name)) {
      ts = Key.TYPES.defaultValue;
    } else {
      ts = schema[Key.TYPES.name];
    }
    Map<String, SjsType> types = parseTypes(ts, formats);
    return new Schema(fields, name, formats, type, types);
  }
  
  bool validate (Map json) {
    var names = fields.keys;
    for (String name in names) {
      var field = fields[name];
      
      if (! json.containsKey(name)) {
        return ! field.required;
      } else {
        if (! _validate(json[name], field.type)) {
          return false;
        }
      }
    }
    return true;
  }
  
  bool _validate (value, String type) {
    if (null == value) {
      return false;
    }
    
    bool valid = true;
    var conversionError = (value) {
      valid = false;
      return -1;
    };
    
    switch (type) {
      case 'int':
        if (value is! int) {
          if (value is! String) {
            valid = false;
          } else {
            int.parse(value, onError: conversionError);
          }
        }
        break;
      case 'num':
        if (value is! int) {
          if (value is! String) {
            valid = false;
          } else {
            double.parse(value, conversionError);
          }
        }
        break;
      case 'string':
        if (value is! String) {
          valid = false;
        }
        break;
      case 'object':
        if (value is! Map) {
          valid = false;
        }
        break;
      default:
        if (LIST.hasMatch(type)) {
          Match m = LIST.firstMatch(type);
          if (value is! List) {
            return false;
          } else {
            if (! value.every((test) => _validate(test, m.group(1)))) {
              return false;
            }
          }
        }
        if (! types.containsKey(type)) {
          valid = false;
        } else {
          valid = _validateObject(value, types[type]);
        }
        break;
    }
    return valid;
  }
  
  bool _validateObject (Map value, SjsType type) {
    var fields = type.fields;
    var names = fields.keys;
    for (String name in names) {
      Field field = fields[name];
      if (field.required) {
        if (!value.containsKey(name)) {
          return false;
        } else {
          if (! _validate(value[name], field.type)) {
            return false;
          }
        }
      }
    }
    return true;
  }
  
  static final RegExp LIST = new RegExp(r'\b(\w+)\b\[\]', multiLine: false, caseSensitive: true);
}