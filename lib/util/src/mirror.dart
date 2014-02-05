part of util;

class Applier {
  final MethodMirror constructor;
  final List<ParameterMirror> parameters;
  
  Applier(MethodMirror constructor) 
      : parameters = constructor.parameters,
      this.constructor = constructor;
  
  ApplierResult apply (Map<Symbol, dynamic> args) {
    List positional = [];
    Map<Symbol, dynamic> named = <Symbol, dynamic>{};
    
    parameters.forEach((param) {
      Symbol name = param.simpleName;
      if (! args.containsKey(name)) {
        if (! param.isOptional) {
          throw new ArgumentError('Missing required parameter ${MirrorSystem.getName(param.simpleName)}');
        }/*else {
          //Nothing to do: param is not required
        }*/
      } else {
        if (! param.isNamed) {
          positional.add(args[name]);
        } else {
          named[name] = args[name];
        }
      }
    });
    
    return new ApplierResult(positional, named: named);
  }
}

class ApplierResult {
  final Map<Symbol, dynamic> named;
  final List positional;
  
  ApplierResult(this.positional, {this.named});
}

class Instantiator {
  final Map<Symbol, Applier> appliers = <Symbol, Applier>{};
  final ClassMirror mirror;
  final Iterable<MethodMirror> constructors;
  
  Instantiator(ClassMirror mirror) 
      : constructors = mirror.declarations.values.where(TEST).map((f) => f as MethodMirror),
      this.mirror = mirror {
    constructors.forEach((constructor)
        => appliers[constructor.constructorName] = new Applier(constructor));
  }
  
  /**
   * Returns true if and only if value is a [MethodMirror] on a constructor and it isn't const or private
   */
  static final Function TEST = (DeclarationMirror declaration) 
      => declaration is MethodMirror && declaration.isConstructor
          && ! declaration.isPrivate && ! declaration.isConstConstructor;//impossible to instatiate const objetcs at runtime

  InstanceMirror instantiate (Map<Symbol, dynamic> args, {Symbol constructorName}) {
    final Map<Symbol, dynamic> named = <Symbol, dynamic>{};
    final List positional = [];
    
    ApplierResult result;
    if (null != constructorName) {
      result = appliers[constructorName].apply(args);
    } else {
      Iterable<Symbol> names = appliers.keys;
      for (Symbol name in names) {
        Applier applier = appliers[name];
        try {
          result = applier.apply(args);
        } on ArgumentError catch (e) {
          //Not appliable
        }
        if (null != result) {
          constructorName = name;
          break;
        }
      }
    }
    
    if (null != result) {
      var named = result.named;
      return mirror.newInstance(constructorName, result.positional, named.isNotEmpty ? named : null);
    } else {
      throw new ArgumentError('No suitable constructor found');
    }
  }
}

