part of orm;

typedef bool where (obj);

abstract class DataStore {
  get (Symbol name, id);
  
  void put (Symbol name, Entity e);
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
  
  void put (Symbol name, Entity e) {
    Map m;
    if (objs.containsKey(name)) {
      m = objs[name];
    } else {
      m = new Map ();
      objs[name] = m;
    }
    m[e.entityIdentifier] = e;
  }
}