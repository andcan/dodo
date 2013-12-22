part of di2p;

abstract class Protocol {
  
  factory Protocol () => new _Protocol ();
  
  /**
   * ----------------------------------------------------------------------
   * SAM connection handshake
   * ----------------------------------------------------------------------
   * No SAM communication can occur until after the client and bridge have agreed on a 
   * protocol version, which is done by the client sending a HELLO and the bridge sending
   * a HELLO REPLY: 
   * 
   * ->  HELLO VERSION MIN=$min MAX=$max
   * 
   * and
   * 
   * <-  HELLO REPLY RESULT=OK VERSION=3.0
   * 
   * *** In order to force protocol version 3.0, the values of $min and $max must be "3.0".
   */
  Message handshake([double min = 3.0, double max = 3.0]);
  
  /**
   * If the SAM bridge cannot find a suitable version, it replies with :
   * 
   * <- HELLO REPLY RESULT=NOVERSION
   * 
   * If some error occurred, such as a bad request format, it replies with :
   * 
   * <- HELLO REPLY RESULT=I2P_ERROR MESSAGE={$message}
   */
  RegExp handshakeReply ({Result result: Result.OK, double version: 3.0});
  
  /**
   * ----------------------------------------------------------------------
   * SAM sessions
   * ----------------------------------------------------------------------
   * A SAM session is created by a client opening a socket to the SAM bridge, operating a
   * handshake, and sending a SESSION CREATE message, and the session terminates when the
   * socket is disconnected.
   * 
   * Each registered I2P Destination is uniquely associated with a session ID (or nickname).
   * 
   * Each session is uniquely associated with :
   * * the socket from which the client creates the session
   *  * its ID (or nickname)
   * The session creation message can only use one of these forms (messages received through
   * other forms are answered with an error message) :
   * 
   * ->  SESSION CREATE 
   *        STYLE={STREAM,DATAGRAM,RAW}
   *        ID={$nickname}
   *        DESTINATION={$private_destination_key,TRANSIENT}
   *        [option=value]*
   *        
   * DESTINATION specifies what destination should be used for sending and receiving 
   * messages/streams.  It has to be a suitable
   * private base64 destination key. If the destination is
   * specified as TRANSIENT, the SAM bridge creates a new destination.
   * 
   * {$nickname} is the choice of the client. No whitespace is allowed.
   * 
   * Additional options given are passed to the I2P session configuration if not interpreted
   * by the SAM bridge (e.g. outbound.length=0). These options are documented below.
   *  
   * The SAM bridge itself should already be configured with what router it should
   * communicate over I2P through (though if need be there maybe a way to provide an 
   * override, e.g. i2cp.tcp.host=localhost and i2cp.tcp.port=7654).
   * 
   * SAM sessions live and die with the socket they are associated with. When the socket is
   * closed, the session dies, and all communications using the session die at the same
   * time. And the other way round, when the session dies for any reason, the SAM bridge
   * closes the socket.
   */
  Message session (String id, String destination, {Map<String, String> options,
    Style style: Style.STREAM, bool transient: true});
  
  /**
   * After receiving the session create message, the SAM bridge will reply with a session status message, as follows:
   * 
   * If the creation was successful :
   * 
   * <-  SESSION STATUS RESULT=OK DESTINATION={$private_destination_key}
   * 
   * If the nickname is already associated with a session :
   * 
   * <-  SESSION STATUS RESULT=DUPLICATED_ID
   * 
   * If the destination is already in use :
   * 
   * <-  SESSION STATUS RESULT=DUPLICATED_DEST
   * 
   * If the destination is not a valid private destination key :
   * 
   * <-  SESSION STATUS RESULT=INVALID_KEY
   * 
   * If some other error has occurred :
   * 
   * <-  SESSION STATUS RESULT=I2P_ERROR MESSAGE={$message}
   * 
   * If it's not OK, the MESSAGE should contain human-readable information as to why the 
   * session could not be created.
   */
  RegExp sessionReply ({Result result: Result.OK});
}

class _Protocol implements Protocol {
  HandShakeMessage handshake([double min = 3.0, double max = 3.0]) {
    if (min < 1 || min > 3) {
      throw new ArgumentError('[min] must be between 1 and 3 (included)');
    } else if (max < 1 || max > 3) {
      throw new ArgumentError('[max] must be between 1 and 3 (included)');
    } else if (min > max) {
      throw new ArgumentError('[min] must be smaller or equal than [max]');
    }
    return new HandShakeMessage(min.toStringAsPrecision(2), max.toStringAsPrecision(2));
  }
  
  RegExp handshakeReply ({Result result: Result.OK, double version: 3.0}) {
    switch (result) {
      case Result.OK:
        if (version < 1 || version > 3) {
          throw new ArgumentError('[version] must be between 1 and 3 (included)');
        }
        return new RegExp('HELLO REPLY RESULT=$result VERSION=${version.toStringAsPrecision(2)}\n');
        break;
      case Result.I2P_ERROR:
        return new RegExp(r'HELLO REPLY RESULT=I2P_ERROR MESSAGE={(\w+(?: )*)+}\n');
        break;
      case Result.NOVERSION:
        return new RegExp(r'HELLO REPLY RESULT=NOVERSION\n');
        break;
    }
  }
  
  SessionMessage session (String id, String destination, {Map<String, String> options: const {},
    Style style: Style.STREAM, bool transient: true}) {
    var opts = new StringBuffer ();
    if (options != null) {
      options = new Map<String, String> ();
    }
    return new SessionMessage(new Destination(destination, transient), id, style, options);
  }
  
  RegExp sessionReply ({Result result: Result.OK}) {
    switch(result) {
      case Result.OK:
        return new RegExp(r'SESSION STATUS RESULT=OK DESTINATION={\w+}\n');
        break;
    }
  }
  
  
}

class Result {
  final String result;
  
  const Result._(this.result);
  
  static const Result DUPLICATED_DEST = const Result._('DUPLICATED_DEST'),
      DUPLICATED_ID = const Result._('DUPLICATED_ID'),
      I2P_ERROR = const Result._('I2P_ERROR'),
      INVALID_KEY = const Result._('INVALID_KEY'),
      NOVERSION = const Result._('NOVERSION'),
      OK = const Result._('OK');
  
  String toString () => result;
}

class Style {
  final String style;
  
  const Style._(this.style);
  
  static const Style DATAGRAM = const Style._('DATAGRAM'),
      RAW = const Style._('RAW'),
      STREAM = const Style._('STREAM');
  
  String toString () => style;
}