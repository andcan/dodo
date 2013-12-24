part of entities;

class Key extends Entity<String> {
  Key.empty ();
  Key ({String id, int length, String path}) :    
    _id = id, _length = length, _path = path;
  factory Key.fromMap (Map<String, dynamic> map) {
    return new Key(id: map['id'], length: map['length'], path: map['path']);
  }
  
  String _id;
  int _length;
  String _path;
  
  List asArray () => [_id, _length, _path];
  
  bool _validate (Persistable persistable, value) => persistable.validate(value);
  
  Symbol get idFieldName => _SYMBOL_ID;
  
  String get id => _id;
  int get length => _length;
  String get path => _path;
  int get hashCode {
    final int p = 37;
    int hash = 1;
    hash = p * hash + _id.hashCode;
    hash = p * hash + _length.hashCode;
    hash = p * hash + _path.hashCode;
    return hash;
  }
  
  set id (String id) {
    if (_PERSISTABLE_ID.validate(id)) {
      _id = id;
      propertyChanged(_SYMBOL_ID);
    } else {
      throw new ArgumentError ('id is not valid');
    }
  }
  set length (int length) {
    if (_PERSISTABLE_LENGTH.validate(length)) {
      _length = length;
      propertyChanged(_SYMBOL_LENGTH);
    } else {
      throw new ArgumentError ('length is not valid');
    }
  }
  set path (String path) {
    if (_PERSISTABLE_PATH.validate(path)) {
      _path = path;
      propertyChanged(_SYMBOL_PATH);
    } else {
      throw new ArgumentError ('path is not valid');
    }
  }
  bool operator == (Key e) => e.id == _id && e.length == _length && e.path == _path;
  static const String _SQL = 'CREATE TABLE Key (id VARCHAR(256) NOT NULL, length INT NOT NULL, path VARCHAR(256) NOT NULL, PRIMARY KEY(id));';
  static const Symbol _SYMBOL_ID = const Symbol ('id'), _SYMBOL_LENGTH = const Symbol ('length'), _SYMBOL_PATH = const Symbol ('path');
  static const Persistable _PERSISTABLE_ID = const StringPersistable (), _PERSISTABLE_LENGTH = const IntPersistable (), _PERSISTABLE_PATH = const StringPersistable ();
}
  