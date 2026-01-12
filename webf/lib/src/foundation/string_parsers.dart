/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

@pragma('vm:prefer-inline')
bool isAsciiWhitespaceCodeUnit(int codeUnit) {
  // Tab, LF, VT, FF, CR, Space
  return codeUnit == 0x09 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0B ||
      codeUnit == 0x0C ||
      codeUnit == 0x0D ||
      codeUnit == 0x20;
}

List<String> splitByAsciiWhitespace(String input) {
  final int len = input.length;
  if (len == 0) return const <String>[];

  final List<String> out = <String>[];
  int i = 0;
  while (i < len && isAsciiWhitespaceCodeUnit(input.codeUnitAt(i))) {
    i++;
  }
  if (i >= len) return const <String>[];

  int start = i;
  while (i < len) {
    final int cu = input.codeUnitAt(i);
    if (isAsciiWhitespaceCodeUnit(cu)) {
      if (start < i) out.add(input.substring(start, i));
      while (i < len && isAsciiWhitespaceCodeUnit(input.codeUnitAt(i))) {
        i++;
      }
      start = i;
      continue;
    }
    i++;
  }
  if (start < len) out.add(input.substring(start));
  return out;
}

/// Split on ASCII whitespace, but do not split inside parentheses `()`/`[]`
/// or within single/double quotes.
List<String> splitByAsciiWhitespacePreservingGroups(String input) {
  if (input.isEmpty) return const <String>[];

  final List<String> out = <String>[];
  final StringBuffer buf = StringBuffer();
  int parenDepth = 0;
  int bracketDepth = 0;
  String? quote;
  bool escape = false;

  void flush() {
    if (buf.isEmpty) return;
    final String token = buf.toString().trim();
    buf.clear();
    if (token.isNotEmpty) out.add(token);
  }

  for (int i = 0; i < input.length; i++) {
    final String ch = input[i];
    final int cu = input.codeUnitAt(i);

    if (quote != null) {
      buf.write(ch);
      if (escape) {
        escape = false;
      } else if (ch == '\\') {
        escape = true;
      } else if (ch == quote) {
        quote = null;
      }
      continue;
    }

    if (ch == '"' || ch == '\'') {
      quote = ch;
      buf.write(ch);
      continue;
    }

    if (ch == '(') {
      parenDepth++;
      buf.write(ch);
      continue;
    }
    if (ch == ')') {
      parenDepth = parenDepth > 0 ? parenDepth - 1 : 0;
      buf.write(ch);
      continue;
    }
    if (ch == '[') {
      bracketDepth++;
      buf.write(ch);
      continue;
    }
    if (ch == ']') {
      bracketDepth = bracketDepth > 0 ? bracketDepth - 1 : 0;
      buf.write(ch);
      continue;
    }

    if (parenDepth == 0 && bracketDepth == 0 && isAsciiWhitespaceCodeUnit(cu)) {
      flush();
      continue;
    }

    buf.write(ch);
  }

  flush();
  return out;
}

List<String> splitByTopLevelDelimiter(String input, int delimiterCodeUnit) {
  if (input.isEmpty) return const <String>[];

  final List<String> out = <String>[];
  final StringBuffer buf = StringBuffer();
  int parenDepth = 0;
  int bracketDepth = 0;
  String? quote;
  bool escape = false;

  void flush() {
    final String token = buf.toString().trim();
    buf.clear();
    out.add(token);
  }

  for (int i = 0; i < input.length; i++) {
    final String ch = input[i];
    final int cu = input.codeUnitAt(i);

    if (quote != null) {
      buf.write(ch);
      if (escape) {
        escape = false;
      } else if (ch == '\\') {
        escape = true;
      } else if (ch == quote) {
        quote = null;
      }
      continue;
    }

    if (ch == '"' || ch == '\'') {
      quote = ch;
      buf.write(ch);
      continue;
    }

    if (ch == '(') {
      parenDepth++;
      buf.write(ch);
      continue;
    }
    if (ch == ')') {
      parenDepth = parenDepth > 0 ? parenDepth - 1 : 0;
      buf.write(ch);
      continue;
    }
    if (ch == '[') {
      bracketDepth++;
      buf.write(ch);
      continue;
    }
    if (ch == ']') {
      bracketDepth = bracketDepth > 0 ? bracketDepth - 1 : 0;
      buf.write(ch);
      continue;
    }

    if (parenDepth == 0 && bracketDepth == 0 && cu == delimiterCodeUnit) {
      flush();
      continue;
    }

    buf.write(ch);
  }

  flush();
  return out;
}

String removeWhitespaceAroundCommas(String input) {
  if (input.isEmpty) return input;
  final List<int> out = <int>[];
  bool pendingComma = false;

  for (int i = 0; i < input.length; i++) {
    final int cu = input.codeUnitAt(i);
    if (cu == 0x2C /* , */) {
      // Remove trailing ASCII whitespace already emitted.
      while (out.isNotEmpty && isAsciiWhitespaceCodeUnit(out.last)) {
        out.removeLast();
      }
      out.add(cu);
      pendingComma = true;
      continue;
    }
    if (pendingComma && isAsciiWhitespaceCodeUnit(cu)) {
      continue;
    }
    pendingComma = false;
    out.add(cu);
  }
  return String.fromCharCodes(out);
}

String kebabizeCamelCase(String input) {
  if (input.isEmpty) return input;
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    final int cu = input.codeUnitAt(i);
    if (cu >= 0x41 && cu <= 0x5A) {
      buf.writeCharCode(0x2D); // '-'
      buf.writeCharCode(cu + 0x20);
    } else {
      buf.writeCharCode(cu);
    }
  }
  return buf.toString();
}

String camelizeKebabCase(String input) {
  if (input.isEmpty) return input;
  final StringBuffer buf = StringBuffer();
  bool upperNext = false;
  for (int i = 0; i < input.length; i++) {
    final int cu = input.codeUnitAt(i);
    if (cu == 0x2D /* - */) {
      upperNext = true;
      continue;
    }
    if (upperNext && cu >= 0x61 && cu <= 0x7A) {
      buf.writeCharCode(cu - 0x20);
    } else {
      buf.writeCharCode(cu);
    }
    upperNext = false;
  }
  return buf.toString();
}

List<String> splitByUppercaseBoundary(String input) {
  final int len = input.length;
  if (len == 0) return const <String>[];
  final List<String> out = <String>[];
  int start = 0;
  for (int i = 0; i < len; i++) {
    final int cu = input.codeUnitAt(i);
    final bool isUpper = cu >= 0x41 && cu <= 0x5A;
    if (isUpper) {
      out.add(input.substring(start, i));
      start = i;
    }
  }
  out.add(input.substring(start));
  return out;
}

String collapseCrlfToSingleSpace(String input) {
  if (input.isEmpty) return input;
  final StringBuffer buf = StringBuffer();
  bool inNewlines = false;
  for (int i = 0; i < input.length; i++) {
    final int cu = input.codeUnitAt(i);
    if (cu == 0x0A || cu == 0x0D) {
      if (!inNewlines) {
        buf.write(' ');
        inNewlines = true;
      }
      continue;
    }
    inNewlines = false;
    buf.writeCharCode(cu);
  }
  return buf.toString();
}

String encodeNewlinesAsPercentCrlf(String input) {
  if (input.isEmpty) return input;
  final StringBuffer buf = StringBuffer();
  int i = 0;
  while (i < input.length) {
    final int cu = input.codeUnitAt(i);
    if (cu == 0x0D /* \r */) {
      // Collapse CRLF and CR into CRLF.
      if (i + 1 < input.length && input.codeUnitAt(i + 1) == 0x0A /* \n */) {
        i += 2;
      } else {
        i++;
      }
      buf.write('%0D%0A');
      continue;
    }
    if (cu == 0x0A /* \n */) {
      i++;
      buf.write('%0D%0A');
      continue;
    }
    buf.writeCharCode(cu);
    i++;
  }
  return buf.toString();
}

String? parseHeaderParameter(String input, String keyLowercase) {
  final String lower = input.toLowerCase();
  int idx = lower.indexOf(keyLowercase);
  if (idx == -1) return null;

  // Ensure the match starts at a parameter boundary.
  if (idx > 0) {
    final int prev = lower.codeUnitAt(idx - 1);
    if (prev != 0x3B /* ; */ && !isAsciiWhitespaceCodeUnit(prev)) {
      idx = lower.indexOf(keyLowercase, idx + 1);
      if (idx == -1) return null;
    }
  }

  int start = idx + keyLowercase.length;
  // keyLowercase should include '=' (e.g. 'charset=')
  if (start > input.length) return null;

  int end = start;
  while (end < input.length) {
    final int cu = input.codeUnitAt(end);
    if (cu == 0x3B /* ; */) break;
    end++;
  }
  String value = input.substring(start, end).trim();
  if (value.length >= 2) {
    final int first = value.codeUnitAt(0);
    final int last = value.codeUnitAt(value.length - 1);
    if ((first == 0x22 && last == 0x22) || (first == 0x27 && last == 0x27)) {
      value = value.substring(1, value.length - 1);
    }
  }
  return value.isEmpty ? null : value;
}

String? extractInlineStylePropertyValue(String styleAttr, String propertyName) {
  if (styleAttr.isEmpty || propertyName.isEmpty) return null;

  final String lowerStyle = styleAttr.toLowerCase();
  final String lowerProp = propertyName.toLowerCase();

  int searchFrom = 0;
  while (true) {
    final int idx = lowerStyle.indexOf(lowerProp, searchFrom);
    if (idx == -1) return null;

    // Ensure property boundary: start or preceded by whitespace/semicolon.
    if (idx > 0) {
      final int prev = lowerStyle.codeUnitAt(idx - 1);
      if (prev != 0x3B /* ; */ && !isAsciiWhitespaceCodeUnit(prev)) {
        searchFrom = idx + 1;
        continue;
      }
    }

    int i = idx + lowerProp.length;
    while (i < styleAttr.length && isAsciiWhitespaceCodeUnit(styleAttr.codeUnitAt(i))) {
      i++;
    }
    if (i >= styleAttr.length || styleAttr.codeUnitAt(i) != 0x3A /* : */) {
      searchFrom = idx + 1;
      continue;
    }

    i++; // skip ':'
    while (i < styleAttr.length && isAsciiWhitespaceCodeUnit(styleAttr.codeUnitAt(i))) {
      i++;
    }
    if (i >= styleAttr.length) return '';

    final int valueStart = i;
    int parenDepth = 0;
    String? quote;
    bool escape = false;

    while (i < styleAttr.length) {
      final String ch = styleAttr[i];
      final int cu = styleAttr.codeUnitAt(i);

      if (quote != null) {
        if (escape) {
          escape = false;
        } else if (ch == '\\') {
          escape = true;
        } else if (ch == quote) {
          quote = null;
        }
        i++;
        continue;
      }

      if (ch == '"' || ch == '\'') {
        quote = ch;
        i++;
        continue;
      }

      if (cu == 0x28 /* ( */) {
        parenDepth++;
        i++;
        continue;
      }
      if (cu == 0x29 /* ) */) {
        parenDepth = parenDepth > 0 ? parenDepth - 1 : 0;
        i++;
        continue;
      }

      if (cu == 0x3B /* ; */ && parenDepth == 0) {
        break;
      }
      i++;
    }

    return styleAttr.substring(valueStart, i).trim();
  }
}

/// Replace `var(...)` function calls in a CSS value string using a lightweight
/// scanner that supports nested parentheses and quoted substrings.
String replaceCssVarFunctions(String input, String Function(String varFunctionText) replacer) {
  if (!input.contains('var(')) return input;
  final int len = input.length;
  final StringBuffer out = StringBuffer();
  int i = 0;

  while (i < len) {
    final int idx = input.indexOf('var(', i);
    if (idx == -1) {
      out.write(input.substring(i));
      break;
    }
    out.write(input.substring(i, idx));

    final int open = idx + 3;
    if (open >= len || input.codeUnitAt(open) != 0x28 /* ( */) {
      // Should not happen, but fall back to literal copy.
      out.write('var');
      i = open;
      continue;
    }

    int depth = 0;
    String? quote;
    bool escape = false;
    int j = open;
    for (; j < len; j++) {
      final String ch = input[j];
      final int cu = input.codeUnitAt(j);

      if (quote != null) {
        if (escape) {
          escape = false;
        } else if (ch == '\\') {
          escape = true;
        } else if (ch == quote) {
          quote = null;
        }
        continue;
      }

      if (ch == '"' || ch == '\'') {
        quote = ch;
        continue;
      }

      if (cu == 0x28 /* ( */) {
        depth++;
      } else if (cu == 0x29 /* ) */) {
        depth--;
        if (depth == 0) {
          final String varText = input.substring(idx, j + 1);
          out.write(replacer(varText));
          i = j + 1;
          break;
        }
      }
    }

    if (j >= len) {
      // Unbalanced; append remainder as-is.
      out.write(input.substring(idx));
      break;
    }
  }

  return out.toString();
}

/// Same as [replaceCssVarFunctions], but provides the match range as UTF-16
/// code unit indices: `[start, end)` in the original input.
String replaceCssVarFunctionsIndexed(
  String input,
  String Function(String varFunctionText, int start, int end) replacer,
) {
  if (!input.contains('var(')) return input;
  final int len = input.length;
  final StringBuffer out = StringBuffer();
  int i = 0;

  while (i < len) {
    final int idx = input.indexOf('var(', i);
    if (idx == -1) {
      out.write(input.substring(i));
      break;
    }
    out.write(input.substring(i, idx));

    final int open = idx + 3;
    if (open >= len || input.codeUnitAt(open) != 0x28 /* ( */) {
      out.write('var');
      i = open;
      continue;
    }

    int depth = 0;
    String? quote;
    bool escape = false;
    int j = open;
    for (; j < len; j++) {
      final String ch = input[j];
      final int cu = input.codeUnitAt(j);

      if (quote != null) {
        if (escape) {
          escape = false;
        } else if (ch == '\\') {
          escape = true;
        } else if (ch == quote) {
          quote = null;
        }
        continue;
      }

      if (ch == '"' || ch == '\'') {
        quote = ch;
        continue;
      }

      if (cu == 0x28 /* ( */) {
        depth++;
      } else if (cu == 0x29 /* ) */) {
        depth--;
        if (depth == 0) {
          final int end = j + 1;
          final String varText = input.substring(idx, end);
          out.write(replacer(varText, idx, end));
          i = end;
          break;
        }
      }
    }

    if (j >= len) {
      out.write(input.substring(idx));
      break;
    }
  }

  return out.toString();
}
