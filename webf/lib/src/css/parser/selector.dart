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
  final List<Selector> selectors;

  int _specificity = -1;

  int get specificity {
    if (_specificity == -1) {
      _specificity = _calcSpecificity();
    }
    return _specificity;
  }

  SelectorGroup(this.selectors) : super();

  @override
  SelectorGroup clone() => SelectorGroup(selectors);

  @override
  dynamic visit(Visitor visitor) => visitor.visitSelectorGroup(this);

  int _calcSpecificity() {
    int specificity = 0;
    for (final selector in selectors) {
      for (final simpleSelectorSequence in selector.simpleSelectorSequences) {
        final simpleSelector = simpleSelectorSequence.simpleSelector;
        switch (simpleSelector.runtimeType) {
          case IdSelector:
            specificity += kIdSpecificity;
            break;
          case ClassSelector:
            specificity += kClassLikeSpecificity;
            break;
          case ElementSelector:
            specificity += kTagSpecificity;
            break;
        }
      }
    }
    return specificity;
  }
}

class Selector extends TreeNode {
  final List<SimpleSelectorSequence> simpleSelectorSequences;

  Selector(this.simpleSelectorSequences) : super();

  void add(SimpleSelectorSequence seq) => simpleSelectorSequences.add(seq);

  int get length => simpleSelectorSequences.length;

  @override
  Selector clone() {
    var simpleSequences = simpleSelectorSequences.map((ss) => ss.clone()).toList();

    return Selector(simpleSequences);
  }

  @override
  dynamic visit(Visitor visitor) => visitor.visitSelector(this);
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
  SimpleSelectorSequence clone() => SimpleSelectorSequence(simpleSelector, combinator);

  @override
  dynamic visit(Visitor visitor) => visitor.visitSimpleSelectorSequence(this);

  @override
  String toString() => simpleSelector.name;
}

// All other selectors (element, #id, .class, attribute, pseudo, negation,
// namespace, *) are derived from this selector.
abstract class SimpleSelector extends TreeNode {
  final dynamic _name; // ThisOperator, Identifier, Negation, others?

  SimpleSelector(this._name) : super();

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
  ElementSelector clone() => ElementSelector(_name);

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
  AttributeSelector clone() => AttributeSelector(_name as Identifier, _op, value);

  @override
  String toString() => '[$name${matchOperator()}${valueToString()}]';

  @override
  dynamic visit(Visitor visitor) => visitor.visitAttributeSelector(this);
}

// #id
class IdSelector extends SimpleSelector {
  IdSelector(Identifier name) : super(name);
  @override
  IdSelector clone() => IdSelector(_name as Identifier);

  @override
  String toString() => '#$_name';

  @override
  dynamic visit(Visitor visitor) => visitor.visitIdSelector(this);
}

// .class
class ClassSelector extends SimpleSelector {
  ClassSelector(Identifier name) : super(name);
  @override
  ClassSelector clone() => ClassSelector(_name as Identifier);
  @override
  String toString() => '.$_name';

  @override
  dynamic visit(Visitor visitor) => visitor.visitClassSelector(this);
}

// :pseudoClass
class PseudoClassSelector extends SimpleSelector {
  PseudoClassSelector(Identifier name) : super(name);

  @override
  PseudoClassSelector clone() => PseudoClassSelector(_name as Identifier);

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
  PseudoElementSelector clone() => PseudoElementSelector(_name as Identifier);

  @override
  String toString() => "${isLegacy ? ':' : '::'}$name";

  @override
  dynamic visit(Visitor visitor) => visitor.visitPseudoElementSelector(this);
}

// :pseudoClassFunction(argument)
class PseudoClassFunctionSelector extends PseudoClassSelector {
  final dynamic argument; // Selector, List<String>

  PseudoClassFunctionSelector(Identifier name, this.argument) : super(name);

  @override
  PseudoClassFunctionSelector clone() => PseudoClassFunctionSelector(_name as Identifier, argument);

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
  PseudoElementFunctionSelector clone() => PseudoElementFunctionSelector(_name as Identifier, expression);

  @override
  dynamic visit(Visitor visitor) => visitor.visitPseudoElementFunctionSelector(this);
}

// :NOT(negation_arg)
class NegationSelector extends SimpleSelector {
  final SimpleSelector? negationArg;

  NegationSelector(this.negationArg) : super(Negation());

  @override
  NegationSelector clone() => NegationSelector(negationArg);

  @override
  dynamic visit(Visitor visitor) => visitor.visitNegationSelector(this);
}
