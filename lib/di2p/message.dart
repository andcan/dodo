part of di2p;

class HandShakeMessage extends Message {
  HandShakeMessage (String min, String max) :
    super('HELLO', 'VERSION', new PersistentMap.fromMap({'MAX': max, 'MIN': min}));
}

class SessionMessage extends Message {
  SessionMessage(Destination destination, String id, Style style, Map<String, String> options) :
    super ('SESSION', 'CREATE', new PersistentMap.fromMap({
      'DESTINATION': '{${destination.toString()}}',
      'ID': '{$id}',
      'STYLE': '{$style}'
    }..addAll(options)));
}

class Destination {
  final String destination;
  final bool transient;
  
  Destination (this.destination, this.transient);
  
  String toString () => '$destination${transient ? ',TRANSIENT' : ''}';
}

class MessageDecoder implements StreamTransformer<List<int>, Message> {
  final StreamController<Message> _controller = new StreamController<Message>();
  
  MessageDecoder();
  
  const MessageDecoder.constant();
  
  Stream<Message> bind(Stream<List<int>> stream) {
    stream.listen((data) {
      Message m = new Message.fromString(ASCII.decode(data, allowInvalid: true));
      String result = m.params['RESULT'];
      if (result == Result.DUPLICATED_DEST.result) {
        _controller.addError(new DuplicatedDestinationError(m));
      } else if (result == Result.DUPLICATED_ID.result) {
        _controller.addError(new DuplicatedIdError(m));
      } else if (result == Result.I2P_ERROR.result) {
        _controller.addError(new I2pError(m));
      } else if (result == Result.INVALID_KEY.result) {
        _controller.addError(new InvalidKeyError(m));
      } else if (result == Result.NOVERSION.result) {
        _controller.addError(new NoVersionError(m));
      } else {
        _controller.add(m);
      }
    }, onError: (e) => _controller.addError(e), onDone: () => _controller.close(), 
        cancelOnError: false);
    return _controller.stream;
  }
}

class MessageEncoder implements StreamTransformer<Message, List<int>> {
  final StreamController<List<int>> _controller = new StreamController<List<int>>();
  
  const MessageEncoder();
  
  Stream<List<int>> bind(Stream<Message> stream) {
    stream.listen((message) => _controller.add(ASCII.encode(message.toString())),
        onError: (e) => _controller.addError(e), 
        onDone: () => _controller.close(), 
        cancelOnError: false);
    return _controller.stream;
  }
}

class Message {
  final String first;
  final String second;
  final PersistentMap<String, String> params;
  
  Message(this.first, this.second, this.params);
  
  factory Message.fromString(String message) {
    Match msg = MESSAGE.firstMatch(message);
    if (msg == null) {
      throw new ArgumentError('Invalid Message: $message');
    }
    
    Map<String, String> ps = new Map<String, String> ();
    String params = msg.group(3);
    params.split(' ').forEach((String param) {
      Match p = PARAM.firstMatch(param);
      if (p == null) {
        throw new ArgumentError('Invalid param: $param');
      }
      ps[p[1]] = p[2];
    });
    
    return new Message(msg[1], msg[2], new PersistentMap.fromMap(ps));
  }
  
  String toString () {
    StringBuffer ps = new StringBuffer ();
    params.forEach((pair) {
      ps.write('${pair.fst}=${pair.snd} ');
    });
    return '$first $second ${ps.toString().substring(0, ps.length - 1)}\n';
  }
  
  static final RegExp MESSAGE = new RegExp(r'([A-Z]+) ([A-Z]+) ((?:[A-Z]+={?[A-Za-z0-9._]+}?(?: )?)+)\n',
      multiLine: false, caseSensitive: true);
  static final RegExp PARAM = new RegExp(r'([A-Z]+)=({?' + STRING.pattern + '+}?)',
      multiLine: false, caseSensitive: true);
  static final RegExp STRING = new RegExp(r'[A-Za-z0-9._]', multiLine: false,
      caseSensitive: true);
}