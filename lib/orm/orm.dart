library orm;

import 'dart:async';
import 'dart:mirrors';

import 'package:sqljocky/sqljocky.dart';

part 'datastore/datastore.dart';
part 'datastore/sqldatastore.dart';
part 'entity.dart';
part 'optional.dart';
part 'annotation.dart';
part 'src/event.dart';
part 'src/member.dart';
part 'src/meta.dart';

class Orm {
  
  final DataStore datastore;
  
  final StreamController<ContentChangeEvent> _onChange = 
      new StreamController<ContentChangeEvent> ();
  final Map<Symbol, Meta> _registered = new Map<Symbol, Meta> ();
  
  Orm (this.datastore) {
    _onChange.stream.listen(_listen, onError: (e) => print (e));
  }
  
  void _listen (ContentChangeEvent e) {
    InstanceMirror mirror = reflect (e.entity);
    ClassMirror type = mirror.type;
    
    datastore.put(type.qualifiedName, e.entity);
    e.sink();
  }
  
  /*void register (Type t) {
    ClassMirror mirror = reflectClass(t);
    
    mirror.instanceMembers.forEach((name, method) {
      if (method.isGetter) {
        Member id;
        List<Member> members = [];
        
        method.metadata.forEach((im) {
          if (im is Persistable) {
            Member m = new Member(name, mapped: im.name, max: im.max, min: im.min);
            if (im is Id) {
              id = m;
            } else {
              members.add(m);
            }
          }
        });
        _registered[mirror.qualifiedName] = new Meta (id, members);
      }
    });
  }*/
  
  void persist (Entity e) {
    e.changeStreamController = new Optional(_onChange);      
    datastore.put(reflect (e).type.qualifiedName, e);
  }
}