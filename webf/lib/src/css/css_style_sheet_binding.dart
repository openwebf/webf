/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

/// A Dart-side CSSOM wrapper for [CSSStyleSheet] that is exposed to JavaScript
/// via WebF's binding object mechanism (DartBindingObject on the JS side).
///
/// This is used by `document.styleSheets` when Blink CSS is disabled.
class CSSStyleSheetBinding extends DynamicBindingObject with StaticDefinedBindingObject {
  final Document _document;
  final CSSStyleSheet _sheet;
  final Pointer<NativeBindingObject> _pointer;

  final Expando<WeakReference<CSSRuleBindingBase>> _ruleBindingCache = Expando('cssRuleBinding');
  WeakReference<CSSRuleListBinding>? _cssRulesRef;

  CSSStyleSheetBinding(BindingContext super.context, this._document, this._sheet) : _pointer = context.pointer;

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  Document get document => _document;

  CSSStyleSheet get sheet => _sheet;

  bool get disabled => _sheet.disabled;

  set disabled(bool value) {
    if (_sheet.disabled == value) return;
    _sheet.disabled = value;
    _scheduleStyleUpdate();
  }

  String get href => _sheet.href ?? '';

  String get type => _sheet.type;

  CSSRuleListBinding get cssRules {
    CSSRuleListBinding? existing = _cssRulesRef?.target;
    if (existing == null || isBindingObjectDisposed(existing.pointer)) {
      existing = CSSRuleListBinding(
        BindingContext(ownerView, contextId!, allocateNewBindingObject()),
        this,
        () => _sheet.cssRules,
      );
      _cssRulesRef = WeakReference(existing);
    }
    existing.refresh();
    return existing;
  }

  int insertRule(String text, int index) {
    final double windowWidth = _document.viewport?.viewportSize.width ?? _document.preloadViewportSize?.width ?? -1;
    final double windowHeight = _document.viewport?.viewportSize.height ?? _document.preloadViewportSize?.height ?? -1;
    final bool isDarkMode = ownerView.rootController.isDarkMode ?? false;

    final int insertedIndex = _sheet.insertRule(
      text,
      index,
      windowWidth: windowWidth,
      windowHeight: windowHeight,
      isDarkMode: isDarkMode,
    );

    cssRules.refresh();
    _scheduleStyleUpdate();
    return insertedIndex;
  }

  void deleteRule(int index) {
    _sheet.deleteRule(index);
    cssRules.refresh();
    _scheduleStyleUpdate();
  }

  void replaceSync(String text) {
    final double windowWidth = _document.viewport?.viewportSize.width ?? _document.preloadViewportSize?.width ?? -1;
    final double windowHeight = _document.viewport?.viewportSize.height ?? _document.preloadViewportSize?.height ?? -1;
    final bool? isDarkMode = ownerView.rootController.isDarkMode;
    _sheet.replaceSync(text, windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: isDarkMode);
    cssRules.refresh();
    _scheduleStyleUpdate();
  }

  CSSRuleBindingBase? ruleAt(int index) {
    if (index < 0 || index >= _sheet.cssRules.length) return null;
    return _ensureRuleBinding(_sheet.cssRules[index]);
  }

  CSSRuleBindingBase _ensureRuleBinding(CSSRule rule) {
    final CSSRuleBindingBase? existing = _ruleBindingCache[rule]?.target;
    if (existing != null && !isBindingObjectDisposed(existing.pointer)) {
      return existing;
    }
    final BindingContext ctx = BindingContext(ownerView, contextId!, allocateNewBindingObject());
    final CSSRuleBindingBase binding;
    if (rule is CSSLayerBlockRule) {
      binding = CSSLayerBlockRuleBinding(ctx, this, rule);
    } else if (rule is CSSLayerStatementRule) {
      binding = CSSLayerStatementRuleBinding(ctx, rule);
    } else {
      binding = CSSRuleBinding(ctx, rule);
    }
    _ruleBindingCache[rule] = WeakReference(binding);
    return binding;
  }

  void scheduleStyleUpdateForCSSOM() => _scheduleStyleUpdate();

  void _scheduleStyleUpdate() {
    // Mark this stylesheet as pending and force a style flush so selector
    // matching and cascade order updates are visible to JS (e.g. getComputedStyle).
    _document.styleNodeManager.appendPendingStyleSheet(_sheet);
    _document.updateStyleIfNeeded();
  }

  static final StaticDefinedBindingPropertyMap _cssStyleSheetProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (sheet) => castToType<CSSStyleSheetBinding>(sheet).disabled,
      setter: (sheet, value) => castToType<CSSStyleSheetBinding>(sheet).disabled = castToType<bool>(value),
    ),
    'href': StaticDefinedBindingProperty(getter: (sheet) => castToType<CSSStyleSheetBinding>(sheet).href),
    'type': StaticDefinedBindingProperty(getter: (sheet) => castToType<CSSStyleSheetBinding>(sheet).type),
    'cssRules': StaticDefinedBindingProperty(getter: (sheet) => castToType<CSSStyleSheetBinding>(sheet).cssRules),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _cssStyleSheetProperties];

  static final StaticDefinedSyncBindingObjectMethodMap _cssStyleSheetMethods = {
    'insertRule': StaticDefinedSyncBindingObjectMethod(
      call: (sheet, args) => castToType<CSSStyleSheetBinding>(sheet)
          .insertRule(castToType<String>(args[0]), castToType<int>(args[1])),
    ),
    'deleteRule': StaticDefinedSyncBindingObjectMethod(
      call: (sheet, args) => castToType<CSSStyleSheetBinding>(sheet).deleteRule(castToType<int>(args[0])),
    ),
    'replaceSync': StaticDefinedSyncBindingObjectMethod(
      call: (sheet, args) => castToType<CSSStyleSheetBinding>(sheet).replaceSync(castToType<String>(args[0])),
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _cssStyleSheetMethods];
}

class CSSRuleListBinding extends DynamicBindingObject with StaticDefinedBindingObject {
  final CSSStyleSheetBinding _sheetBinding;
  final List<CSSRule> Function() _rulesProvider;
  final Pointer<NativeBindingObject> _pointer;

  CSSRuleListBinding(BindingContext super.context, this._sheetBinding, this._rulesProvider) : _pointer = context.pointer {
    refresh();
  }

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  @override
  int get length => _rulesProvider().length;

  CSSRuleBindingBase? item(int index) {
    final rules = _rulesProvider();
    if (index < 0 || index >= rules.length) return null;
    return _sheetBinding._ensureRuleBinding(rules[index]);
  }

  void refresh() {
    // Keep numeric properties (0..length-1) in sync so JS indexed access works:
    // `sheet.cssRules[0]` → getProperty('0').
    final props = dynamicProperties;
    props.removeWhere((key, _) => int.tryParse(key) != null);
    for (int i = 0; i < length; i++) {
      final int index = i;
      props['$index'] = BindingObjectProperty(getter: () => item(index));
    }
  }

  static final StaticDefinedBindingPropertyMap _cssRuleListProperties = {
    'length': StaticDefinedBindingProperty(getter: (list) => castToType<CSSRuleListBinding>(list).length),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _cssRuleListProperties];

  static final StaticDefinedSyncBindingObjectMethodMap _cssRuleListMethods = {
    'item': StaticDefinedSyncBindingObjectMethod(
      call: (list, args) => castToType<CSSRuleListBinding>(list).item(castToType<int>(args[0])),
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _cssRuleListMethods];
}

abstract class CSSRuleBindingBase extends DynamicBindingObject with StaticDefinedBindingObject {
  CSSRuleBindingBase(BindingContext context) : super(context);

  String get cssText;
  int get type;

  static final StaticDefinedBindingPropertyMap _cssRuleBaseProperties = {
    'cssText': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSRuleBindingBase>(rule).cssText),
    'type': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSRuleBindingBase>(rule).type),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _cssRuleBaseProperties];
}

class CSSRuleBinding extends CSSRuleBindingBase {
  final CSSRule _rule;
  final Pointer<NativeBindingObject> _pointer;

  CSSRuleBinding(BindingContext context, this._rule)
      : _pointer = context.pointer,
        super(context);

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  @override
  String get cssText => _rule.cssText;

  @override
  int get type => _rule.type;
}

class CSSLayerStatementRuleBinding extends CSSRuleBindingBase {
  final CSSLayerStatementRule _rule;
  final Pointer<NativeBindingObject> _pointer;

  CSSLayerStatementRuleBinding(BindingContext context, this._rule)
      : _pointer = context.pointer,
        super(context);

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  @override
  String get cssText => _rule.cssText;

  @override
  int get type => _rule.type;

  List<String> get nameList => _rule.layerNamePaths.map((p) => p.join('.')).toList(growable: false);

  static final StaticDefinedBindingPropertyMap _layerStatementRuleProperties = {
    'nameList': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSLayerStatementRuleBinding>(rule).nameList),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _layerStatementRuleProperties];
}

class CSSLayerBlockRuleBinding extends CSSRuleBindingBase {
  final CSSStyleSheetBinding _sheetBinding;
  final CSSLayerBlockRule _rule;
  final Pointer<NativeBindingObject> _pointer;

  WeakReference<CSSRuleListBinding>? _cssRulesRef;

  CSSLayerBlockRuleBinding(BindingContext context, this._sheetBinding, this._rule)
      : _pointer = context.pointer,
        super(context);

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  @override
  String get cssText => _rule.cssText;

  @override
  int get type => _rule.type;

  String get name => _rule.name;

  CSSRuleListBinding get cssRules {
    CSSRuleListBinding? existing = _cssRulesRef?.target;
    if (existing == null || isBindingObjectDisposed(existing.pointer)) {
      existing = CSSRuleListBinding(
        BindingContext(ownerView, contextId!, allocateNewBindingObject()),
        _sheetBinding,
        () => _rule.cssRules,
      );
      _cssRulesRef = WeakReference(existing);
    }
    existing.refresh();
    return existing;
  }

  int insertRule(String text, int index) {
    final Document document = _sheetBinding.document;
    final double windowWidth = document.viewport?.viewportSize.width ?? document.preloadViewportSize?.width ?? -1;
    final double windowHeight = document.viewport?.viewportSize.height ?? document.preloadViewportSize?.height ?? -1;
    final bool isDarkMode = ownerView.rootController.isDarkMode ?? false;

    final List<CSSRule> rules = CSSParser(text, href: _sheetBinding.sheet.href)
        .parseRules(windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: isDarkMode);

    if (index < 0 || index > _rule.cssRules.length) {
      throw RangeError.index(index, _rule.cssRules, 'index');
    }

    final List<String> layerPrefix = _rule.layerNamePath;
    for (final r in rules) {
      r.parentStyleSheet = _sheetBinding.sheet;
      _prefixLayerForInsertedRule(r, layerPrefix);
    }

    _rule.cssRules.insertAll(index, rules);
    cssRules.refresh();
    _sheetBinding.scheduleStyleUpdateForCSSOM();
    return index;
  }

  void deleteRule(int index) {
    _rule.deleteRule(index);
    cssRules.refresh();
    _sheetBinding.scheduleStyleUpdateForCSSOM();
  }

  static void _prefixLayerForInsertedRule(CSSRule rule, List<String> layerPrefix) {
    if (layerPrefix.isEmpty) return;
    if (rule is CSSStyleRule) {
      // Inserted rules directly inside a layer block belong to the implicit
      // sublayer so they override nested sublayers in normal cascade.
      if (rule.layerPath.isEmpty) {
        rule.layerPath = <String>[...layerPrefix, kWebFImplicitLayerSegment];
      } else {
        rule.layerPath = <String>[...layerPrefix, ...rule.layerPath];
      }
      return;
    }
    if (rule is CSSLayerStatementRule) {
      // A layer statement inside a layer block refers to sublayers of that layer.
      for (int i = 0; i < rule.layerNamePaths.length; i++) {
        rule.layerNamePaths[i] = <String>[...layerPrefix, ...rule.layerNamePaths[i]];
      }
      return;
    }
    if (rule is CSSLayerBlockRule) {
      // Prefix children style rules so they belong to the nested layer.
      for (final child in rule.cssRules) {
        _prefixExistingLayerPath(child, layerPrefix);
      }
      // NOTE: CSSLayerBlockRule.layerNamePath is immutable; nested @layer blocks
      // inserted via CSSOM are not fully supported beyond style rules.
      // The current CSS cascade behavior is still correct for inserted style rules.
      // (WPT coverage currently focuses on inserting style rules into existing blocks.)
      return;
    }
  }

  static void _prefixExistingLayerPath(CSSRule rule, List<String> layerPrefix) {
    if (layerPrefix.isEmpty) return;
    if (rule is CSSStyleRule) {
      if (rule.layerPath.isEmpty) {
        rule.layerPath = <String>[...layerPrefix, kWebFImplicitLayerSegment];
      } else {
        rule.layerPath = <String>[...layerPrefix, ...rule.layerPath];
      }
    } else if (rule is CSSLayerBlockRule) {
      for (final child in rule.cssRules) {
        _prefixExistingLayerPath(child, layerPrefix);
      }
    }
  }

  static final StaticDefinedBindingPropertyMap _layerBlockRuleProperties = {
    'name': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSLayerBlockRuleBinding>(rule).name),
    'cssRules': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSLayerBlockRuleBinding>(rule).cssRules),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _layerBlockRuleProperties];

  static final StaticDefinedSyncBindingObjectMethodMap _layerBlockRuleMethods = {
    'insertRule': StaticDefinedSyncBindingObjectMethod(
      call: (rule, args) => castToType<CSSLayerBlockRuleBinding>(rule)
          .insertRule(castToType<String>(args[0]), castToType<int>(args[1])),
    ),
    'deleteRule': StaticDefinedSyncBindingObjectMethod(
      call: (rule, args) => castToType<CSSLayerBlockRuleBinding>(rule).deleteRule(castToType<int>(args[0])),
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _layerBlockRuleMethods];
}
