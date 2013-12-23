part of entities;

class User extends Entity<String> {
  User.empty ();
  User ({String email, String pass}) :    
    _email = email, _pass = pass;
  factory User.fromMap (Map<String, dynamic> map) {
    return new User(email: map['email'], pass: map['pass']);
  }
  
  String _email;
  String _pass;
  
  List asArray () => [_email, _pass];
  
  bool _validate (Persistable persistable, value) => persistable.validate(value);
  
  Symbol get idFieldName => _SYMBOL_EMAIL;
  
  String get email => _email;
  String get pass => _pass;
  int get hashCode {
    final int p = 37;
    int hash = 1;
    hash = p * hash + _email.hashCode;
    hash = p * hash + _pass.hashCode;
    return hash;
  }
  
  set email (String email) {
    if (_PERSISTABLE_EMAIL.validate(email)) {
      _email = email;
      propertyChanged(_SYMBOL_EMAIL);
    } else {
      throw new ArgumentError ('email is not valid');
    }
  }
  set pass (String pass) {
    if (_PERSISTABLE_PASS.validate(pass)) {
      _pass = pass;
      propertyChanged(_SYMBOL_PASS);
    } else {
      throw new ArgumentError ('pass is not valid');
    }
  }
  bool operator == (User e) => e.email == _email && e.pass == _pass;
  static const String _SQL = 'CREATE TABLE User (email VARCHAR(150) NOT NULL, pass VARCHAR(64) NOT NULL, PRIMARY KEY(email));';
  static const Symbol _SYMBOL_EMAIL = const Symbol ('email'), _SYMBOL_PASS = const Symbol ('pass');
  static const Persistable _PERSISTABLE_EMAIL = const StringPersistable (max: 150), _PERSISTABLE_PASS = const StringPersistable (max: 64, min: 64);
}
  