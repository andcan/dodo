part of di2p;

class Di2pError extends Error {
  final String error;
  Di2pError ([this.error]) :
    super();
  
  String toString() => error;
}

class MessageError extends Di2pError {
  final Message message;
  
  MessageError(Message message) :
    this.message = message,
    super(message.toString());
}

class DuplicatedDestinationError extends MessageError {
  DuplicatedDestinationError (Message error) :
    super(error);
}

class DuplicatedIdError extends MessageError {
  DuplicatedIdError (Message error) :
    super(error);
}

class I2pError extends MessageError {
  I2pError (Message error) :
    super(error);
}

class InvalidKeyError extends MessageError {
  InvalidKeyError (Message error) :
    super(error);
}

class NoVersionError extends MessageError {
  NoVersionError (Message error) :
    super(error);
}