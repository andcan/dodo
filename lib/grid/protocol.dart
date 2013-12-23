part of grid;



class Message {
  int _code;
  Iterable<String> _values;
  
  Message(this._code, this._values);
  
  Message.fromString (String message) {
    var s = message.split(SEPARATOR);
    if (s.length > 0) {
      var c = int.parse(s.first, onError: (e) => throw e);
      _code = c;
      _values = s.skip(1);
    }
  }
  
  int get code => _code;
  
  Iterable<String> get values => _values;
  
  String toString () => '$code${SEPARATOR}${values.join(SEPARATOR)}';
  
  String operator [] (int index) => _values.elementAt(index);
  
  static const String SEPARATOR = ':';
}

abstract class Protocol<T> {
  
  factory Protocol () => new _ProtocolImpl ();
  
  static const int CODE_AUTHENTICATE = 100;
  
  T authenticate (String user, String pass);
}

class _ProtocolImpl implements Protocol<Message> {
  Message authenticate (String user, String pass) =>
      new Message (Protocol.CODE_AUTHENTICATE, [user, pass]);
}