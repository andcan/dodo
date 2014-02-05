part of dttpd;

class RoutedHttpRequest extends Stream<List<int>> implements HttpRequest {
  final HttpRequest _request;
  final Route route;
  
  RoutedHttpRequest(this._request, this.route);
  
  X509Certificate get certificate => _request.certificate;
  
  HttpConnectionInfo get connectionInfo => _request.connectionInfo;
  
  int get contentLength => _request.contentLength;
  
  List<Cookie> get cookies => _request.cookies;
  
  HttpHeaders get headers => _request.headers;
  
  String get method => _request.method;
  
  bool get persistentConnection => _request.persistentConnection;
  
  String get protocolVersion => _request.protocolVersion;
  
  HttpResponse get response => _request.response;
  
  HttpSession get session => _request.session;
  
  Uri get uri => _request.uri;
  
  StreamSubscription<List<int>> listen(void onData(List<int> event), {Function onError,
    void onDone(), bool cancelOnError}) 
    => _request.listen(onData, onError: onError, onDone: onDone, 
        cancelOnError: cancelOnError);
}

class Router implements StreamTransformer<HttpRequest, HttpRequest> {
  final List<Route> _routes;
  final StreamController<HttpRequest> _controller = new StreamController();
  
  Router(this._routes);
  
  Stream<HttpRequest> bind(Stream<HttpRequest> stream) {
    stream.listen((request) {
      HttpRequest r;
      var routes = _routes.where((test) => test.match.hasMatch(request.uri.path));
      if (routes.isNotEmpty) {
        r = new RoutedHttpRequest(request, routes.first);
      } else {
        r = request;
      }
      _controller.add(r);
    }, onError: (e) => _controller.addError(e), onDone: () => _controller.done,
        cancelOnError: false);
    return _controller.stream;
  }
}