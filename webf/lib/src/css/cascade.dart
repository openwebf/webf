/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:webf/css.dart';

/// Internal segment appended to layered rules that are directly inside a layer
/// block (i.e. not in an explicit nested sublayer).
///
/// Per CSS Cascade Layers, the implicit sublayer is ordered *after* all explicit
/// sublayers within the same layer, so that direct rules in the layer override
/// nested layer rules in the normal (non-`!important`) cascade.
const String kWebFImplicitLayerSegment = '__webf__implicit_layer__';

const int _kImplicitLayerSiblingIndex = 1 << 30;

class CascadeLayerTree {
  final _LayerNode _root = _LayerNode(name: '<root>', siblingIndex: -1);

  void reset() {
    _root.reset();
  }

  /// Ensures [layerPath] exists and returns its stable sort key.
  List<int> declare(List<String> layerPath) {
    var node = _root;
    final key = <int>[];
    for (final seg in layerPath) {
      final child = seg == kWebFImplicitLayerSegment
          ? node.ensureImplicitChild()
          : node.ensureChild(seg);
      key.add(child.siblingIndex);
      node = child;
    }
    return key;
  }

  void declareAll(List<List<String>> paths) {
    for (final p in paths) {
      if (p.isEmpty) continue;
      declare(p);
    }
  }

  static int compareLayerOrderNormal(CSSRule a, CSSRule b) {
    final ak = a.layerOrderKey;
    final bk = b.layerOrderKey;
    if (ak == null && bk == null) return 0;
    // Unlayered is above all layers for normal declarations.
    if (ak == null) return 1;
    if (bk == null) return -1;

    final minLen = ak.length < bk.length ? ak.length : bk.length;
    for (var i = 0; i < minLen; i++) {
      final diff = ak[i] - bk[i];
      if (diff != 0) return diff;
    }
    // Parent layer comes before its sublayers.
    return ak.length - bk.length;
  }
}

class _LayerNode {
  final String name;
  final int siblingIndex;
  final List<_LayerNode> _childrenInOrder = <_LayerNode>[];
  final Map<String, _LayerNode> _childrenByName = <String, _LayerNode>{};
  _LayerNode? _implicitChild;

  _LayerNode({required this.name, required this.siblingIndex});

  _LayerNode ensureChild(String seg) {
    final existing = _childrenByName[seg];
    if (existing != null) return existing;
    final created =
        _LayerNode(name: seg, siblingIndex: _childrenInOrder.length);
    _childrenInOrder.add(created);
    _childrenByName[seg] = created;
    return created;
  }

  _LayerNode ensureImplicitChild() {
    return _implicitChild ??= _LayerNode(
      name: kWebFImplicitLayerSegment,
      siblingIndex: _kImplicitLayerSiblingIndex,
    );
  }

  void reset() {
    _childrenInOrder.clear();
    _childrenByName.clear();
    _implicitChild = null;
  }
}

int compareStyleRulesForCascade(CSSStyleRule a, CSSStyleRule b,
    {required bool important}) {
  var layerCmp = CascadeLayerTree.compareLayerOrderNormal(a, b);
  if (important) layerCmp = -layerCmp;
  if (layerCmp != 0) return layerCmp;

  final specCmp = a.selectorGroup.matchSpecificity
      .compareTo(b.selectorGroup.matchSpecificity);
  if (specCmp != 0) return specCmp;

  return a.position.compareTo(b.position);
}

CSSStyleDeclaration cascadeMatchedStyleRules(List<CSSStyleRule> rules) {
  final declaration = CSSStyleDeclaration();
  if (rules.isEmpty) return declaration;

  final normalOrder = List<CSSStyleRule>.from(rules)
    ..sort((a, b) => compareStyleRulesForCascade(a, b, important: false));
  for (final r in normalOrder) {
    declaration.unionByImportance(r.declaration, important: false);
  }

  final importantOrder = List<CSSStyleRule>.from(rules)
    ..sort((a, b) => compareStyleRulesForCascade(a, b, important: true));
  for (final r in importantOrder) {
    declaration.unionByImportance(r.declaration, important: true);
  }

  return declaration;
}
