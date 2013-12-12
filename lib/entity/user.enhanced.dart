import '../orm/orm.dart';
class User extends Entity<String> {
  
  String _email;
  String _name;
  int _code;
  
  String get entityIdentifier => _email;
  
  @Id() String get email => _email;
  @Persistable() String get name => _name;
  @Persistable() int get code => _code;
  
  set email (String email) {
    _email = email;
    propertyChanged();
  }
  set name (String name) {
    _name = name;
    propertyChanged();
  }
  set code (int code) {
    _code = code;
    propertyChanged();
  }
}