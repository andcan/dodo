part of orm;

class Persistable {
  final String name;
  final num max;
  final num min;
  
  const Persistable ({this.name: null, this.max, this.min});
}

class Id extends Persistable {
  const Id({String name: null}) :
    super (name: name);
}