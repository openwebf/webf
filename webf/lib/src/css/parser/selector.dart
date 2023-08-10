/*
Copyright 2013, the Dart project authors.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

part of 'parser.dart';

const kIdSpecificity = 0x010000;
const kClassLikeSpecificity = 0x000100;
const kTagSpecificity = 0x000001;

// https://drafts.csswg.org/cssom/#parse-a-group-of-selectors
class SelectorGroup extends TreeNode {
  final SelectorTextVisitor _selectorTextVisitor = SelectorTextVisitor();
  final List<Selector> selectors;

  int _matchSpecificity = -1;

  int get matchSpecificity => _matchSpecificity;

  set matchSpecificity(int specificity) {
    if (specificity > _matchSpecificity || specificity == -1 ) {
      _matchSpecificity = specificity;
    }
  }

  String? _selectorText;
  String get selectorText {
    if (_selectorText != null) {
      return _selectorText ?? '';
    }
    _selectorTextVisitor.visitSelectorGroup(this);
    _selectorText = _selectorTextVisitor.toString();
    return _selectorText ?? '';
  }

  SelectorGroup(this.selectors) : super();

  @override
  dynamic visit(Visitor visitor) => visitor.visitSelectorGroup(this);
}

class Selector extends TreeNode {
  final List<SimpleSelectorSequence> simpleSelectorSequences;

  Selector(this.simpleSelectorSequences) : super();

  void add(SimpleSelectorSequence seq) => simpleSelectorSequences.add(seq);

  int get length => simpleSelectorSequences.length;

  int _specificity = -1;

  @override
  dynamic visit(Visitor visitor) => visitor.visitSelector(this);

  int get specificity {
    if (_specificity == -1) {
      _specificity = _calcSpecificity();
    }
    return _specificity;
  }

  int _calcSpecificity() {
    int specificity = 0;
    for (final simpleSelectorSequence in simpleSelectorSequences) {
      final simpleSelector = simpleSelectorSequence.simpleSelector;
      switch (simpleSelector.runtimeType) {
        case IdSelector:
          specificity += kIdSpecificity;
          break;
        case ClassSelector:
        case AttributeSelector:
        case PseudoClassSelector:
          specificity += kClassLikeSpecificity;
          break;
        case ElementSelector:
        case PseudoElementSelector:
          specificity += kTagSpecificity;
          break;
      }
    }
    return specificity;
  }
}

class SimpleSelectorSequence extends TreeNode {
  /// +, >, ~, NONE
  int combinator;
  final SimpleSelector simpleSelector;

  SimpleSelectorSequence(this.simpleSelector, [this.combinator = TokenKind.COMBINATOR_NONE]) : super();

  bool get isCombinatorNone => combinator == TokenKind.COMBINATOR_NONE;
  bool get isCombinatorPlus => combinator == TokenKind.COMBINATOR_PLUS;
  bool get isCombinatorGreater => combinator == TokenKind.COMBINATOR_GREATER;
  bool get isCombinatorTilde => combinator == TokenKind.COMBINATOR_TILDE;
  bool get isCombinatorDescendant => combinator == TokenKind.COMBINATOR_DESCENDANT;

  String get combinatorToString {
    switch (combinator) {
      case TokenKind.COMBINATOR_DESCENDANT:
        return ' ';
      case TokenKind.COMBINATOR_GREATER:
        return ' > ';
      case TokenKind.COMBINATOR_PLUS:
        return ' + ';
      case TokenKind.COMBINATOR_TILDE:
        return ' ~ ';
      default:
        return '';
    }
  }

  @override
  dynamic visit(Visitor visitor) => visitor.visitSimpleSelectorSequence(this);

  @override
  String toString() => simpleSelector.name;
}
final Set<String> selectorKeySet = {};
// All other selectors (element, #id, .class, attribute, pseudo, negation,
// namespace, *) are derived from this selector.
abstract class SimpleSelector extends TreeNode {
  final dynamic _name; // ThisOperator, Identifier, Negation, others?

  SimpleSelector(this._name) : super(){
    selectorKeySet.add(_name.name);
  }

  // TOOD(srawlins): Figure this one out.
  // ignore: avoid_dynamic_calls
  String get name => _name.name as String;

  bool get isWildcard => _name is Wildcard;

  bool get isThis => _name is ThisOperator;

  @override
  dynamic visit(Visitor visitor) => visitor.visitSimpleSelector(this);
}

// element name
class ElementSelector extends SimpleSelector {
  ElementSelector(name) : super(name);

  @override
  String toString() => name;

  @override
  dynamic visit(Visitor visitor) => visitor.visitElementSelector(this);
}

// [attr op value]
class AttributeSelector extends SimpleSelector {
  final int _op;
  final dynamic value;

  AttributeSelector(Identifier name, this._op, this.value) : super(name);

  int get operatorKind => _op;

  String? matchOperator() {
    switch (_op) {
      case TokenKind.EQUALS:
        return '=';
      case TokenKind.INCLUDES:
        return '~=';
      case TokenKind.DASH_MATCH:
        return '|=';
      case TokenKind.PREFIX_MATCH:
        return '^=';
      case TokenKind.SUFFIX_MATCH:
        return '\$=';
      case TokenKind.SUBSTRING_MATCH:
        return '*=';
      case TokenKind.NO_MATCH:
        return '';
    }
    return null;
  }

  // Return the TokenKind for operator used by visitAttributeSelector.
  String? matchOperatorAsTokenString() {
    switch (_op) {
      case TokenKind.EQUALS:
        return 'EQUALS';
      case TokenKind.INCLUDES:
        return 'INCLUDES';
      case TokenKind.DASH_MATCH:
        return 'DASH_MATCH';
      case TokenKind.PREFIX_MATCH:
        return 'PREFIX_MATCH';
      case TokenKind.SUFFIX_MATCH:
        return 'SUFFIX_MATCH';
      case TokenKind.SUBSTRING_MATCH:
        return 'SUBSTRING_MATCH';
    }
    return null;
  }

  String valueToString() {
    if (value != null) {
      if (value is Identifier) {
        return value.toString();
      } else {
        return '"$value"';
      }
    } else {
      return '';
    }
  }

  @override
  String toString() => '[$name${matchOperator()}${valueToString()}]';

  @override
  dynamic visit(Visitor visitor) => visitor.visitAttributeSelector(this);
}

// #id
class IdSelector extends SimpleSelector {
  IdSelector(Identifier name) : super(name);

  @override
  String toString() => '#$_name';

  @override
  dynamic visit(Visitor visitor) => visitor.visitIdSelector(this);
}

// .class
class ClassSelector extends SimpleSelector {
  ClassSelector(Identifier name) : super(name);

  @override
  String toString() => '.$_name';

  @override
  dynamic visit(Visitor visitor) => visitor.visitClassSelector(this);
}

// :pseudoClass
class PseudoClassSelector extends SimpleSelector {
  PseudoClassSelector(Identifier name) : super(name);

  @override
  String toString() => ':$name';

  @override
  dynamic visit(Visitor visitor) => visitor.visitPseudoClassSelector(this);
}

// ::pseudoElement
class PseudoElementSelector extends SimpleSelector {
  // If true, this is a CSS2.1 pseudo-element with only a single ':'.
  final bool isLegacy;

  PseudoElementSelector(Identifier name, {this.isLegacy = false}) : super(name);

  @override
  String toString() => "${isLegacy ? ':' : '::'}$name";

  @override
  dynamic visit(Visitor visitor) => visitor.visitPseudoElementSelector(this);
}

// :pseudoClassFunction(argument)
class PseudoClassFunctionSelector extends PseudoClassSelector {
  final dynamic argument; // Selector, List<String>

  PseudoClassFunctionSelector(Identifier name, this.argument) : super(name);

  Selector get selector => argument as Selector;

  List<String> get expression => argument as List<String>;

  @override
  dynamic visit(Visitor visitor) => visitor.visitPseudoClassFunctionSelector(this);
}

// ::pseudoElementFunction(expression)
class PseudoElementFunctionSelector extends PseudoElementSelector {
  final List<String> expression;

  PseudoElementFunctionSelector(Identifier name, this.expression) : super(name);

  @override
  dynamic visit(Visitor visitor) => visitor.visitPseudoElementFunctionSelector(this);
}

// :NOT(negation_arg)
class NegationSelector extends SimpleSelector {
  final SimpleSelector? negationArg;

  NegationSelector(this.negationArg) : super(Negation());

  @override
  dynamic visit(Visitor visitor) => visitor.visitNegationSelector(this);
}

/// Merge the nested selector sequences [current] to the [parent] sequences or
/// substitue any & with the parent selector.
List<SimpleSelectorSequence> mergeNestedSelector(
    List<SimpleSelectorSequence> parent, List<SimpleSelectorSequence> current) {
  // If any & operator then the parent selector will be substituted otherwise
  // the parent selector is pre-pended to the current selector.
  var hasThis = current.any((s) => s.simpleSelector.isThis);

  var newSequence = <SimpleSelectorSequence>[];

  if (!hasThis) {
    // If no & in the sector group then prefix with the parent selector.
    newSequence.addAll(parent);
    newSequence.addAll(_convertToDescendentSequence(current));
  } else {
    for (var sequence in current) {
      if (sequence.simpleSelector.isThis) {
        // Substitue the & with the parent selector and only use a combinator
        // descendant if & is prefix by a sequence with an empty name e.g.,
        // "... + &", "&", "... ~ &", etc.
        var hasPrefix = newSequence.isNotEmpty && newSequence.last.simpleSelector.name.isNotEmpty;
        newSequence.addAll(hasPrefix ? _convertToDescendentSequence(parent) : parent);
      } else {
        newSequence.add(sequence);
      }
    }
  }

  return newSequence;
}

/// Return selector sequences with first sequence combinator being a
/// descendant.  Used for nested selectors when the parent selector needs to
/// be prefixed to a nested selector or to substitute the this (&) with the
/// parent selector.
List<SimpleSelectorSequence> _convertToDescendentSequence(List<SimpleSelectorSequence> sequences) {
  if (sequences.isEmpty) return sequences;

  var newSequences = <SimpleSelectorSequence>[];
  var first = sequences.first;
  newSequences.add(SimpleSelectorSequence(first.simpleSelector, TokenKind.COMBINATOR_DESCENDANT));
  newSequences.addAll(sequences.skip(1));

  return newSequences;
}
