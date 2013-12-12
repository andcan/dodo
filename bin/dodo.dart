import '../lib/orm/orm.dart';
import '../lib/enhancer/enhancer.dart';

import 'dart:mirrors';

void main () {
  enhance('../lib/entity', '../lib/entity/enhanced');
}