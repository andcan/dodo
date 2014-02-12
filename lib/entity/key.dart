import '../orm/orm.dart';

class Key {
  @Id() String id;
  @Persistable() List<int> path;
}