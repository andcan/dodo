import '../orm/orm.dart';

class User {
  @Id(max: 150) String email;
  @Persistable(max: 64, min: 64) String pass;
}