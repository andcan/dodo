import '../orm/orm.dart';

class Key {
  @Id() String id;
  @Persistable() String path;
}