part of orm;

typedef bool where (obj);

abstract class DataStore<E extends Entity> {
  void close ();
  
  Future<E> get (E e);
  
  Future put (E e);
  
  Future update (E e, [List<Symbol> symbols = null]);
}

class MemoryDataStore<E extends Entity> implements DataStore<E> {
  Map<Symbol, Map> objs = new Map<Symbol, Map> ();
  
  Future close () => new Future.value(null);
  
  Future<E> get (E e) {
    Completer<E> c = new Completer<E>();
    Symbol name = e.idFieldName;
    if (objs.containsKey(name)) {
      Map m = objs[name];
      c.complete(m[reflect(e).getField(e.idFieldName)]);
    } else {
      c.completeError(new ArgumentError('No instance with this name'));
    }
    return c.future;
  }
  
  Future put (E e) {
    InstanceMirror im = reflect(e);
    Symbol name = im.type.qualifiedName;
    Map m;
    if (objs.containsKey(name)) {
      m = objs[name];
    } else {
      m = new Map ();
      objs[name] = m;
    }
    m[im.getField(e.idFieldName)] = e;
    return new Future.value(true);
  }
}