import '../lib/orm/orm.dart';
import '../lib/entity/enhanced/entities.dart';

import 'package:utf/utf.dart';
import 'package:crypto/crypto.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:unittest/unittest.dart';

void main () {
  test('Orm', () {
    var datastore = new SqlDataStore(
        new ConnectionPool(host: '127.0.0.1', port: 3306, user: 'root', password: 'iU4hrS16f5.93', db: 'dodo', max: 5));
    var orm = new Orm(datastore);
    Hash hash = new SHA256()..add('ciaofess'.codeUnits);
    User u = new User(email: 'asd', pass: CryptoUtils.bytesToHex(hash.close()));
    orm.persist(u).whenComplete(() {
      orm.datastore.get(u).then((Optional<User> opt) {
        expect(opt.isAbsent, isFalse);
      });
    });
    orm.datastore.delete(u).whenComplete(() {
      orm.datastore.get(u).then((Optional<User> opt) {
        expect(opt.isAbsent, isTrue);
      });
    });
  });
}