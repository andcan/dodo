part of enhancer;

class Member {
  Annotation a;
  TypeName tn;
  VariableDeclaration vd;
  
  Member (this.a, this.tn, this.vd);
  
  String asGetter () => '${tn == null ? ' ' : '$tn '}get ${vd.name} => _${vd.name};';
  
  String asSetter () => '''set ${vd.name} (${tn == null ? ' ' : '$tn '}${vd.name}) {
    if (_PERSISTABLE_${vd.name.toString().toUpperCase()}.validate(${vd.name})) {
      _${vd.name} = ${vd.name};
      propertyChanged(_SYMBOL_${vd.name.toString().toUpperCase()});
    } else {
      throw new ArgumentError ('${vd.name} is not valid');
    }
  }''';
  
  String asParameter () => '${tn == null ? ' ' : '$tn '}${vd.name}';
  
  String asPrivate () => '${tn == null ? ' ' : '$tn '}_${vd.name};';
  
  String toString () => '$a ${tn == null ? ' ' : '$tn '}${vd.name};';
}