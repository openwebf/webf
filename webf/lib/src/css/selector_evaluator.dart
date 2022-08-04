/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/dom.dart';
import 'package:webf/css.dart';

class SelectorEvaluator extends SelectorVisitor {
  Element? _element;

  bool matchSelector(SelectorGroup? selector, Element? element) {
    if (selector == null || element == null) {
      return false;
    }
    _element = element;
    return visitSelectorGroup(selector);
  }

  @override
  bool visitSelectorGroup(SelectorGroup node) => node.selectors.any(visitSelector);

  @override
  bool visitSelector(Selector node) {
    final old = _element;
    var result = true;

    // Note: evaluate selectors right-to-left as it's more efficient.
    int? combinator;
    for (var s in node.simpleSelectorSequences.reversed) {
      if (combinator == null) {
        result = s.simpleSelector.visit(this) as bool;
      } else if (combinator == TokenKind.COMBINATOR_DESCENDANT) {
        // descendant combinator
        // http://dev.w3.org/csswg/selectors-4/#descendant-combinators
        do {
          _element = _element!.parentElement;
        } while (_element != null && !(s.simpleSelector.visit(this) as bool));

        if (_element == null) result = false;
      } else if (combinator == TokenKind.COMBINATOR_TILDE) {
        // Following-sibling combinator
        // http://dev.w3.org/csswg/selectors-4/#general-sibling-combinators
        do {
          _element = _element!.previousElementSibling;
        } while (_element != null && !(s.simpleSelector.visit(this) as bool));

        if (_element == null) result = false;
      }

      if (!result) break;

      switch (s.combinator) {
        case TokenKind.COMBINATOR_PLUS:
          // Next-sibling combinator
          // http://dev.w3.org/csswg/selectors-4/#adjacent-sibling-combinators
          _element = _element!.previousElementSibling;
          break;
        case TokenKind.COMBINATOR_GREATER:
          // Child combinator
          // http://dev.w3.org/csswg/selectors-4/#child-combinators
          _element = _element!.parentElement;
          break;
        case TokenKind.COMBINATOR_DESCENDANT:
        case TokenKind.COMBINATOR_TILDE:
          // We need to iterate through all siblings or parents.
          // For now, just remember what the combinator was.
          combinator = s.combinator;
          break;
        case TokenKind.COMBINATOR_NONE:
          break;
        default:
          throw _unsupported(node);
      }

      if (_element == null) {
        result = false;
        break;
      }
    }

    _element = old;
    return result;
  }

  @override
  bool visitPseudoClassSelector(PseudoClassSelector node) {
    switch (node.name) {
      // http://dev.w3.org/csswg/selectors-4/#structural-pseudos

      // http://dev.w3.org/csswg/selectors-4/#the-root-pseudo
      case 'root':
        // TODO(jmesserly): fix when we have a .ownerDocument pointer
        // return _element == _element.ownerDocument.rootElement;
        return _element!.nodeName == 'html' && _element!.parentNode == null;

      // http://dev.w3.org/csswg/selectors-4/#the-empty-pseudo
      case 'empty':
        return _element!.childNodes.any((n) => !(n is Element || n is TextNode && n.data.isNotEmpty));

      // http://dev.w3.org/csswg/selectors-4/#the-blank-pseudo
      case 'blank':
        return _element!.childNodes.any((n) => !(n is Element || n is TextNode && n.data.runes.any((r) => !isWhitespaceCC(r))));

      // http://dev.w3.org/csswg/selectors-4/#the-first-child-pseudo
      case 'first-child':
        return _element!.previousElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#the-last-child-pseudo
      case 'last-child':
        return _element!.nextElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#the-only-child-pseudo
      case 'only-child':
        return _element!.previousElementSibling == null && _element!.nextElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#link
      case 'link':
        return _element!.attributes['href'] != null;

      case 'visited':
        // Always return false since we aren't a browser. This is allowed per:
        // http://dev.w3.org/csswg/selectors-4/#visited-pseudo
        return false;
    }

    // :before, :after, :first-letter/line can't match DOM elements.
    if (_isLegacyPsuedoClass(node.name)) return false;

    throw _unimplemented(node);
  }

  @override
  bool visitPseudoElementSelector(PseudoElementSelector node) {
    // :before, :after, :first-letter/line can't match DOM elements.
    if (_isLegacyPsuedoClass(node.name)) return false;

    throw _unimplemented(node);
  }

  static bool _isLegacyPsuedoClass(String name) {
    switch (name) {
      case 'before':
      case 'after':
      case 'first-line':
      case 'first-letter':
        return true;
      default:
        return false;
    }
  }

  @override
  bool visitPseudoElementFunctionSelector(PseudoElementFunctionSelector node) => throw _unimplemented(node);

  @override
  bool visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) {
    switch (node.name) {
      // http://dev.w3.org/csswg/selectors-4/#child-index

      // http://dev.w3.org/csswg/selectors-4/#the-nth-child-pseudo
      case 'nth-child':
        // TODO(jmesserly): support An+B syntax too.
        final exprs = node.expression;
        if (exprs.length == 1 && _element != null) {
          final literal = int.parse(exprs[0]);
          final parent = _element!.parentElement;
          return parent != null && literal > 0 && parent.children.indexOf(_element!) == literal;
        }
        break;
    }
    throw _unimplemented(node);
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  @override
  bool visitElementSelector(ElementSelector node) => _element!.tagName == node.name.toUpperCase();

  @override
  bool visitIdSelector(IdSelector node) => _element!.id == node.name;

  @override
  bool visitClassSelector(ClassSelector node) => _element!.classList.contains(node.name);

  // TODO(jmesserly): negation should support any selectors in level 4,
  // not just simple selectors.
  // http://dev.w3.org/csswg/selectors-4/#negation
  @override
  bool visitNegationSelector(NegationSelector node) => !(node.negationArg!.visit(this) as bool);

  @override
  bool visitAttributeSelector(AttributeSelector node) {
    // Match name first
    final value = _element!.attributes[node.name.toLowerCase()];
    if (value == null) return false;

    if (node.operatorKind == TokenKind.NO_MATCH) return true;

    final select = '${node.value}';
    switch (node.operatorKind) {
      case TokenKind.EQUALS:
        return value == select;
      case TokenKind.INCLUDES:
        return value.split(' ').any((v) => v.isNotEmpty && v == select);
      case TokenKind.DASH_MATCH:
        return value.startsWith(select) && (value.length == select.length || value[select.length] == '-');
      case TokenKind.PREFIX_MATCH:
        return value.startsWith(select);
      case TokenKind.SUFFIX_MATCH:
        return value.endsWith(select);
      case TokenKind.SUBSTRING_MATCH:
        return value.contains(select);
      default:
        throw _unsupported(node);
    }
  }

  UnimplementedError _unimplemented(SimpleSelector selector) => UnimplementedError("'$selector' selector of type "
      '${selector.runtimeType} is not implemented');

  FormatException _unsupported(selector) => FormatException("'$selector' is not a valid selector");

  bool isWhitespaceCC(int charCode) {
    switch (charCode) {
      case TokenChar.TAB: // '\t'
      case TokenChar.NEWLINE: // '\n'
      case TokenChar.FF: // '\f'
      case TokenChar.RETURN: // '\r'
      case TokenChar.SPACE: // ' '
        return true;
    }
    return false;
  }
}
