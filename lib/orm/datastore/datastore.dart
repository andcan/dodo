part of orm;

typedef bool where (obj);

abstract class DataStore {
  get (Symbol name, id);
  
  void put (Entity e);
}

class MemoryDataStore implements DataStore {
  Map<Symbol, Map> objs = new Map<Symbol, Map> ();
  
  get (Symbol name, id) {
    if (objs.containsKey(name)) {
      Map m = objs[name];
      return m[id];
    } else {
      throw new ArgumentError('No instance with this name');
    }
  }
  
  void put (Entity e) {
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
  }
}