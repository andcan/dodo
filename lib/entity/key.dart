import '../orm/orm.dart';

class Key {
  @Id() String id;
  @Persistable() int length;
  @Persistable() String path;
}