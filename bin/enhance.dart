import 'dart:async';
import 'dart:io';

import 'package:analyzer/analyzer.dart';

class Enhancer extends GeneralizingASTVisitor {
  
  final StringBuffer buffer = new StringBuffer ();
  
  bool _grab = false;
  bool _grabId = false;
  Variable _id;
  Variable _var;
  final List<Variable> _variables = [];
  
  Enhancer ();
  
  visitAnnotation(Annotation node) {
    super.visitAnnotation(node);
    switch (node.name.name){
      case 'Id':
        _grabId = true;
        break;
      case 'Persistable':
        
        break;
      default:
        throw new ArgumentError(node.name.name);
        break;
    }
    _var = new Variable ();
    _var.annotation = node.toString();
  }
  
  visitClassDeclaration (ClassDeclaration node) {
    super.visitClassDeclaration(node);
    buffer.write ('${node.abstractKeyword == null ? '' : '${node.abstractKeyword} '}${node.classKeyword} ${node.name} ${node.extendsClause == null ? '' : '${node.extendsClause} '}{');
  }
  
  visitCompilationUnit (CompilationUnit node) {
    super.visitCompilationUnit(node);
    StringBuffer get = new StringBuffer (), set = new StringBuffer ();
    _variables.forEach((v) {
      buffer.write('\n  ${v.type} _${v.name};');
      get.write('\n  ${v.annotation} ${v.type} get ${v.name} => _${v.name};');
      set.write('\n  set ${v.name} (${v.type} ${v.name}) {\n    _${v.name} = ${v.name};\n    onChange.add(new ContentChangeEvent(this));\n  }');
    });
    buffer.write('\n$get\n  \n$set\n\n}');
  }
  
  visitFieldDeclaration(FieldDeclaration node) {
    _grab = true;
    super.visitFieldDeclaration(node);
    _variables.add(_var);
    _grab = false;
  }
  
  visitTypeName (TypeName node) {
    super.visitTypeName(node);
    if (_grab) {
      _var.type = node.name.name;
    }
  }
  
  visitVariableDeclaration (VariableDeclaration node) {
    super.visitVariableDeclaration(node);
    _var..name = node.name.name
        ..isConst = node.isConst
        ..isFinal = node.isFinal;
    if (_grabId) {
      _id = _var;
      _grabId = false;
    }
  }
}

class _Entity {
  final String name;
  
  _Entity (this.name);
}

class Variable {
  bool isConst;
  bool isFinal;
  String annotation;
  String name;
  String type;
  
  Variable();
  
  String toString () => '$annotation $type $name;';
}

void main () {
  Directory entities = new Directory('../lib/entity');
  
  entities.list(recursive: false, followLinks: false).forEach((file) {
    var unit = parseDartFile(file.absolute.path);
    var enhancer = new Enhancer ();
    unit.accept(enhancer);
    print (enhancer.buffer);
  });
}