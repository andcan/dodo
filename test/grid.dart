import 'package:crypto/crypto.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:unittest/unittest.dart';

import '../lib/entity/enhanced/entities.dart';
import '../lib/grid/grid.dart';
import '../lib/orm/orm.dart';

import 'dart:async';
import 'dart:io';

void main () {
  /*var datastore = new SqlDataStore(
      new ConnectionPool(host: '127.0.0.1', port: 3306, user: 'root', password: 'iU4hrS16f5.93', db: 'dodo', max: 5));
  var orm = new Orm(datastore);
  Node.bind('127.0.0.1', 8005, orm, backlog: 15).then((node) {
    WebSocket.connect('ws://127.0.0.1:8005').then((websocket) {
      while (websocket.readyState != WebSocket.OPEN) {
        sleep(new Duration(milliseconds: 110));
      }
      var protocol = new Protocol();
      websocket.listen((data) => print(data));
      Hash h = new SHA256()..add('ciaofess'.codeUnits);
      websocket.add(
          protocol.authenticate('asd', CryptoUtils.bytesToHex(h.close())).toString());
    });
  });*/
  
  test ('otp', () {
    final String message = 'test message';
    final StreamController<List<int>> controller = new StreamController<List<int>> ();
    final Key k = new Key(path: 'grid.dart');
    controller.stream.transform(new OtpTransformer(k)).transform(new OtpTransformer(k)).listen((data) {
      expect (new String.fromCharCodes(data), equals(message));
    });
    controller.add(message.codeUnits);
  });
}