import '../lib/util/util.dart';

import 'dart:mirrors';

import 'package:unittest/unittest.dart';

class Abc {
  final String a;
  
  Abc.asd(this.a);
  
  Abc(int asd) : this.a = asd.toString();
  
  bool operator == (Abc a) => this.a == a.a;
}

void main () {
  test ('util', () {
    ClassMirror mirror = reflectClass(Abc);
    MethodMirror c = mirror.declarations.values.where((test) 
        => test is MethodMirror && test.isConstructor).elementAt(1);
    
    expect(newInstance(symbol('Abc'), {
      symbol('asd'): 15
    }).reflectee, equals(mirror.newInstance(c.constructorName, [15]).reflectee));
  });
}