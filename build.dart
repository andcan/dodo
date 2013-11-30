import 'package:polymer/builder.dart';
        
main(args) {
  lint(entryPoints: ['web/html/dodo.html'], options: parseOptions(args));
  build(entryPoints: ['web/html/dodo.html'], options: parseOptions(args));
}
