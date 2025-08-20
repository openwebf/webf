/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

final _variableRgbRegExp = RegExp(r'var\(\-\-[\w\-]+\)');

const int _HYPHEN_CODE = 45; // -

// https://www.w3.org/TR/css-variables-1/#defining-variables
class CSSVariable {
  static bool isVariable(String? value) {
    if (value == null) {
      return false;
    }
    return value.length > 2 && value.codeUnitAt(0) == _HYPHEN_CODE && value.codeUnitAt(1) == _HYPHEN_CODE;
  }

  // Try to parse CSSVariable.
  static CSSVariable? tryParse(RenderStyle renderStyle, String propertyValue) {
    // font-size: var(--x);
    // font-size: var(--x, 28px);
    if (CSSFunction.isFunction(propertyValue, functionName: VAR)) {
      List<CSSFunctionalNotation> fns = CSSFunction.parseFunction(propertyValue);
      if (fns.first.args.isNotEmpty) {
        if (fns.first.args.length > 1) {
          // Has default value for CSS Variable.
          dynamic defaultValue = fns.first.args.last.trim();
          CSSVariable? defaultVar = CSSVariable.tryParse(renderStyle, defaultValue);
          if (defaultVar != null) {
            defaultValue = defaultVar;
          }
          return CSSVariable(fns.first.args.first, renderStyle, defaultValue: defaultValue);
        } else {
          return CSSVariable(fns.first.args.first, renderStyle);
        }
      }
    }
    return null;
  }

  static String tryReplaceVariableInString(String input, RenderStyle renderStyle) {
    return input.replaceAllMapped(_variableRgbRegExp, (Match match) {
      String? varString = match[0];
      final variable = CSSVariable.tryParse(renderStyle, varString!);
      final computedValue = variable?.computedValue('');
      return computedValue;
    });
  }

  final String identifier;
  final dynamic defaultValue;
  final RenderStyle _renderStyle;

  CSSVariable(this.identifier, this._renderStyle, {this.defaultValue});

  // Get the lazy calculated CSS resolved value.
  dynamic computedValue(String propertyName) {
    dynamic value = _renderStyle.getCSSVariable(identifier, propertyName);
    if (value == null || value == INITIAL) {
      value = defaultValue;
    }

    if (value == null) {
      return null;
    }

    if (value is CSSVariable) {
      return value.computedValue(propertyName);
    } else if (propertyName.isNotEmpty) {
      return _renderStyle.resolveValue(propertyName, value);
    } else {
      return value;
    }
  }

  @override
  String toString() {
    return 'var($identifier${defaultValue != null ? ', $defaultValue' : ''})';
  }

  @override
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object? other) => other is CSSVariable && other.identifier == identifier;
}
