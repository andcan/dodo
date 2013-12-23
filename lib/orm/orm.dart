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
    datastore.update(e.entity, [e.field]);
    e.sink();
  }
  
  Future<bool> persist (Entity e) {
    e.changeStreamController = new Optional(_onChange);
    return datastore.put(e);
  }
}