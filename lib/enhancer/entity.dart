part of enhancer;

class Entity {
  ClassDeclaration cd;
  final List<Member> members = [];
  
  Entity (this.cd);
  
  String toString () {
    String name = cd.name.name;
    StringBuffer arr = new StringBuffer ('['),
        cs = new StringBuffer ('$name.empty ();\n  $name ({'), cs1 = new StringBuffer (), 
        cs2 = new StringBuffer ('factory $name.fromMap (Map<String, dynamic> map) {\n    return new User('), fs = new StringBuffer (),
        gs = new StringBuffer (), ps = new StringBuffer ('static const Persistable '),
        ss = new StringBuffer (), symbols = new StringBuffer ('static const Symbol ');
    Member id;
    
    members.forEach((member){
      String name = member.vd.name.toString(), nameuc = '_${name.toUpperCase()}',
          varname = member.vd.name.toString();
      if (member.a.name.toString () == 'Id') {
        id = member;
      }
      arr.write('_$varname, ');
      fs.write('\n  ${member.asPrivate()}');
      cs.write('${member.asParameter()}, ');
      cs1.write('_$name = $name, ');
      cs2.write("$varname: map['$varname'], ");
      gs.write('\n  ${member.asGetter()}');
      ss.write('\n  ${member.asSetter()}');
      symbols.write("_SYMBOL$nameuc = const Symbol ('$name'), ");
      
      Annotation annotation = member.a;
      ps.write('_PERSISTABLE$nameuc = const ${annotation.name.toString()} ${annotation.arguments.toString()}, ');
    });
    String _arr = '${arr.toString().substring(0, arr.length - 2)}]';
    String _cs = '''${cs.toString().substring(0, cs.length - 2)}}) :    
    ${cs1.toString().substring(0, cs1.length - 2)};
  ${cs2.toString().substring(0, cs2.length - 2)});
  }''';
    String _symbols = '${symbols.toString().substring(0, symbols.length - 2)};';
    String _ps = '${ps.toString().substring(0, ps.length - 2)};';
    
    return '''part of entities;

class ${cd.abstractKeyword == null ? '' : '${cd.abstractKeyword} '}${cd.name} extends Entity${id.tn == null ? '' : '<${id.tn}>'} {
  $_cs
  $fs
  
  List asArray () => $_arr;
  
  bool _validate (Persistable persistable, value) => persistable.validate(value);
  
  Symbol get idFieldName => _SYMBOL_${id.vd.name.toString().toUpperCase()};
  $gs
  $ss
  $_symbols
  $_ps
}''';
  }
}