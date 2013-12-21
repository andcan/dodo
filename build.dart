import 'lib/enhancer/enhancer.dart';
import 'package:polymer/builder.dart';
        
main(args) {
  build(entryPoints: ['web/html/dodo.html'], options: parseOptions(args));
  //enhance('lib/entity', 'lib/entity/enhanced');
}
