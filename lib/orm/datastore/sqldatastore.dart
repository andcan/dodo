part of orm;

class SqlDataStore implements DataStore {
  
  final ConnectionPool pool;
  
  SqlDataStore(this.pool);
  
  void _handleError (Error e) => throw e;
  
  get (Symbol name, id) {
    pool.startTransaction(consistent: true).then((transaction) {
      
    }, onError: _handleError);
  }
}