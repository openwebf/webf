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
import 'package:webf/src/html/form/checked.dart';
import 'package:webf/src/html/form/base_input.dart';
import 'package:webf/src/html/form/form_element_base.dart';

typedef IndexCounter = int Function(Element element);

Element? querySelector(Node node, String selector) =>
    SelectorEvaluator(scopeElement: _resolveScope(node))
        .querySelector(node, _parseSelectorGroup(selector));

List<Element> querySelectorAll(Node node, String selector) {
  final group = _parseSelectorGroup(selector);
  final results = <Element>[];
  SelectorEvaluator(scopeElement: _resolveScope(node))
      .querySelectorAll(node, group, results);
  return results;
}

bool matches(Element element, String selector) =>
    SelectorEvaluator(scopeElement: element)
        .matchSelector(_parseSelectorGroup(selector), element);

Element? closest(Node node, String selector) =>
    SelectorEvaluator(scopeElement: node is Element ? node : null)
        .closest(node, _parseSelectorGroup(selector));


// http://dev.w3.org/csswg/selectors-4/#grouping
SelectorGroup? _parseSelectorGroup(String selector) {
  CSSParser parser = CSSParser(selector)..tokenizer.inSelector = true;
  return parser.processSelectorGroup();
}

Element? _resolveScope(Node node) {
  if (node is Element) return node;
  if (node is Document) return node.documentElement;
  return null;
}

class SelectorEvaluator extends SelectorVisitor {
  Element? _element;
  SelectorGroup? _selectorGroup;
  final Element? _scopeElement;

  SelectorEvaluator({Element? scopeElement}) : _scopeElement = scopeElement;

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
    final String name = node.name.toLowerCase();
    switch (name) {
      // http://dev.w3.org/csswg/selectors-4/#structural-pseudos

      // http://dev.w3.org/csswg/selectors-4/#the-root-pseudo
      case 'root':
        return _element!.nodeName == HTML && (_element!.parentElement == null || _element!.parentElement is Document);

      case 'scope':
        if (_scopeElement == null) return false;
        return identical(_element, _scopeElement);

      // http://dev.w3.org/csswg/selectors-4/#the-empty-pseudo
      case 'empty':
        return _element!.childNodes.every((n) => !(n is Element || n is TextNode && n.data.isNotEmpty));

      // http://dev.w3.org/csswg/selectors-4/#the-blank-pseudo
      case 'blank':
        return _element!.childNodes
            .any((n) => !(n is Element || n is TextNode && n.data.runes.any((r) => !isWhitespaceCC(r))));

      // http://dev.w3.org/csswg/selectors-4/#the-first-child-pseudo
      case 'first-child':
        return _element!.previousElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#the-last-child-pseudo
      case 'last-child':
        return _element!.nextElementSibling == null;

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

          if (isFirst && name == 'first-of-type') {
            return true;
          }

          if (isLast && name == 'last-of-type') {
            return true;
          }

          if (isFirst && isLast && name == 'only-of-type') {
            return true;
          }

          return false;
        } else {
          // No element parent (e.g., the root element). Per spec, the root is the
          // only element child of the document, so it is simultaneously first-of-type,
          // last-of-type and only-of-type.
          switch (name) {
            case 'first-of-type':
            case 'last-of-type':
            case 'only-of-type':
              return true;
          }
        }

        break;
      // http://dev.w3.org/csswg/selectors-4/#the-only-child-pseudo
      case 'only-child':
        return _element!.previousElementSibling == null && _element!.nextElementSibling == null;

      // https://drafts.csswg.org/selectors-4/#the-hover-pseudo
      case 'hover':
        return _element!.isHovered;

      // https://drafts.csswg.org/selectors-4/#the-active-pseudo
      case 'active':
        return _element!.isActive;

      // https://drafts.csswg.org/selectors-4/#the-focus-pseudo
      case 'focus':
        return _element!.isFocused;

      // https://drafts.csswg.org/selectors-4/#the-focus-visible-pseudo
      case 'focus-visible':
        return _element!.isFocusVisible;

      // https://drafts.csswg.org/selectors-4/#the-focus-within-pseudo
      case 'focus-within':
        return _element!.isFocusWithin;

      // https://drafts.csswg.org/selectors-4/#enableddisabled
      case 'enabled':
      case 'disabled': {
        final Element element = _element!;
        if (!_isFormControlElement(element)) return false;
        final bool isDisabled = _isFormControlDisabled(element);
        return name == 'disabled' ? isDisabled : !isDisabled;
      }
      // https://drafts.csswg.org/selectors-4/#opt-pseudos
      case 'required':
      case 'optional': {
        final Element element = _element!;
        if (!_isFormControlElement(element)) return false;
        final bool required = element.attributes.containsKey('required');
        return name == 'required' ? required : !required;
      }
      // https://drafts.csswg.org/selectors-4/#placeholder-shown-pseudo
      case 'placeholder-shown': {
        final Element element = _element!;
        if (!_isFormControlElement(element)) return false;
        String placeholder = '';
        String value = '';
        if (element is BaseInputElement) {
          placeholder = element.placeholder;
          value = element.value;
        } else {
          placeholder = element.attributes['placeholder'] ?? '';
          value = element.attributes['value'] ?? '';
        }
        if (placeholder.isEmpty) return false;
        return value.isEmpty;
      }
      // https://drafts.csswg.org/selectors-4/#validity-pseudos
      case 'valid':
      case 'invalid': {
        final Element element = _element!;
        if (!_isFormControlElement(element)) return false;
        final bool isValid = _isFormControlValid(element);
        return name == 'valid' ? isValid : !isValid;
      }
      // https://drafts.csswg.org/selectors-4/#checked
      case 'checked': {
        final Element element = _element!;
        if (element is BaseCheckedElement) {
          return element.getChecked();
        }
        if (element.tagName.toUpperCase() == OPTION) {
          return _isOptionSelected(element);
        }
        if (element.attributes.containsKey('checked')) return true;
        if (element.attributes.containsKey('selected')) return true;
        final String? ariaChecked = element.attributes['aria-checked'];
        if (ariaChecked != null && ariaChecked.toLowerCase() == 'true') return true;
        return false;
      }

      // http://dev.w3.org/csswg/selectors-4/#link
      case 'link':
        return _element!.attributes['href'] != null;

      case 'visited':
        // Always return false since we aren't a browser. This is allowed per:
        // http://dev.w3.org/csswg/selectors-4/#visited-pseudo
        return false;
    }

    if (_isLegacyPsuedoClass(name)) return true;

    if (kDebugMode) throw _unimplemented(node);
    return false;
  }

  bool _isFormControlElement(Element element) {
    switch (element.tagName.toUpperCase()) {
      case 'BUTTON':
      case 'INPUT':
      case 'SELECT':
      case 'TEXTAREA':
      case 'OPTION':
      case 'OPTGROUP':
      case 'FIELDSET':
        return true;
      default:
        return false;
    }
  }

  bool _isFormControlDisabled(Element element) {
    // Widget-based form controls (e.g., <input>, <textarea>) keep `disabled`
    // state in the element instance and may not reflect it as an attribute.
    if (element is FormElementBase) {
      if (element.disabled) return true;
    }
    if (element.attributes.containsKey('disabled')) return true;
    if (element.tagName.toUpperCase() == OPTION) {
      final Element? optgroup = _findAncestorByTag(element, OPTGROUP);
      if (optgroup != null && optgroup.attributes.containsKey('disabled')) {
        return true;
      }
      final Element? select = _findAncestorByTag(element, SELECT);
      if (select != null && select.attributes.containsKey('disabled')) {
        return true;
      }
    }
    if (element.tagName.toUpperCase() == OPTGROUP) {
      final Element? select = _findAncestorByTag(element, SELECT);
      if (select != null && select.attributes.containsKey('disabled')) {
        return true;
      }
    }
    final String? ariaDisabled = element.attributes['aria-disabled'];
    if (ariaDisabled != null && ariaDisabled.toLowerCase() == 'true') return true;
    return false;
  }

  bool _isFormControlValid(Element element) {
    if (_isFormControlDisabled(element)) {
      return true;
    }
    String type = 'text';
    String value = '';
    if (element is BaseInputElement) {
      type = element.type.toLowerCase();
      value = element.value ?? '';
    } else {
      final String? attrType = element.attributes['type'];
      if (attrType != null && attrType.isNotEmpty) {
        type = attrType.toLowerCase();
      }
      value = element.attributes['value'] ?? '';
    }
    final bool required = element.attributes.containsKey('required');

    if (element is BaseCheckedElement && (type == 'checkbox' || type == 'radio')) {
      return !required || element.getChecked();
    }

    switch (type) {
      case 'email':
        if (value.isEmpty) return !required;
        return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
      default:
        if (!required) return true;
        return value.isNotEmpty;
    }
  }

  Element? _findAncestorByTag(Element element, String tag) {
    Element? current = element.parentElement;
    while (current != null) {
      if (current.tagName.toUpperCase() == tag) {
        return current;
      }
      current = current.parentElement;
    }
    return null;
  }

  bool _isOptionSelected(Element element) {
    if (element.attributes.containsKey('selected')) {
      return true;
    }
    final Element? select = _findAncestorByTag(element, SELECT);
    if (select == null) {
      return false;
    }
    if (select.attributes.containsKey('multiple')) {
      return false;
    }
    final List<Element> options = _collectOptions(select);
    if (options.isEmpty) {
      return false;
    }
    final bool anyExplicit = options.any((option) => option.attributes.containsKey('selected'));
    if (anyExplicit) {
      return false;
    }
    return identical(options.first, element);
  }

  List<Element> _collectOptions(Element root) {
    final List<Element> options = <Element>[];
    void visit(Element element) {
      if (element.tagName.toUpperCase() == OPTION) {
        options.add(element);
      }
      for (final Element child in element.children) {
        visit(child);
      }
    }
    visit(root);
    return options;
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
    final String name = node.name.toLowerCase();

    switch (name) {
      case 'is': {
        final arg = node.argument;
        if (arg is! SelectorGroup) return false;
        final Element element = _element!;
        for (final Selector selector in arg.selectors) {
          if (_matchesSelectorWithoutSpecificity(selector, element)) {
            return true;
          }
        }
        return false;
      }
      case 'has': {
        final arg = node.argument;
        if (arg is! SelectorGroup) return false;
        final Element scope = _element!;
        for (final Selector selector in arg.selectors) {
          if (_matchesRelativeSelector(scope, selector)) {
            return true;
          }
        }
        return false;
      }
      case 'where': {
        final arg = node.argument;
        if (arg is! SelectorGroup) return false;
        final Element element = _element!;
        for (final Selector selector in arg.selectors) {
          if (_matchesSelectorWithoutSpecificity(selector, element)) {
            return true;
          }
        }
        return false;
      }
      // http://dev.w3.org/csswg/selectors-4/#the-nth-child-pseudo
      case 'nth-child':
      case 'nth-of-type':
      case 'nth-last-child':
      case 'nth-last-of-type': {
        final arg = node.argument;
        if (arg is! List<String>) return false;
        final List<num?>? data = _parseNthExpressions(arg);
        //  i = An + B
        if (data == null) return false;

        switch (name) {
          case 'nth-child':
            return _elementSatisfiesNthChildren(_element!, node, data[0], data[1]!);
          case 'nth-of-type':
            return _elementSatisfiesNthChildrenOfType(_element!, _element!.tagName, node, data[0], data[1]!);
          case 'nth-last-child':
            return _elementSatisfiesNthLastChildren(_element!, node, data[0], data[1]!);
          case 'nth-last-of-type':
            return _elementSatisfiesNthLastChildrenOfType(_element!, _element!.tagName, node, data[0], data[1]!);
        }
        return false;
      }
    }

    if (kDebugMode) throw _unimplemented(node);
    return false;
  }

  bool _matchesRelativeSelector(Element scope, Selector selector) {
    if (selector.simpleSelectorSequences.isEmpty) return false;

    final int leadingCombinator = selector.simpleSelectorSequences.first.combinator;
    Iterable<Element> candidates;

    switch (leadingCombinator) {
      case TokenKind.COMBINATOR_PLUS:
      case TokenKind.COMBINATOR_TILDE: {
        final List<Element> roots = <Element>[];
        Element? sibling = scope.nextElementSibling;
        while (sibling != null) {
          roots.add(sibling);
          sibling = sibling.nextElementSibling;
        }
        if (roots.isEmpty) return false;
        candidates = _traverseMultiple(roots);
        break;
      }
      case TokenKind.COMBINATOR_GREATER:
      case TokenKind.COMBINATOR_DESCENDANT:
      case TokenKind.COMBINATOR_NONE:
      default: {
        candidates = _traverseElements(scope, includeRoot: false);
        break;
      }
    }

    for (final Element element in candidates) {
      final List<Element> leftmostMatches = _collectLeftmostMatches(element, selector);
      if (leftmostMatches.isEmpty) continue;
      for (final Element leftmost in leftmostMatches) {
        if (_leftmostMatchesScope(scope, leftmost, leadingCombinator)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _leftmostMatchesScope(Element scope, Element leftmost, int leadingCombinator) {
    switch (leadingCombinator) {
      case TokenKind.COMBINATOR_GREATER:
        return leftmost.parentElement == scope;
      case TokenKind.COMBINATOR_PLUS:
        return leftmost.previousElementSibling == scope;
      case TokenKind.COMBINATOR_TILDE: {
        Element? prev = leftmost.previousElementSibling;
        while (prev != null) {
          if (prev == scope) return true;
          prev = prev.previousElementSibling;
        }
        return false;
      }
      case TokenKind.COMBINATOR_DESCENDANT:
      case TokenKind.COMBINATOR_NONE:
      default:
        return _isDescendantOf(leftmost, scope);
    }
  }

  bool _isDescendantOf(Element element, Element ancestor) {
    Element? current = element.parentElement;
    while (current != null) {
      if (current == ancestor) return true;
      current = current.parentElement;
    }
    return false;
  }

  Iterable<Element> _traverseMultiple(List<Element> roots) sync* {
    for (final Element root in roots) {
      yield* _traverseElements(root, includeRoot: true);
    }
  }

  Iterable<Element> _traverseElements(Element root, {required bool includeRoot}) sync* {
    if (includeRoot) yield root;
    for (final Element child in root.children) {
      yield child;
      yield* _traverseElements(child, includeRoot: false);
    }
  }

  List<Element> _collectLeftmostMatches(Element element, Selector node) {
    final old = _element;
    final Set<Element> results = <Element>{};

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

    void collect(Element current, int groupIndex) {
      if (!matchesCompound(current, groups[groupIndex])) return;
      if (groupIndex == groups.length - 1) {
        results.add(current);
        return;
      }

      final int combinator = groupCombinators[groupIndex];
      final List<SimpleSelector> nextGroup = groups[groupIndex + 1];

      switch (combinator) {
        case TokenKind.COMBINATOR_DESCENDANT: {
          Element? ancestor = current.parentElement;
          while (ancestor != null) {
            if (matchesCompound(ancestor, nextGroup)) {
              collect(ancestor, groupIndex + 1);
            }
            ancestor = ancestor.parentElement;
          }
          break;
        }
        case TokenKind.COMBINATOR_GREATER: {
          final Element? parent = current.parentElement;
          if (parent == null || !matchesCompound(parent, nextGroup)) {
            break;
          }
          collect(parent, groupIndex + 1);
          break;
        }
        case TokenKind.COMBINATOR_PLUS: {
          final Element? prev = current.previousElementSibling;
          if (prev == null || !matchesCompound(prev, nextGroup)) {
            break;
          }
          collect(prev, groupIndex + 1);
          break;
        }
        case TokenKind.COMBINATOR_TILDE: {
          Element? prev = current.previousElementSibling;
          while (prev != null) {
            if (matchesCompound(prev, nextGroup)) {
              collect(prev, groupIndex + 1);
            }
            prev = prev.previousElementSibling;
          }
          break;
        }
        case TokenKind.COMBINATOR_NONE:
          if (matchesCompound(current, nextGroup)) {
            collect(current, groupIndex + 1);
          }
          break;
        default:
          if (kDebugMode) throw _unsupported(node);
      }
    }

    collect(element, 0);

    _element = old;
    return results.toList(growable: false);
  }

  bool _matchesSelectorWithoutSpecificity(Selector selector, Element element) {
    final Element? savedElement = _element;
    final SelectorGroup? savedGroup = _selectorGroup;

    _element = element;
    // Disable matchSpecificity tracking while evaluating nested selectors.
    _selectorGroup = null;
    final bool result = visitSelector(selector);

    _element = savedElement;
    _selectorGroup = savedGroup;

    return result;
  }

  bool _elementSatisfies(Element element, PseudoClassFunctionSelector selector, num? a, num b, IndexCounter finder) {
    // For a detached element, per Selectors semantics used by WPT, treat it as
    // the sole child of its (implicit) parent subtree. This means its 1-based
    // index is 1 and all sibling traversals are empty.
    final ContainerNode? parent = element.parentNode;
    if (parent == null) {
      return _indexSatisfiesEquation(1, a, b);
    }

    int index = 0;
    final int? cacheIndex = element.ownerDocument.nthIndexCache.getChildrenIndexFromCache(parent, element, selector.name);
    if (cacheIndex != null) {
      index = cacheIndex;
    } else {
      index = finder(element);
      element.ownerDocument.nthIndexCache.setChildrenIndexWithParentNode(parent, element, selector.name, index);
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
        String value = exprs[0].toLowerCase();
        if (isNumeric(value)) {
          B = num.parse(value);
          return [A, B];
        } else {
          if (value == 'even') {
            A = 2;
            B = 0;
            return [A, B];
          } else if (value == 'odd') {
            A = 2;
            B = 1;
            return [A, B];
          } else if (value == 'n') {
            A = 1;
            B = 0;
            return [A, B];
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
