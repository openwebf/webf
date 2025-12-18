/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
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

import 'package:flutter/foundation.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/html.dart';

typedef IndexCounter = int Function(Element element);

Element? querySelector(Node node, String selector) =>
    SelectorEvaluator().querySelector(node, _parseSelectorGroup(selector));

List<Element> querySelectorAll(Node node, String selector) {
  final group = _parseSelectorGroup(selector);
  final results = <Element>[];
  SelectorEvaluator().querySelectorAll(node, group, results);
  return results;
}

bool matches(Element element, String selector) =>
    SelectorEvaluator().matchSelector(_parseSelectorGroup(selector), element);

Element? closest(Node node, String selector) =>
    SelectorEvaluator().closest(node, _parseSelectorGroup(selector));


// http://dev.w3.org/csswg/selectors-4/#grouping
SelectorGroup? _parseSelectorGroup(String selector) {
  CSSParser parser = CSSParser(selector)..tokenizer.inSelector = true;
  return parser.processSelectorGroup();
}

class SelectorEvaluator extends SelectorVisitor {
  Element? _element;
  SelectorGroup? _selectorGroup;

  bool matchSelector(SelectorGroup? selectorGroup, Element? element) {
    if (selectorGroup == null || element == null) {
      return false;
    }
    _element = element;
    _selectorGroup = selectorGroup;
    _selectorGroup?.matchSpecificity = -1;
    return visitSelectorGroup(selectorGroup);
  }

  Element? querySelector(Node root, SelectorGroup? selector) {
    for (var element in root.childNodes.whereType<Element>()) {
      if (matchSelector(selector, element)) return element;
      final result = querySelector(element, selector);
      if (result != null) return result;
    }
    return null;
  }

  void querySelectorAll(Node root, SelectorGroup? selector, List<Element> results) {
    for (var element in root.childNodes.whereType<Element>()) {
      if (matchSelector(selector, element)) results.add(element);
      querySelectorAll(element, selector, results);
    }
  }

  Element? closest(Node node, SelectorGroup? selector) {
    Node? targetNode = node;
    while (targetNode != null) {
      if (targetNode is Element) {
        if (matchSelector(selector, targetNode)) return targetNode;
      }
      targetNode = targetNode.parentNode;
    }
    return null;
  }

  @override
  bool visitSelectorGroup(SelectorGroup node) => node.selectors.any(visitSelector);

  @override
  bool visitSelector(Selector node) {
    final old = _element;

    // Build right-to-left groups of compound selectors (simple selectors joined
    // with COMBINATOR_NONE), and the combinator that connects each group to the
    // next group on the left.
    final List<List<SimpleSelector>> groups = <List<SimpleSelector>>[];
    final List<int> groupCombinators = <int>[]; // combinator from this group to the next (left) group

    {
      List<SimpleSelector> current = <SimpleSelector>[];
      for (final seq in node.simpleSelectorSequences.reversed) {
        current.add(seq.simpleSelector);
        if (seq.combinator != TokenKind.COMBINATOR_NONE) {
          groups.add(current);
          groupCombinators.add(seq.combinator);
          current = <SimpleSelector>[];
        }
      }
      if (current.isNotEmpty) {
        groups.add(current);
        // No combinator to the left of the leftmost group
        groupCombinators.add(TokenKind.COMBINATOR_NONE);
      }
    }

    bool matchesCompound(Element? element, List<SimpleSelector> compound) {
      if (element == null) return false;
      // Save and restore _element so nested selector checks work correctly.
      final saved = _element;
      _element = element;

      // Optional timing/logging for diagnostics.
      final bool wantDetail = DebugFlags.enableCssMatchDetail || (DebugFlags.cssMatchCompoundLogThresholdMs > 0);
      final Stopwatch? sw = wantDetail ? (Stopwatch()..start()) : null;
      bool ok = true;
      int failIndex = -1;
      String failType = '';
      for (int i = 0; i < compound.length; i++) {
        final sel = compound[i];
        final bool matched = sel.visit(this) as bool;
        if (!matched) {
          ok = false;
          failIndex = i;
          failType = _simpleSelectorType(sel);
          break;
        }
      }
      final int elapsed = sw?.elapsedMilliseconds ?? 0;
      if (wantDetail) {
        final int threshold = DebugFlags.cssMatchCompoundLogThresholdMs;
        final bool overThreshold = threshold > 0 && elapsed >= threshold;
        if (DebugFlags.enableCssMatchDetail || overThreshold) {
          final String elemDesc = _describeElement(element);
          final String sels = compound.map(_simpleSelectorType).join(',');
          cssLogger.info('[match][compound] elem=$elemDesc parts=${compound.length} ok=$ok ms=$elapsed'
              '${ok ? '' : ' failAt=$failIndex failType=$failType'} selTypes=[$sels]');
        }
      }
      _element = saved;
      return ok;
    }

    bool result = true;
    Element? cursor = _element;
    if (cursor == null) return false;

    // The rightmost group must match the element itself.
    if (!matchesCompound(cursor, groups[0])) {
      _element = old;
      return false;
    }

    // Walk groups leftwards, honoring the combinator between groups.
    for (int gi = 0; gi < groups.length - 1; gi++) {
      final int combinator = groupCombinators[gi];
      final List<SimpleSelector> nextGroup = groups[gi + 1];

      switch (combinator) {
        case TokenKind.COMBINATOR_DESCENDANT: {
          Element? ancestor = cursor?.parentElement;
          bool found = false;
          while (ancestor != null) {
            if (matchesCompound(ancestor, nextGroup)) {
              found = true;
              cursor = ancestor;
              break;
            }
            ancestor = ancestor.parentElement;
          }
          if (!found) {
            result = false;
          }
          break;
        }
        case TokenKind.COMBINATOR_GREATER: {
          final Element? parent = cursor?.parentElement;
          if (parent == null || !matchesCompound(parent, nextGroup)) {
            result = false;
          } else {
            cursor = parent;
          }
          break;
        }
        case TokenKind.COMBINATOR_PLUS: {
          final Element? prev = cursor?.previousElementSibling;
          if (prev == null || !matchesCompound(prev, nextGroup)) {
            result = false;
          } else {
            cursor = prev;
          }
          break;
        }
        case TokenKind.COMBINATOR_TILDE: {
          Element? prev = cursor?.previousElementSibling;
          bool found = false;
          while (prev != null) {
            if (matchesCompound(prev, nextGroup)) {
              found = true;
              cursor = prev;
              break;
            }
            prev = prev.previousElementSibling;
          }
          if (!found) {
            result = false;
          }
          break;
        }
        case TokenKind.COMBINATOR_NONE:
          // No combinator – the next group must match the same element.
          if (!matchesCompound(cursor, nextGroup)) {
            result = false;
          }
          break;
        default:
          if (kDebugMode) throw _unsupported(node);
      }

      if (!result) break;
    }

    _element = old;
    if (result) _selectorGroup?.matchSpecificity = node.specificity;
    return result;
  }

  String _describeElement(Element e) {
    final String id = (e.id != null && e.id!.isNotEmpty) ? '#${e.id}' : '';
    final String cls = e.classList.isNotEmpty ? '.${e.classList.join('.')}' : '';
    return '<${e.tagName}$id$cls>';
  }

  String _simpleSelectorType(SimpleSelector s) {
    if (s is IdSelector) return 'ID';
    if (s is ClassSelector) return 'CLASS';
    if (s is ElementSelector) return s.isWildcard ? 'TAG(*)' : 'TAG';
    if (s is AttributeSelector) return 'ATTR';
    if (s is NegationSelector) return 'NEGATION';
    if (s is PseudoClassSelector) return 'PSEUDO';
    if (s is PseudoClassFunctionSelector) return 'PSEUDO_FUNC';
    if (s is PseudoElementSelector) return 'PSEUDO_EL';
    if (s is PseudoElementFunctionSelector) return 'PSEUDO_EL_FUNC';
    return s.runtimeType.toString();
  }

  @override
  bool visitPseudoClassSelector(PseudoClassSelector node) {
    switch (node.name.toLowerCase()) {
      // http://dev.w3.org/csswg/selectors-4/#structural-pseudos

      // http://dev.w3.org/csswg/selectors-4/#the-root-pseudo
      case 'root':
        return _element!.nodeName == HTML && (_element!.parentElement == null || _element!.parentElement is Document);

      // http://dev.w3.org/csswg/selectors-4/#the-empty-pseudo
      case 'empty':
        return _element!.childNodes.every((n) => !(n is Element || n is TextNode && n.data.isNotEmpty));

      // http://dev.w3.org/csswg/selectors-4/#the-blank-pseudo
      case 'blank':
        return _element!.childNodes
            .any((n) => !(n is Element || n is TextNode && n.data.runes.any((r) => !isWhitespaceCC(r))));

      // http://dev.w3.org/csswg/selectors-4/#the-first-child-pseudo
      case 'first-child':
        if (_element!.previousElementSibling != null) {
          return _element!.previousElementSibling is HeadElement;
        }
        return true;

      // http://dev.w3.org/csswg/selectors-4/#the-last-child-pseudo
      case 'last-child':
        return _element!.nextSibling == null;

      //http://drafts.csswg.org/selectors-4/#first-of-type-pseudo
      //http://drafts.csswg.org/selectors-4/#last-of-type-pseudo
      //http://drafts.csswg.org/selectors-4/#only-of-type-pseudo
      case 'first-of-type':
      case 'last-of-type':
      case 'only-of-type':
        var parent = _element!.parentElement;
        if (parent != null) {
          var children = parent.children.where((Element el) {
            return el.nodeName == _element!.nodeName;
          }).toList();

          var index = children.indexOf(_element!);
          var isFirst = index == 0;
          var isLast = index == children.length - 1;

          if (isFirst && node.name == 'first-of-type') {
            return true;
          }

          if (isLast && node.name == 'last-of-type') {
            return true;
          }

          if (isFirst && isLast && node.name == 'only-of-type') {
            return true;
          }

          return false;
        } else {
          // No element parent (e.g., the root element). Per spec, the root is the
          // only element child of the document, so it is simultaneously first-of-type,
          // last-of-type and only-of-type.
          switch (node.name) {
            case 'first-of-type':
            case 'last-of-type':
            case 'only-of-type':
              return true;
          }
        }

        break;
      // http://dev.w3.org/csswg/selectors-4/#the-only-child-pseudo
      case 'only-child':
        return _element!.previousSibling == null && _element!.nextSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#link
      case 'link':
        return _element!.attributes['href'] != null;

      case 'visited':
        // Always return false since we aren't a browser. This is allowed per:
        // http://dev.w3.org/csswg/selectors-4/#visited-pseudo
        return false;
    }

    if (_isLegacyPsuedoClass(node.name)) return true;

    if (kDebugMode) throw _unimplemented(node);
    return false;
  }

  @override
  bool visitPseudoElementSelector(PseudoElementSelector node) {
    if (_isLegacyPsuedoClass(node.name)) return true;

    if (kDebugMode) throw _unimplemented(node);
    return false;
  }

  static bool _isLegacyPsuedoClass(String name) {
    // TODO: :first-letter/line match elements.
    switch (name) {
      case 'before':
      case 'after':
      case 'first-letter':
      case 'first-line':
        return true;
      default:
        return false;
    }
  }

  @override
  bool visitPseudoElementFunctionSelector(PseudoElementFunctionSelector node) {
    if (kDebugMode) throw _unimplemented(node);
    return false;
  }

  @override
  bool visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) {
    List<num?>? data = _parseNthExpressions(node.expression);
    //  i = An + B
    if (data == null) {
      return false;
    }

    switch (node.name) {
      // http://dev.w3.org/csswg/selectors-4/#the-nth-child-pseudo
      case 'nth-child':
        return _elementSatisfiesNthChildren(_element!, node, data[0], data[1]!);
      case 'nth-of-type':
        return _elementSatisfiesNthChildrenOfType(_element!, _element!.tagName, node, data[0], data[1]!);
      case 'nth-last-child':
        return _elementSatisfiesNthLastChildren(_element!, node, data[0], data[1]!);
      case 'nth-last-of-type':
        return _elementSatisfiesNthLastChildrenOfType(_element!, _element!.tagName, node, data[0], data[1]!);
    }
    if (kDebugMode) throw _unimplemented(node);
    return false;
  }

  bool _elementSatisfies(Element element, PseudoClassFunctionSelector selector, num? a, num b, IndexCounter finder) {
    int index = 0;

    int? cacheIndex = element.ownerDocument.nthIndexCache.getChildrenIndexFromCache(_element!.parentNode!, _element!, selector.name);
    if (cacheIndex != null) {
      index = cacheIndex;
    } else {
      index = finder(element);
      element.ownerDocument.nthIndexCache.setChildrenIndexWithParentNode(_element!.parentNode!, _element!, selector.name, index);
    }

    return _indexSatisfiesEquation(index + 1, a, b);
  }

  bool _elementSatisfiesNthChildren(Element element, PseudoClassFunctionSelector selector, num? a, num b) {
    return _elementSatisfies(element, selector, a, b, (element) {
      int index = 0;
      Element? currentElement = element;
      // Traverse the list to find the index of the element
      while (currentElement?.previousElementSibling != null) {
        currentElement = currentElement!.previousElementSibling;
        index++;
      }
      return index;
    });
  }

  bool _elementSatisfiesNthChildrenOfType(Element element, String tagName, PseudoClassFunctionSelector selector, num? a, num b) {
    return _elementSatisfies(element, selector, a, b, (element) {
      int index = 0;
      Element? currentElement = element;
      // Traverse the list to find the index of the element
      while (currentElement?.previousElementSibling != null) {
        currentElement = currentElement!.previousElementSibling;
        if (currentElement?.tagName == tagName) {
          index++;
        }
      }
      return index;
    });
  }

  bool _elementSatisfiesNthLastChildren(Element element, PseudoClassFunctionSelector selector, num? a, num b) {
    return _elementSatisfies(element, selector, a, b, (element) {
      Element? currentElement = element;
      int index = 0;
      // Traverse the list to find the index of the element
      while (currentElement?.nextElementSibling != null) {
        currentElement = currentElement!.nextElementSibling;
        index++;
      }
      return index;
    });
  }

  bool _elementSatisfiesNthLastChildrenOfType(Element element, String tagName, PseudoClassFunctionSelector selector, num? a, num b) {
    return _elementSatisfies(element, selector, a, b, (element) {
      Element? currentElement = element;
      int index = 0;
      // Traverse the list to find the index of the element
      while (currentElement?.nextElementSibling != null) {
        currentElement = currentElement!.nextElementSibling;
        if (currentElement?.tagName == tagName) {
          index++;
        }
      }
      return index;
    });
  }

  bool _indexSatisfiesEquation(int index, num? a, num b) {
    if (a == null) {
      return b > 0 && index == b;
    }

    var divideResult = (index - b) / a;
    if (divideResult >= 1) {
      return divideResult % divideResult.ceil() == 0;
    } else {
      return divideResult == 0;
    }
  }

  num _countExpressionList(List<String> list) {
    String first = list[0];
    num sum = 0;
    num modulus = 1;
    if (first == '-') {
      modulus = -1;
      list = list.sublist(1);
    }
    for (var item in list) {
      num? value = num.tryParse(item);
      if (value != null) {
        sum += value;
      }
    }
    return sum * modulus;
  }

  List<num?>? _parseNthExpressions(List<String> exprs) {
    num? A;
    num B = 0;

    if (exprs.isNotEmpty) {
      if (exprs.length == 1) {
        String value = exprs[0];
        if (isNumeric(value)) {
          B = num.parse(value);
        } else {
          if (value == 'even') {
            A = 2;
            B = 1;
          } else if (value == 'odd') {
            A = 2;
            B = 0;
          } else if (value == 'n') {
            A = 1;
            B = 0;
          } else {
            return null;
          }
        }
      }

      List<String> bTerms = [];
      List<String> aTerms = [];
      var nIndex = exprs.indexWhere((expr) {
        return expr.toString() == 'n';
      });

      if (nIndex > -1) {
        bTerms.addAll(exprs.sublist(nIndex + 1));
        aTerms.addAll(exprs.sublist(0, nIndex));
      } else {
        bTerms.addAll(exprs);
      }

      if (bTerms.isNotEmpty) {
        B = _countExpressionList(bTerms);
      }

      if (aTerms.isNotEmpty) {
        if (aTerms.length == 1 && aTerms[0] == '-') {
          A = -1;
        } else {
          A = _countExpressionList(aTerms);
        }
      } else {
        if (nIndex == 0) {
          A = 1;
        }
      }
    }

    return [A, B];
  }

  bool isNumeric(String s) {
    return num.tryParse(s) != null;
  }

  @override
  bool visitElementSelector(ElementSelector node) => node.isWildcard || _element!.tagName == node.name.toUpperCase();

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
        if (kDebugMode) throw _unsupported(node);
    }
    return false;
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
