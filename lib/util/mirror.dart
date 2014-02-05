part of util;

/**
 * Reference to current [MirrorSystem]
 */
final MirrorSystem CURRENT_MIRROR_SYSTEM = currentMirrorSystem();
/**
 * Caches instatiators used by [newInstance]
 */
final Map<LibraryMirror, Map<Symbol, Instantiator>> _instantiators =
  <LibraryMirror, Map<Symbol, Instantiator>>{};
/**
 * Local [Symbolizer] instance used by [symbol]
 */
final Symbolizer _symbolizer = new Symbolizer ();
/**
 * Creates and **caches** [Symbol] instances from their [String] representation for later use.
 */
class Symbolizer implements Function {
  
  final Map<String, Symbol> symbols = <String, Symbol>{};
  
  Symbol call (String value) 
    => symbols.containsKey(value) ? symbols[value]
      : symbols[value] = new Symbol(value);
  
  static apply(Function function, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments]) {
    if (1 != positionalArguments.length) {
      throw new ArgumentError('Bad positionalArguments length: ${positionalArguments.length}');
    }
    final value = positionalArguments.first;
    if (value is! String) {
      throw new ArgumentError('value is not String. Found ${value.runtimeType}');
    }
    return function(value);
  }
}

InstanceMirror newInstance (Symbol className, Map<Symbol, dynamic> args, {Symbol constructorName, Symbol libraryName}) {
  LibraryMirror library;
  
  if (null == libraryName) {
    Iterable<LibraryMirror> libs = CURRENT_MIRROR_SYSTEM.libraries.values.where((test) 
        => test.declarations.containsKey(className));
    switch (libs.length) {
      case 0:
        throw new ArgumentError('Declaration not found');
        break;
      case 1:
        library = libs.first;
        break;
      default:
        throw new ArgumentError('Too many declarations');
        break;
    }
  } else {
    try {
      library = CURRENT_MIRROR_SYSTEM.findLibrary(libraryName);
    } on StateError catch (e) {
      throw new ArgumentError('Library not found');
    }
  }
  if (null != library) {
    final declarations = library.declarations;
    var mirror;
    if (! declarations.containsKey(className)) {
      throw new ArgumentError('Declaration not found in ${libraryName != null ? libraryName : 'any library'}');
    }
    mirror = declarations[className];
    if (mirror is! ClassMirror) {
      throw new ArgumentError('$mirror is not a ClassMirror');
    }
    
    Map<Symbol, Instantiator> instantiators;
    if (! _instantiators.containsKey(library)) {
      _instantiators[library] = instantiators = <Symbol, Instantiator>{};
    } else {
      instantiators = _instantiators[library];
    }
    Instantiator i;
    if (! instantiators.containsKey(className)) {
      instantiators[className] = i = new Instantiator(mirror);
    } else {
      i = instantiators[className];
    }
    
    return i.instantiate(args, constructorName: constructorName);
  } else {
    throw new ArgumentError('Declaration not found in ${libraryName != null ? libraryName : 'any library'}');
  }
}

/**
 * Returns the equivalent [Symbol] of [value]
 */
Symbol symbol (String value) => _symbolizer(value);