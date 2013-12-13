part of orm;

class SqlDataStore<E extends Entity> implements DataStore<E> {
  
  final Map<Symbol, Query> _gets = new Map<Symbol, Query> (),
      _puts = new Map<Symbol, Query> ();
  final ConnectionPool pool;
  
  SqlDataStore(this.pool);
  
  void _handleError (MySqlException e) => throw e;
  
  void close () {
    pool.close();
  }
  
  Future<E> get (E e) {
    Completer<E> c = new Completer<E> ();
    pool.startTransaction(consistent: true).then((transaction) {
      InstanceMirror mirror = reflect (e);
      Symbol id = e.idFieldName;
      
      bool newQuery = false;
      Symbol name = mirror.type.qualifiedName;
      Future<Query> q;
      if (_gets.containsKey(name)) {
        q = new Future.value(_gets[name]);
      } else {
        newQuery = true;
        q = transaction
          .prepare('SELECT * FROM ${e.runtimeType} WHERE ${MirrorSystem.getName(id)} = ? LIMIT 1')
            .then((query) => q = query, onError: _handleError);
      }
      
      q.then((query) {
        _gets[mirror.type.qualifiedName] = query;
        query.execute([mirror.getField(id)]).then((Results results) {
          results.length.then((length) {
            switch (length) {
              case '0':
                c.complete(null);
                break;
              case '1':
                results.first.then((Row result) {
                  results.fields.forEach((field) {
                    mirror.setField(new Symbol ('${field.name}'), result[field]);
                    c.complete(e);
                  });                
                }, onError: _handleError);
                break;
              default:
                c.completeError(new StateError ('Invalid results'));
                break;
            }
            transaction.commit();
          }, onError: _handleError);
        }, onError: _handleError);
      }, onError: _handleError);
    }, onError: _handleError);
    return c.future;
  }
  
  Future<bool> put (E e) {
    Completer<bool> c = new Completer<bool> ();
    pool.startTransaction(consistent: true).then((transaction) {
      InstanceMirror mirror = reflect (e);
      Symbol name = mirror.type.qualifiedName;
      Future<Query> q;
      List values = e.asArray();
      
      bool newQuery = false;
      if (_puts.containsKey(name)) {
        q = new Future.value(_puts[name]);
      } else {
        newQuery = true;
        var qms = new StringBuffer ();
        for (int i = 0; i < values.length; i++) {
          qms.write('?, ');
        }
        q = transaction
            .prepare('INSERT INTO ${e.runtimeType} VALUES (${qms.toString().substring(0, qms.length - 2)})');
      }
      q.then((query) {
        if (newQuery) {
          _puts[mirror.type.qualifiedName] = query;
        }
        query.execute(values).then((results) {
          //results will be empty, but auto-increment columns will be reported
          transaction.commit();
          c.complete(true);
        }, onError: _handleError);
      }, onError: _handleError);
    });
    return c.future;
  }
}