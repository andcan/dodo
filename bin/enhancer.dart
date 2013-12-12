import 'dart:io';

import 'package:analyzer/analyzer.dart';

abstract class Enhancer<I, O> extends GeneralizingASTVisitor {
  O enhance (I input);
}

class StringEnhancer extends Enhancer <String, String> {
  Entity entity;
  Member member;
  
  String enhance (String input, [String name = null]) {
    entity = new Entity ();
    parseCompilationUnit(input, name: name).accept(this);
    
    String enhanced = entity.toString();
    entity = null;
    return enhanced;
  }
  
  visitAnnotation(Annotation node) {
    if (member != null) {
      member.a = node;
    }
    super.visitAnnotation(node);
  }
  
  visitClassDeclaration(ClassDeclaration node) {
    entity.cd = node;
    super.visitClassDeclaration(node);
  }
  
  visitFieldDeclaration(FieldDeclaration node) {
    member = new Member();
    super.visitFieldDeclaration(node);
    entity.members.add(member);
  }
  
  visitTypeName(TypeName node) {
    if (member != null) {
      member.tn = node;
    }
    super.visitTypeName(node);
  }
  
  visitVariableDeclaration(VariableDeclaration node) {
    member.vd = node;
    super.visitVariableDeclaration(node);
  }
}

class Entity {
  ClassDeclaration cd;
  final List<Member> members = [];
  
  String toString () {
    StringBuffer fs = new StringBuffer (), gs = new StringBuffer (), ss = new StringBuffer ();
    Member id;
    
    members.forEach((member){
      if (member.a.name.toString () == 'Id') {
        id = member;
      }
      fs.write('\n  ${member.asPrivate()}');
      gs.write('\n  ${member.asGetter()}');
      ss.write('\n  ${member.asSetter()}');
    });
    
    return '''import '../orm/orm.dart';
class ${cd.abstractKeyword == null ? '' : '${cd.abstractKeyword} '}${cd.name} extends Entity${id.tn == null ? '' : '<${id.tn}>'} {
  $fs
  
 ${id.asGetter(true)}
  $gs
  $ss
}''';
  }
}

class Member {
  Annotation a;
  TypeName tn;
  VariableDeclaration vd;
  
  String asGetter ([bool id = false]) => '${id ? ' ' : '$a '}${tn == null ? ' ' : '$tn '}get ${id ? 'entityIdentifier' : vd.name} => _${vd.name};';
  
  String asSetter () => 'set ${vd.name} (${tn == null ? ' ' : '$tn '}${vd.name}) {\n    _${vd.name} = ${vd.name};\n    propertyChanged();\n  }';
  
  String asPrivate () => '${tn == null ? ' ' : '$tn '}_${vd.name};';
  
  String toString () => '$a ${tn == null ? ' ' : '$tn '}${vd.name};';
}

void main () {
  Directory entities = new Directory('../lib/entity');
  
  entities.list(recursive: false, followLinks: false).forEach((file) {
    var enhancer = new StringEnhancer ();
    if (file is File) {
      File enhanced = new File(file.absolute.path.replaceFirst('.dart', '.enhanced.dart'));
      enhanced.writeAsString(enhancer.enhance(file.readAsStringSync(), file.absolute.path), mode: FileMode.WRITE);
    }
  });
}