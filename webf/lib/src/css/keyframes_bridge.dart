/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/foundation/logger.dart';

class _RegisteredKeyframes {
  final int sheetId;
  final CSSKeyframesRule rule;
  _RegisteredKeyframes(this.sheetId, this.rule);
}

/// Bridge-side registry for @keyframes rules parsed on the native (C++) side.
///
/// - Stores keyframes per name with registration order.
/// - Tracks which stylesheet (sheetId) provided which rule so we can unregister on sheet removal.
/// - Updates the document RuleSet so animation-name lookups can find these keyframes.
class CSSKeyframesBridge {
  // name -> [registrations...]
  static final Map<String, List<_RegisteredKeyframes>> _byName = {};
  // sheetId -> [registrations...]
  static final Map<int, List<_RegisteredKeyframes>> _bySheet = {};

  static void registerFromBridge({
    required double contextId,
    required int sheetId,
    required String name,
    required String cssText,
    required bool isPrefixed,
  }) {
    final controller = WebFController.getControllerOfJSContextId(contextId);
    if (controller == null) return;
    final document = controller.view.document;

    // Parse the incoming @keyframes cssText into a CSSKeyframesRule using the Dart CSS parser.
    // We keep href null here since there should be no relative URLs inside @keyframes blocks.
    try {
      final rules = CSSParser(cssText, href: document.styleSheets.isNotEmpty ? document.styleSheets.first.href : null)
          .parseRules(
              windowWidth: document.viewport?.viewportSize.width ?? document.preloadViewportSize?.width ?? -1,
              windowHeight: document.viewport?.viewportSize.height ?? document.preloadViewportSize?.height ?? -1,
              isDarkMode: controller.view.rootController.isDarkMode ?? false);

      for (final rule in rules) {
        if (rule is CSSKeyframesRule) {
          // Register
          final reg = _RegisteredKeyframes(sheetId, rule);
          _byName.putIfAbsent(name, () => <_RegisteredKeyframes>[]).add(reg);
          _bySheet.putIfAbsent(sheetId, () => <_RegisteredKeyframes>[]).add(reg);

          // Update document ruleset for lookup by animation-name
          document.ruleSet.keyframesRules[name] = rule;

          cssLogger.info('[keyframes][register] ctx=$contextId sheet=$sheetId name=$name frames=${rule.keyframes.length}');
        }
      }
    } catch (e, s) {
      cssLogger.severe('[keyframes][register] error: $e\n$s');
    }
  }

  static void unregisterFromSheet({
    required double contextId,
    required int sheetId,
  }) {
    final controller = WebFController.getControllerOfJSContextId(contextId);
    if (controller == null) return;
    final document = controller.view.document;

    final regs = _bySheet.remove(sheetId);
    if (regs == null) return;

    for (final reg in regs) {
      final String name = reg.rule.name;
      final list = _byName[name];
      if (list != null) {
        list.removeWhere((r) => r.sheetId == sheetId);
        if (list.isEmpty) {
          _byName.remove(name);
          // Remove from document ruleset if no other registration for this name exists.
          document.ruleSet.keyframesRules.remove(name);
        } else {
          // Revert to the most recently registered remaining rule.
          document.ruleSet.keyframesRules[name] = list.last.rule;
        }
      }
    }
  }
}
