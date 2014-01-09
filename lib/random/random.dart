library random;

import 'dart:async';
import 'dart:isolate';
//import 'dart-ext:secure_random';

class SecureRandom {
  static SendPort _port;
  
  Future<List<int>> secureRandom (int length) {
    Completer c = new Completer ();
    var replyPort = new RawReceivePort();
    
    var args = new List(2);
    args[0] = length;
    args[1] = replyPort;
    
    _servicePort.send(args);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        c.complete(result);
      } else {
        c.completeError(new Exception("Random array creation failed"));
      }
    };
    return c.future;
  }
  
  SendPort get _servicePort {
    if (_port == null) {
      //_port = _newServicePort();
    }
    return _port;
  }
  
  //SendPort _newServicePort () native "SecureRandom_ServicePort";
}