part of orm;

class Member {
  final Symbol name;
  final Persistable annotation;
  
  const Member (this.name, this.annotation);
}