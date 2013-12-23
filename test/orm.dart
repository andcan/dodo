import '../lib/orm/orm.dart';
import '../lib/entity/enhanced/entities.dart';

import 'package:utf/utf.dart';
import 'package:crypto/crypto.dart';
import 'package:sqljocky/sqljocky.dart';

void main () {
  var datastore = new SqlDataStore(
      new ConnectionPool(host: '127.0.0.1', port: 3306, user: 'root', password: 'iU4hrS16f5.93', db: 'dodo', max: 5));
  var orm = new Orm(datastore);
  Hash h = new SHA256()..add('ciaofess'.codeUnits);
  User u = new User(email: 'asd', pass: CryptoUtils.bytesToHex(h.close()));
  orm.persist(u);
}