part of dttpd;

class Server implements HttpServer, Stream<HttpRequest> {
  final Map _config;
  final Schema _schema;
  final Directory rootDirectory;
  final HttpServer _server;
  
  Server._ (this._server, this._schema, Map config) :
    this._config = config,
    rootDirectory = new Directory(config['rootDirectory']);
  
  Future<HttpRequest> get first => _server.first;
  
  InternetAddress get address => _server.address;
  
  Duration get idleTimeout => _server.idleTimeout;
  
  bool get isBroadcast => false;
  
  Future<bool> get isEmpty => _server.isEmpty;
  
  Future<HttpRequest> get last => _server.last;
  
  Future<int> get length => _server.length;
  
  List<Map<String, dynamic>> get mappings => _config['mappings'];
  
  int get port =>_server.port;
  
  List<Route> get routes => _config['routes'];
  
  String get serverHeader => _server.serverHeader;
  
  Future<HttpRequest> get single => _server.single;
  
  Future<bool> any(bool test(HttpRequest element)) => _server.any(test);
  
  Stream<HttpRequest> asBroadcastStream({
    void onListen(StreamSubscription<HttpRequest> subscription),
    void onCancel(StreamSubscription<HttpRequest> subscription) }) 
    => _server.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  
  Map get config => new Map.from(_config);
  
  HttpConnectionsInfo connectionsInfo() => _server.connectionsInfo();
  
  Future<bool> contains(Object needle) => _server.contains(needle);
  
  Stream<HttpRequest> distinct([bool equals(HttpRequest previous, 
                                                 HttpRequest next)]) 
                                                 => _server.distinct(equals);
  
  Future drain([var futureValue]) => _server.drain();
  
  Future<HttpRequest> elementAt(int index) => _server.elementAt(index);
  
  Future<bool> every(bool test(HttpRequest element)) => _server.every(test);
  
  Stream expand(Iterable convert(HttpRequest value)) => _server.expand(convert);
  
  Future<dynamic> firstWhere(bool test(HttpRequest element), {Object defaultValue()})
    => _server.firstWhere(test, defaultValue: defaultValue);
  
  Future fold(var initialValue, combine(var previous, HttpRequest element))
    => _server.fold(initialValue, combine);
  
  Future forEach(void action(HttpRequest element)) => _server.forEach(action);
  
  Stream<HttpRequest> handleError(Function onError, { bool test(error) })
    => _server.handleError(onError, test: test);
  
  Future<String> join([String separator = ""]) => _server.join(separator);
  
  Future<dynamic> lastWhere(bool test(HttpRequest element), {Object defaultValue()})
    => _server.lastWhere(test, defaultValue: defaultValue);
  
  StreamSubscription<HttpRequest> listen(void onData(HttpRequest event), 
      { Function onError, void onDone(), bool cancelOnError }) 
      => _server.listen(onData, onError: onError, onDone: onDone, 
          cancelOnError: cancelOnError);
  
  Stream map(convert(HttpRequest event)) => _server.map(convert);
  
  Future pipe(StreamConsumer<HttpRequest> streamConsumer) 
    => _server.pipe(streamConsumer);
  
  Future<HttpRequest> reduce(HttpRequest combine(HttpRequest previous, 
                                                           HttpRequest element))
                                                 => _server.reduce(combine);
  
  Future<HttpRequest> singleWhere(bool test(HttpRequest element)) 
    => _server.singleWhere(test);
  
  Stream<HttpRequest> skip(int count) => _server.skip(count);
  
  Stream<HttpRequest> skipWhile(bool test(HttpRequest element)) 
    => _server.skipWhile(test);
  
  Stream<HttpRequest> take(int count) => _server.take(count);
  
  Stream<HttpRequest> takeWhile(bool test(HttpRequest element)) 
    => _server.takeWhile(test);
  
  Stream timeout(Duration timeLimit, {void onTimeout(EventSink sink)})
    => _server.timeout(timeLimit, onTimeout: onTimeout);
  
  Future<List<HttpRequest>> toList() => _server.toList();
  
  Future<Set<HttpRequest>> toSet() => _server.toSet();
  
  Stream transform(StreamTransformer<HttpRequest, dynamic> streamTransformer) 
    => _server.transform(streamTransformer);
  
  Stream<HttpRequest> where(bool test(HttpRequest event)) 
    => _server.where(test);
  
  Future close ({bool force: false}) => _server.close(force: force);
  
  set idleTimeout (Duration timeout) => _server.idleTimeout = timeout;
  
  set serverHeader (String header) => _server.serverHeader = header;
  
  set sessionTimeout (int timeout) => _server.sessionTimeout = timeout;
  
  static Future<Server> bind (Map config, Schema schema) {
    Completer<Server> c = new Completer<Server>();
    if (! schema.validate(config)) {
      throw new ArgumentError('Bad configuration: $config');
    }
    var bind = config['bind'];
    String address = bind['address'];
    int port = bind['port'];
    
    HttpServer.bind(address, port).then((HttpServer server) {
      Server s = new Server._(server, schema, config);
      c.complete(s);
    }, onError: (e) => c.completeError(e));
    return c.future;
  }
}