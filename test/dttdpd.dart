import 'package:json/json.dart' as json;
import 'package:path/path.dart' as libpath;
import 'package:unittest/unittest.dart';

import 'dart:async';

import '../lib/dttpd/dttpd.dart';
import '../lib/sjs/sjs.dart';

import 'dart:io';

final File CONFIG = new File('../conf/dttpd/dttpd.json');
final File SCHEMA = new File('../conf/dttpd/dttpd.schema.json');

main () {
  test ('schema', () {
    Schema schema = new Schema.fromMap(json.parse(SCHEMA.readAsStringSync()));
    
    var formats = schema.formats;
    
    RegExp ipv4 = formats['ipv4'].match;
    expect('192.168.0.1', matches(ipv4));
    expect('255.255.255.255', matches(ipv4));
    expect('0.0.0.0', matches(ipv4));
    expect('127.0.0.1',matches(ipv4));
    
    RegExp path = formats['path'].match;
    expect('/home/andrea', matches(path));
    expect('/home/andrea/', matches(path));
    expect('/', matches(path));
  });
  
  test('validation', () {
    Schema schema = new Schema.fromMap(json.parse(SCHEMA.readAsStringSync()));
    
    expect (schema.validate(json.parse(CONFIG.readAsStringSync())), isTrue);
  });
  
  test ('server', () {
    final config = json.parse(CONFIG.readAsStringSync());
    final Schema schema = new Schema.fromMap(json.parse(SCHEMA.readAsStringSync()));
    
    final address = config['bind']['address'];
    expect (address, equals ('127.0.0.1'));
    final port = config['bind']['port'];
    expect (port, equals (8080));
    Server.bind(config, schema).then((final server) {
      final Directory root = server.rootDirectory;
      server.transform(new Router(server.routes)).listen((HttpRequest request) {
        final HttpResponse response = request.response;
        String path;
        if (request is! RoutedHttpRequest) {
          path = request.uri.path;
        } else {
          path = (request as RoutedHttpRequest).route.to;
        }
        path = libpath.join(root.absolute.path, path.substring(1));
        
        FileSystemEntity.type(path, followLinks: false).then((type) {
          switch (type) {
            case FileSystemEntityType.DIRECTORY:
              StringBuffer buffer = new StringBuffer ();
              new Directory(path).list(recursive: false, followLinks: false)
                .forEach((entity) => buffer.write(entity.path)).then((_) 
                    => response
                    ..write(buffer.toString())
                    ..close());
            break;
            case FileSystemEntityType.FILE:
              new File(path).readAsString().then((data) 
                  => response
                    ..write(data)
                    ..close());
              break;
            case FileSystemEntityType.LINK:
              new Link(path).target().then((data) 
                  => response
                    ..write(data)
                    ..close());
              break;
            case FileSystemEntityType.NOT_FOUND:
              response
                ..write('$path not found!')
                ..close();
              break;
          }
        });
      });
      
      InternetAddress.lookup(address).then((address) {
        expect(server.address.toString(), equals(address.first.toString()));
      });
      expect(server.port, equals(port));
    });
  });
  
  
}