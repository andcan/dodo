part of sjs;

abstract class Format<T> extends Object with HasType {
  final T match;
  
  Format(this.match, String type) {
    this.type = type;
  }
  
  int get hashCode => Util.hash([match]);
  
  operator == (Format f);
}

class StringFormat extends Format<RegExp> {
  
  /**
   * Creates a [StringFormat] from given [RegExp]
   */
  StringFormat (RegExp regexp) :
    super(regexp, 'string');
  
  /**
   * Creates a [StringFormat] from given [String]
   */
  StringFormat.fromString (String expression, {bool caseSensitive: true,
    bool multiLine: false}) :
    super(new RegExp(expression, caseSensitive: caseSensitive, multiLine: multiLine),
        'string');
  
  operator == (StringFormat f) => match.pattern == f.match.pattern && 
      match.isCaseSensitive == f.match.isCaseSensitive &&
      match.isMultiLine == f.match.isMultiLine;
}