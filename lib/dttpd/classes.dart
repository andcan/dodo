part of dttpd;

class Route {
  final RegExp match;
  final String to;
  
  Route (this.match, this.to);
  
  int get hashCode {
    int p = 31;
    int hash = 1;
    hash = p * hash + match.hashCode;
    hash = p * hash + to.hashCode;
    return hash;
  }
  
  String toString () => '${match.pattern} => $to';
  
  operator == (Route r) => r.match == match && r.to == to;
}