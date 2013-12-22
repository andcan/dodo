import '../lib/di2p/di2p.dart';

import 'package:unittest/unittest.dart';

void main () {
  test ('message', () {
    Message m = new Message.fromString('HELLO REPLY RESULT=OK VERSION=3.0\n');
    expect(m.first, equals('HELLO'));
    expect(m.second, equals('REPLY'));
    expect(m.params['RESULT'], equals('OK'));
    expect(m.params['VERSION'], equals('3.0'));
    expect(m.toString(), equals('HELLO REPLY RESULT=OK VERSION=3.0\n'));
  });
  
  test ('protocol', () {
    Protocol p = new Protocol ();
    
    expect(p.handshake(3.0, 3.0).toString(), 
        equals ('HELLO VERSION MIN=3.0 MAX=3.0\n'));
    
    expect('HELLO REPLY RESULT=OK VERSION=3.0\n', 
        matches(p.handshakeReply(result: Result.OK, version: 3.0)));
    expect('HELLO REPLY RESULT=NOVERSION\n', 
        matches(p.handshakeReply(result: Result.NOVERSION)));
    expect('HELLO REPLY RESULT=I2P_ERROR MESSAGE={error message}\n', 
        matches(p.handshakeReply(result: Result.I2P_ERROR)));
  });
  
  test('di2p', () {
    Protocol p = new Protocol ();
    Di2p.connect().then((Di2p di2p) {
      double version = 3.0;
      
      di2p.handshake(version, version).whenComplete(() {
        di2p.handshake(version, version).then((data) => print(data), onError: (e) => print(e));
        /*di2p.session(Style.STREAM, "asd", "XX8q0ZL~poSrEoge2KEW0rRiHvdrK-OFyk7dH5~Saes=",
            transient: true).then((msg) => print(msg), onError: (e)=> print(e));*/
      });
    });
  });
}