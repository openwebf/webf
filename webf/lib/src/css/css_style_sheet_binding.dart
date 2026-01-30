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

  final Expando<WeakReference<CSSRuleBinding>> _ruleBindingCache = Expando('cssRuleBinding');
  WeakReference<CSSRuleListBinding>? _cssRulesRef;

  CSSStyleSheetBinding(BindingContext super.context, this._document, this._sheet) : _pointer = context.pointer;

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

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

  CSSRuleBinding? ruleAt(int index) {
    if (index < 0 || index >= _sheet.cssRules.length) return null;
    return _ensureRuleBinding(_sheet.cssRules[index]);
  }

  CSSRuleBinding _ensureRuleBinding(CSSRule rule) {
    final CSSRuleBinding? existing = _ruleBindingCache[rule]?.target;
    if (existing != null && !isBindingObjectDisposed(existing.pointer)) {
      return existing;
    }
    final binding = CSSRuleBinding(
      BindingContext(ownerView, contextId!, allocateNewBindingObject()),
      rule,
    );
    _ruleBindingCache[rule] = WeakReference(binding);
    return binding;
  }

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
  final Pointer<NativeBindingObject> _pointer;

  CSSRuleListBinding(BindingContext super.context, this._sheetBinding) : _pointer = context.pointer {
    refresh();
  }

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  @override
  int get length => _sheetBinding.sheet.cssRules.length;

  CSSRuleBinding? item(int index) => _sheetBinding.ruleAt(index);

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

class CSSRuleBinding extends DynamicBindingObject with StaticDefinedBindingObject {
  final CSSRule _rule;
  final Pointer<NativeBindingObject> _pointer;

  CSSRuleBinding(BindingContext super.context, this._rule) : _pointer = context.pointer;

  @override
  Pointer<NativeBindingObject> get pointer => _pointer;

  String get cssText => _rule.cssText;

  int get type => _rule.type;

  static final StaticDefinedBindingPropertyMap _cssRuleProperties = {
    'cssText': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSRuleBinding>(rule).cssText),
    'type': StaticDefinedBindingProperty(getter: (rule) => castToType<CSSRuleBinding>(rule).type),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _cssRuleProperties];
}
