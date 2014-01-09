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
    fields.forEach((name, field) {
      if (field.required) {
        if (! json.containsKey(name)) {
          return false;
        } else {
          bool valid = true;
          var conversionError = (value) {
            valid = false;
            return -1;
          };
          String type = field.type;
          var value = json[name];
          if (null == value) {
            return false;
          } else if ('int' == type) {
            if (value is! int) {
              if (value is! String) {
                valid = false;
              } else {
                int.parse(value, onError: conversionError);
              }
            }
          } else if ('num' == type) {
            if (value is! int) {
              if (value is! String) {
                valid = false;
              } else {
                double.parse(value, conversionError);
              }
            }
          } else if ('string' == type) {
            if (value is! String) {
              valid = false;
            }
          } else {
            if (! types.containsKey(type)) {
              valid = false;
            } else {
              var sjsType = types[type];
              var fields = sjsType.fields;
              var names = fields.keys;
              for (String name in names) {
                var field = fields[name];
                if (field.required) {
                  //TODO
                }
              }
            }
          }
          
          if (! valid) {
            return false;
          }
        }
      }
    });
  }
}