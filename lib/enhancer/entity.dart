part of enhancer;

class Entity {
  ClassDeclaration cd;
  final List<Member> members = [];
  
  Entity (this.cd);
  
  String toString () {
    String name = cd.name.name;
    StringBuffer arr = new StringBuffer ('['),
        cs = new StringBuffer ('$name.empty ();\n  $name ({'), cs1 = new StringBuffer (), 
        cs2 = new StringBuffer ('factory $name.fromMap (Map<String, dynamic> map) {\n    return new $name('),
        eq = new StringBuffer (), fs = new StringBuffer (), gs = new StringBuffer (),
        hc = new StringBuffer (), ps = new StringBuffer ('static const Persistable '),
        sql = new StringBuffer ("static const String _SQL = 'CREATE TABLE $name ("), ss = new StringBuffer (),
        symbols = new StringBuffer ('static const Symbol ');
    Member id;
    
    members.forEach((member) {
      String name = member.vd.name.toString(), nameuc = '_${name.toUpperCase()}',
          varname = member.vd.name.toString();
      if (member.a.name.toString () == 'Id') {
        id = member;
      }
      arr.write('_$varname, ');
      cs.write('${member.asParameter()}, ');
      cs1.write('_$name = $name, ');
      cs2.write("$varname: map['$varname'], ");
      eq.write('e.$varname == _$varname && ');
      fs.write('\n  ${member.asPrivate()}');
      gs.write('\n  ${member.asGetter()}');
      hc.write('hash = p * hash + _$varname.hashCode;\n    ');
      ss.write('\n  ${member.asSetter()}');
      symbols.write("_SYMBOL$nameuc = const Symbol ('$name'), ");
      
      String ann;
      Annotation annotation = member.a;
      Map<String, String> args = new Map<String, String> ();
      annotation.arguments.arguments.forEach((arg) {
        var s = arg.toString().split(': ');
        args[s[0]] = s[1];
      });
      String sqlType;
      switch (member.tn.name.toString()) {
        case 'int':
          ann = 'Int';
          sqlType = 'INT';
          break;
        case 'num':
          ann = 'Num';
          sqlType = 'DOUBLE';
          break;
        case 'String':
          ann = 'String';
          if (args.containsKey('max')) {
            sqlType = 'VARCHAR(${args['max']})';
          } else {
            sqlType = 'VARCHAR(256)';
          }
          break;
        default:
          ann = '';
          break;
      }
      sql.write('$name $sqlType ${args.containsKey('nullable') && args['nullable'] ? ' ': 'NOT '}NULL, ');
      ps.write('_PERSISTABLE$nameuc = const ${ann}Persistable ${annotation.arguments.toString()}, ');
    });
    String _arr = '${arr.toString().substring(0, arr.length - 2)}]';
    String _eq = '${eq.toString().substring(0, eq.length - 4)}';
    String _hc = '${hc.toString().substring(0, hc.length - 5)}';
    String _cs = '''${cs.toString().substring(0, cs.length - 2)}}) :    
    ${cs1.toString().substring(0, cs1.length - 2)};
  ${cs2.toString().substring(0, cs2.length - 2)});
  }''';
    String _sql = "${sql.toString().substring(0, sql.length - 2)}, PRIMARY KEY(${id.vd.name}));';";
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
  int get hashCode {
    final int p = 37;
    int hash = 1;
    $_hc
    return hash;
  }
  $ss
  bool operator == ($name e) => $_eq;
  $_sql
  $_symbols
  $_ps
}''';
  }
}