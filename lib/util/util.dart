library util;

import 'dart:mirrors';

part 'optional.dart';
part 'mirror.dart';
part 'src/mirror.dart';

final isBool = (value) => value is bool;
final isInt = (value) => value is int;
final isNum = (value) => value is num;
final isString = (value) => value is String;

class Util {
  static const int PRIME = 31;
  
  static int hash (List values) {
    int hash = 1;
    values.forEach((value) {
      hash = PRIME * hash + value.hashCode;
    });
    return hash;
  }
}

class ETypeMirror extends TypeMirror {
  final TypeMirror typeMirror;
  
  ETypeMirror (Type type) :
    typeMirror = reflectType (type);
  
  ETypeMirror.fromMirror (this.typeMirror);
  
  bool get isOriginalDeclaration => typeMirror.isOriginalDeclaration;
  
  bool get isPrivate => typeMirror.isPrivate;
  
  bool isSuperclass (ClassMirror of) {
    Symbol sc = typeMirror.qualifiedName;
    do {
      if (sc == of.qualifiedName) {
        return true;
      }
      of = of.superclass;
    } while (of != null);
    return false;
  }
  
  bool get isTopLevel => typeMirror.isTopLevel;
  
  SourceLocation get location => typeMirror.location;
  
  List<InstanceMirror> get metadata => typeMirror.metadata;
  
  TypeMirror get originalDeclaration => typeMirror.originalDeclaration;

  DeclarationMirror get owner => typeMirror.owner;
  
  Symbol get qualifiedName => typeMirror.qualifiedName;
  
  Symbol get simpleName => typeMirror.simpleName;
  
  List<TypeMirror> get typeArguments => typeMirror.typeArguments;
  
  List<TypeVariableMirror> get typeVariables => typeMirror.typeVariables;
}

