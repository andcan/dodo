library di2p;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:persistent/persistent.dart';

part 'error.dart';
part 'message.dart';
part 'protocol.dart';

typedef void ErrorListener (Error e);
typedef void Listener (Message message);

class Di2p {
  final Protocol protocol = new Protocol ();
  final Socket _socket;
  
  bool _handshakePerformed = false;
  ErrorListener _onError;
  Listener _onMessage;
  
  Di2p.fromSocket(this._socket) {
    _socket.transform(DECODER).listen((Message m) => _onMessage(m), onError: (e) => _onError(e));
  }
  
  Future<Message> handshake (double min, double max) {
    Completer<Message> c = new Completer<Message> ();
    
    _onMessage = (Message message) {
      if (message.first == 'HELLO' && message.second == 'REPLY' && 
          message.params['RESULT'] == 'OK' && message.params['VERSION'] == '3.0') {
        _handshakePerformed = true;
        c.complete(message);
      } else {
        c.completeError(new Di2pError(message.toString()));
      }
      _onError = null;
      _onMessage = null;
    };
    _onError = (e) {
      c.completeError(e);
      _onError = null;
      _onMessage = null;
    };
    
    add(protocol.handshake(min, max));
    return c.future;
  }
  
  Future<Message> session (Style style, String id, String destination, {bool transient: true}) {
    Completer<Message> c = new Completer<Message> ();
    if (_handshakePerformed) {
      _onMessage = (Message message) {
        if (message.first == 'SESSION' && message.second == 'STATUS' && 
            message.params['RESULT'] == 'OK' && message.params.contains('DESTINATION')) {
          c.complete(message);
        } else {
          c.completeError(new Di2pError(message.toString()));
        }
        _onError = null;
        _onMessage = null;
      };
      _onError = (e) {
        c.completeError(e);
        _onError = null;
        _onMessage = null;
      };
      
      add(protocol.session(id, destination, style: style, transient: transient));
    } else {
      c.completeError(new StateError('handshake not performed'));
    }
    return c.future;
  }
  
  bool get handshakePerformed => _handshakePerformed;
  
  void add (Message m) => _socket.add(ASCII.encode(m.toString()));
  
  Future flush () => _socket.flush();
  
  static Future<Di2p> connect ([int port = PORT]) {
    Completer<Di2p> c = new Completer<Di2p> ();
    Socket.connect(ROUTER_ADDRESS, port).then((socket) => 
        c.complete(new Di2p.fromSocket(socket)));
    return c.future;
  }
  
  static const int PORT = 7656;
  static const String ROUTER_ADDRESS = '127.0.0.1';
  static final MessageDecoder DECODER = new MessageDecoder();
  static const MessageEncoder ENCODER = const MessageEncoder();
}