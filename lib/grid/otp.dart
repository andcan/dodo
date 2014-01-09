part of grid;

class KeyManager {
  
  final Orm orm;
  
  KeyManager (this.orm);
  
  Future delete (Key k) => new File (k.path).delete();
  
  Future<Key> generate (Key k, {bool overwrite: false}) {
    Completer<Key> c = new Completer<Key>();
    File f = new File(k.path);
    f.exists().then((exists) {
      if (exists) {
        if (overwrite) {
          f.delete().whenComplete(() {
            //generate
          });
        }
      } else {
        //generate
      }
    });
    return c.future;
  }
  
  Future<List<int>> load (Key k) => new File(k.path).readAsBytes();
}

class OtpTransformer implements StreamTransformer<List<int>, List<int>> {
  final Key _key;
  File _file;
  
  OtpTransformer (Key key) :
    this._key = key, _file = new File(key.path);
  
  var controller = new StreamController<List<int>>();
  Stream<List<int>> bind(Stream<List<int>> stream) {
    if (!_file.existsSync()) {
      throw new ArgumentError('${_file.path} does not exist');
    }
    int index = 0;
    var keyData = _file.readAsBytesSync();
    stream.listen((List<int> data) {
      List<int> transformed = new List<int> ();
      data.forEach((int i) {
        transformed.add(i ^ keyData[index++]);
      });
      controller.add(transformed);
    }, onError: (e) => controller.addError(e), onDone: () => controller.close(),
        cancelOnError: false);
    return controller.stream;
  }
}