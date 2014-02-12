library enhancer;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:analyzer/analyzer.dart';

part 'entity.dart';
part 'member.dart';

abstract class Enhancer<I, O> {
  O enhance (I input);
}

String symbol (Symbol symbol) => MirrorSystem.getName(symbol);

class FileEnhancer extends GeneralizingASTVisitor implements Enhancer<String, String> {
  
  Entity _e;
  List<Entity> _es = [];
  
  Annotation _a;
  TypeName _t;
  
  String enhance (String path) {
    parseDartFile(path).accept(this);
    
    var buffer = new StringBuffer ();
    _es.forEach((e) => buffer.write('$e\n  '));
    
    return buffer.toString();
  }
  
  visitAnnotation(Annotation node) {
    _a = node;
    super.visitAnnotation(node);
  }
  
  visitClassDeclaration(ClassDeclaration node) {
    _e = new Entity(node);
    super.visitClassDeclaration(node);
    _es.add(_e);
  }
  
  visitTypeName(TypeName node) {
    _t = _t == null ? node : _t;
    super.visitTypeName(node);
  }
  
  visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);
    _e.members.add(new Member(_a, _t, node));
    _a = null;
    _t = null;
  }
}

Future enhance (String entities, String enhanced) {
  Completer c = new Completer ();
  Directory es = new Directory(entities);
  Directory en = new Directory(enhanced);
  if (!en.existsSync()) {
    en.createSync();
  }

  File lib = new File('${en.path}/entities.dart');
  StringBuffer fls = new StringBuffer ("library entities;\n\nimport '../../orm/orm.dart';\n\n");
  es.list(recursive: false, followLinks: false).forEach((file) {
    var enhancer = new FileEnhancer ();
    if (file is File) {
      int index = file.path.lastIndexOf(new RegExp(r'\b\w+\b\.dart'));
      String filename = file.path.substring(index);
      fls.write("part '$filename';\n");
      if (index < 0) {
        print ('[Warning] ${file.absolute.path} is not a dart file');
      } else {
        File e = new File('${en.path}/${filename}');
        e.writeAsString(enhancer.enhance(file.path), mode: WRITE);
      }
    }
  }).whenComplete(() {
    lib.writeAsStringSync(fls.toString(), mode: WRITE);
    c.complete();
  });
  return c.future;
}