part of entities;

class Key extends Entity<String> {
  Key.empty ();
  Key ({String id, List<int> path}) :    
    _id = id, _path = path;
  factory Key.fromMap (Map<String, dynamic> map) {
    return new Key(id: map['id'], path: map['path']);
  }
  
  String _id;
  List<int> _path;
  
  List asArray () => [_id, _path];
  
  bool _validate (Persistable persistable, value) => persistable.validate(value);
  
  Symbol get idFieldName => _SYMBOL_ID;
  
  String get id => _id;
  List<int> get path => _path;
  int get hashCode {
    final int p = 37;
    int hash = 1;
    hash = p * hash + _id.hashCode;
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
  set path (List<int> path) {
    if (_PERSISTABLE_PATH.validate(path)) {
      _path = path;
      propertyChanged(_SYMBOL_PATH);
    } else {
      throw new ArgumentError ('path is not valid');
    }
  }
  bool operator == (Key e) => e.id == _id && e.path == _path;
  static const String _SQL = 'CREATE TABLE Key (id VARCHAR(256) NOT NULL, path null NOT NULL, PRIMARY KEY(id));';
  static const Symbol _SYMBOL_ID = const Symbol ('id'), _SYMBOL_PATH = const Symbol ('path');
  static const Persistable _PERSISTABLE_ID = const StringPersistable (), _PERSISTABLE_PATH = const Persistable ();
}
  