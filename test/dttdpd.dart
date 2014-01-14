import 'package:json/json.dart' as json;
import 'package:unittest/unittest.dart';

import '../lib/dttpd/dttpd.dart';
import '../lib/sjs/sjs.dart';

import 'dart:io';

final File SCHEMA = new File('../conf/dttpd/dttpd.schema.json');

main () {
  test ('schema', () {
    Schema schema = new Schema.fromMap(json.parse(SCHEMA.readAsStringSync()));
    
    var formats = schema.formats;
    
    RegExp ipv4 = formats['ipv4'].match;
    expect('192.168.0.1', matches(ipv4));
    expect('255.255.255.255', matches(ipv4));
    expect('0.0.0.0', matches(ipv4));
    
    RegExp path = formats['path'].match;
    expect('/home/andrea', matches(path));
    expect('/home/andrea/', matches(path));
    expect('/', matches(path));
  });
}