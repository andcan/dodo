import '../orm/orm.dart';

class User {
  @Id(name: 'email') String email;
  @Persistable() String name;
  @Persistable() int code;
}