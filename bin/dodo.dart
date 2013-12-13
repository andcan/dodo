import '../lib/orm/orm.dart';
import '../lib/entity/enhanced/entities.dart';
import '../lib/enhancer/enhancer.dart';
import 'package:sqljocky/sqljocky.dart';

import 'dart:mirrors';

void main () {
  //enhance('../lib/entity', '../lib/entity/enhanced');
  var datastore = new SqlDataStore(
      new ConnectionPool(host: '127.0.0.1', port: 3306, user: 'root', password: 'iU4hrS16f5.93', db: 'dodo', max: 5));
  var orm = new Orm(datastore);
  User u = new User (email: 'asd', code: 15, name: 'Emilio');
  orm.persist(u).whenComplete(() => datastore.close());
}