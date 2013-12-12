import 'lib/enhancer/enhancer.dart';
import 'package:polymer/builder.dart';
        
main(args) {
  //enhance('lib/entity', 'lib/entity/enhanced');
  lint(entryPoints: ['web/html/dodo.html'], options: parseOptions(args));
  build(entryPoints: ['web/html/dodo.html'], options: parseOptions(args));
}
