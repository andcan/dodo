import 'package:unittest/unittest.dart';
import '../lib/sjs/sjs.dart';

main () {
  test ('format', () {
    var format = {
      'caseSensitive': true,
      'match': '.*',
      'multiLine': false,
      'type': 'string'
    };
    
    Format fmt = parseFormat(format);
    expect(fmt, equals(new StringFormat(new RegExp('.*', multiLine: false, caseSensitive: true))));
  
    var formats = {
      '1': {
        'caseSensitive': true,
        'match': '.*',
        'multiLine': false,
        'type': 'string'
      },
      '2': {
        'caseSensitive': true,
        'match': '.?',
        'multiLine': true,
        'type': 'string'
      },
      '3': {
        'caseSensitive': false,
        'match': '.+',
        'multiLine': false,
        'type': 'string'
      }
    };
    formats = parseFormats(formats);
    
    var fmt1 = new StringFormat(new RegExp('.*', multiLine: false, caseSensitive: true));
    var fmts = {
      '1': fmt1,
      '2': new StringFormat(new RegExp('.?', multiLine: true, caseSensitive: true)),
      '3': new StringFormat(new RegExp('.+', multiLine: false, caseSensitive: false)),
    };
    
    expect (formats, equals(fmts));
    
    var field = {
      'type': 'int',
      'min': 1,
      'max': 10
    };
    
    expect(parseField(field, formats), equals(new Field([], 10, 1, true, 'int')));
    
    var fields = {
      'a': {
        'type': 'int',
        'min': 1,
        'max': 10
      },
      'b': {
        'type': 'string',
        'min': 2,
        'max': 5,
        'required': false,
        'format': 1
      }
    };
    
    var fs = {
      'a': new Field([], 10, 1, true, 'int'),
      'b': new Field([fmt1], 2, 5, false, 'string')
    };
    
    expect (parseFields(fields, formats), equals (fs));//Test failed: Caught Illegal argument(s): format is dart.collection._LinkedHashMap expected other
  });
  
  test('schema validation', () {
    Schema s = new Schema.fromMap({
      'name': 'asd',
      'fields': {
        'asd': {
          'type': 'A'
        }
      },
      'types': {
        'A': {
          'fields': {
            'a': {
              'type': 'int',
              'min': 1,
              'max': 10
            }
          }
        }
      }
    });
    expect(s.validate({
      'asd': {
        'a': '1a'
      }
    }), isFalse);
    expect(s.validate({
      'asd': {
        'a': '1'
      }
    }), isTrue);
    expect(s.validate({
      'asd': {
        'a': 1
      }
    }), isTrue);
  });
}

