part of sjs;

const String PARAM_KEY_NAME = r'${key_name}';
const String PARAM_MAP = r'${map}';
const String PARAM_TYPE_EXPECTED = r'${expected_type}';
const String PARAM_TYPE_WRONG = r'${wrong_type}';
const String PARAM_VAR_NAME = r'${var_name}';

const String ERROR_KEY_ABSENT = 'key ${PARAM_KEY_NAME} is missing from ${PARAM_MAP}';
const String ERROR_KEY_IS_NOT_STRING = 'All keys in ${PARAM_MAP} must be String';
const String ERROR_WRONG_TYPE = '${PARAM_VAR_NAME} is ${PARAM_TYPE_WRONG} expected ${PARAM_TYPE_EXPECTED}';

Map<String, dynamic> parse (Map parse, List<Key> keys) {
  var map = new Map<String, dynamic> ();
  if (parse.keys.every(isString)) {
    keys.forEach((Key key) {
      if (parse.containsKey(key.name)) {
        var value = parse[key.name];
        map[key.name] = key.validate(value) ?
            value : 
              throw new ArgumentError(ERROR_WRONG_TYPE
              .replaceFirst(PARAM_VAR_NAME, key.name)
              .replaceFirst(PARAM_TYPE_WRONG,
                MirrorSystem.getName(reflect(parse).type.qualifiedName))
              .replaceFirst(PARAM_TYPE_EXPECTED, 'other'));
      } else {
        map[key.name] = key.defaultValue;
      }
    });
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
      .replaceFirst(PARAM_MAP, parse.toString()));
  }
  return map;
}

Field parseField (Map properties, Map<String, Format> formats) {
  if (properties.keys.every(isString)) {
    Map values = parse(properties, 
        [Key.FORMAT, Key.MAX_NUM, Key.MIN_NUM, Key.REQUIRED, Key.TYPE_SCHEMA]);
    
    List<String> fieldFormat = values[Key.FORMAT.name] is String ? [values[Key.FORMAT.name]] : values['format'];
    var found = formats.keys.where((key) => fieldFormat.contains(key));
    
    List<Format> fs = [];
    found.forEach((value) => fs.add(formats[value]));
    
    return new Field(fs, values[Key.MAX_NUM.name], values[Key.MIN_NUM.name],
        values[Key.REQUIRED.name], values[Key.TYPE_SCHEMA.name]);
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, 'properties'));
  }
}

Format parseFormat (Map properties) {
  if (properties.keys.every(isString)) {
    Map values = parse(properties, 
        [Key.CASE_SENSITIVE, Key.MATCH, Key.MULTI_LINE]);
    return new StringFormat (new RegExp(values[Key.MATCH.name], 
        multiLine: values[Key.MULTI_LINE.name], 
        caseSensitive: values[Key.CASE_SENSITIVE.name]));
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, 'properties'));
  }
}

Map<String, Format> parseFormats (Map formats) {
  if (formats.keys.every(isString)) {
    Map<String, Format> fmts = new Map<String, Format> ();
    
    formats.forEach((String name, format) {
      if (format is Map) {
        if (format.keys.every(isString)) {
          fmts[name] = parseFormat(format);
        } else {
          throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
            .replaceFirst(PARAM_MAP, 'format'));
        }
      } else {
        throw new ArgumentError(ERROR_WRONG_TYPE
          .replaceFirst(PARAM_VAR_NAME, format)
          .replaceFirst(PARAM_TYPE_WRONG,
            MirrorSystem.getName(reflect(format).type.qualifiedName))
          .replaceFirst(PARAM_TYPE_EXPECTED, 'map'));
      }
    });
    return fmts;
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, Key.FORMATS.name));
  }
}

Map<String, Field> parseFields (Map fields, Map<String, Format> formats) {
  Map<String, Field> fs = new Map<String, Field> ();
  
  if (fields.keys.every(isString)) {
    fields.forEach((String name, properties) {
      fs[name] = parseField(properties, formats);
    });
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, Key.FIELDS.name));
  }
  return fs;
}

SjsType parseType (Map<String, dynamic> properties, Map<String, Format> formats) {
    Map values = parse(properties, 
        [Key.FIELDS, Key.TYPE_SCHEMA]);
    properties[Key.FIELDS.name] = parseFields(properties[Key.FIELDS.name], formats);
    
    return new SjsType(values[Key.FIELDS.name], values[Key.TYPE_SCHEMA.name]);
}

Map<String, SjsType> parseTypes(Map types, Map<String, Format> formats) {
  Map<String, SjsType> ts = new Map<String, SjsType> ();
  
  if (types.keys.every(isString)) {
    types.forEach((String name, properties) {
      if (properties is Map) {
        if (properties.keys.every(isString)) {
          ts[name] = parseType(properties, formats);
        } else {
          throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
            .replaceFirst(PARAM_MAP, 'properties'));
        }
      } else {
        throw new ArgumentError(ERROR_WRONG_TYPE
          .replaceFirst(PARAM_VAR_NAME, properties)
          .replaceFirst(PARAM_TYPE_WRONG,
            MirrorSystem.getName(reflect(properties).type.qualifiedName))
          .replaceFirst(PARAM_TYPE_EXPECTED, 'map'));
      }
    });
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, Key.TYPES.name));
  }
  return ts;
}

/*
Map<String, Format> parseFormats (Map formats) {
  Map<String, Format> fmts = new Map<String, Format> ();
  
  if (formats.keys.every(isString)) {
    formats.forEach((String name, properties) {
      if (properties is Map) {
        if (properties.keys.every(isString)) {
          if (properties.containsKey(Key.FORMAT.name)) {
            var format = properties[Key.FORMAT.name];
            if (format is String) {
              if (properties.containsKey(Key.CASE_SENSITIVE.name)) {
                var caseSensitive = properties[Key.CASE_SENSITIVE.name];
                if (caseSensitive == null) {
                  caseSensitive = Key.CASE_SENSITIVE.defaultValues;
                } else if (caseSensitive is! bool) {
                  throw new ArgumentError(ERROR_WRONG_TYPE
                    .replaceFirst(PARAM_VAR_NAME, Key.CASE_SENSITIVE.name)
                    .replaceFirst(PARAM_TYPE_WRONG,
                      MirrorSystem.getName(reflect(caseSensitive).type.qualifiedName))
                    .replaceFirst(PARAM_TYPE_EXPECTED, 'bool'));
                }
                
                var multiLine = properties[Key.MULTI_LINE.name];
                if (multiLine == null) {
                  multiLine = Key.MULTI_LINE.defaultValues;
                } else if (multiLine is! bool) {
                  throw new ArgumentError(ERROR_WRONG_TYPE
                      .replaceFirst(PARAM_VAR_NAME, Key.MULTI_LINE.name)
                      .replaceFirst(PARAM_TYPE_WRONG,
                        MirrorSystem.getName(reflect(multiLine).type.qualifiedName))
                      .replaceFirst(PARAM_TYPE_EXPECTED, 'bool'));
                }
                
                var type = properties[Key.TYPE.name];
                if (type == null) {
                  type = Key.TYPE.defaultValues;
                } else if (type is! String) {
                  throw new ArgumentError(ERROR_WRONG_TYPE
                      .replaceFirst(PARAM_VAR_NAME, Key.TYPE.name)
                      .replaceFirst(PARAM_TYPE_WRONG,
                        MirrorSystem.getName(reflect(type).type.qualifiedName))
                      .replaceFirst(PARAM_TYPE_EXPECTED, 'string'));
                }
                
                Format f;
                if (type is String) {
                  f = new StringFormat.fromString(format,
                      caseSensitive: caseSensitive, multiLine: multiLine);
                } else {
                  f = new Format(format, null, null, null);
                }
                fmts[name] = f;
              }
            } else {
              throw new ArgumentError(ERROR_WRONG_TYPE
                  .replaceFirst(PARAM_VAR_NAME, Key.FORMAT.name)
                  .replaceFirst(PARAM_TYPE_WRONG,
                    MirrorSystem.getName(reflect(format).type.qualifiedName))
                  .replaceFirst(PARAM_TYPE_EXPECTED, 'string'));
            }
          } else {
            throw new ArgumentError (ERROR_KEY_ABSENT
                .replaceFirst(PARAM_KEY_NAME, Key.FORMAT.name)
                .replaceFirst(PARAM_MAP, 'properties'));
          }
        } else {
          throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
              .replaceFirst(PARAM_MAP, 'properties of $name'));
        }
      } else {
        throw new ArgumentError('Invalid properties');
      }
    });
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, Key.FORMATS.name));
  }
  return fmts;
}

Map<String, SjsType> parseTypes (Map types) {
  Map<String, SjsType> ts = new Map<String, SjsType> ();
  
  if (types.keys.every(isString)) {
    types.forEach((String name, properties) {
      if (properties is Map) {
        if (properties.keys.every(isString)) {
          var fields = properties[Key.FIELDS.name];
          if (fields == null) {
            fields = Key.FIELDS.defaultValues;
          } else {
            if (fields is Map) {
              if (fields.keys.every(isString)) {
                fields.forEach((String name, properties) {
                  if (properties is Map) {
                    //////////
                  }
                });
              } else {
                throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
                    .replaceFirst(PARAM_MAP, Key.FIELDS.name));
              }
            } else {
              throw new ArgumentError(ERROR_WRONG_TYPE
                  .replaceFirst(PARAM_VAR_NAME, Key.FIELDS.name)
                    .replaceFirst(PARAM_TYPE_WRONG,
                        MirrorSystem.getName(reflect(fields).type.qualifiedName))
                          .replaceFirst(PARAM_TYPE_EXPECTED, 'map'));
            }
          }
          
          var type = properties[Key.TYPE.name];
          if (type == null) {
            type = Key.TYPE.defaultValues;
          } else if (type is! String) {
            throw new ArgumentError(ERROR_WRONG_TYPE
                .replaceFirst(PARAM_VAR_NAME, Key.TYPE.name)
                  .replaceFirst(PARAM_TYPE_WRONG,
                      MirrorSystem.getName(reflect(type).type.qualifiedName))
                        .replaceFirst(PARAM_TYPE_EXPECTED, 'string'));
          }
        } else {
          throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
              .replaceFirst(PARAM_MAP, Key.PROPERTIES.name));
        }
      } else {
        throw new ArgumentError(ERROR_WRONG_TYPE
            .replaceFirst(PARAM_VAR_NAME, Key.PROPERTIES.name)
              .replaceFirst(PARAM_TYPE_WRONG,
                  MirrorSystem.getName(reflect(properties).type.qualifiedName))
                    .replaceFirst(PARAM_TYPE_EXPECTED, 'map'));
      }
    });
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING
        .replaceFirst(PARAM_MAP, Key.TYPES.name));
  }
}

Schema parseSchema (Map json) {
  Map<String, Format> formats;
  
  if (json.keys.every(isString)) {
    if (json.containsKey(Key.FORMATS.name)) {
      var fmts = json[Key.FORMATS.name];
      if (fmts == null) {
        formats = Key.FORMATS.defaultValues;
      } else if (fmts is Map) {
        Map<String, Format> formats = parseFormats(fmts);
      } else {
        throw new ArgumentError('Invalid formats');
      }
    }
    if (json.containsKey(Key.TYPES.name)) {
      var types = json[Key.TYPES.name];
      if (types is Map) {
        
      } else {
        throw new ArgumentError(ERROR_WRONG_TYPE
            .replaceFirst(PARAM_VAR_NAME, Key.TYPES.name)
            .replaceFirst(PARAM_TYPE_WRONG,
              MirrorSystem.getName(reflect(types).type.qualifiedName))
            .replaceFirst(PARAM_TYPE_EXPECTED, 'map'));
      }
    }
  } else {
    throw new ArgumentError(ERROR_KEY_IS_NOT_STRING.replaceFirst(PARAM_MAP, 'json'));
  }
}*/