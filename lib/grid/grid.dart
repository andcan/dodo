library grid;

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:utf/utf.dart';

import '../orm/orm.dart';
import '../entity/enhanced/entities.dart';

part 'otp.dart';
part 'random.dart';
part 'protocol.dart';

class Node {
  final Orm orm;
  final HttpServer server;
  final Hash hash = new SHA256();
  
  static Future<Node> bind (address, int port, Orm orm, {backlog: 0}) {
    var c = new Completer<Node>();
    HttpServer.bind(address, port, backlog: backlog).then((server) =>
      c.complete(new Node (server, orm)), onError: (e) => print (e));
    return c.future;
  }
  
  Node (this.server, this.orm) {
    server.listen(_listen, onError: (e) => print (e), cancelOnError: false);
  }
  
  void _listen (HttpRequest request) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocketTransformer.upgrade(request).then((WebSocket socket) {
        
        bool authenticated = false;
        socket.listen((data) {
          Message m = new Message.fromString(data);
          if (! authenticated) {
            if (m.code != Protocol.CODE_AUTHENTICATE) {
              socket.add('401');
            } else {
              orm.datastore.get(new User(email: m[0])).then((User user) {
                Hash h = hash.newInstance()
                    ..add(m[1].codeUnits);
                String pass = CryptoUtils.bytesToHex(h.close());
                socket.add('${pass == user.pass}');
              });
            }
          }
        });
      }, onError: (e)=> print (e));
    }
  }
}