/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

String perfDescribeElementNode(dynamic element, {int maxClasses = 2}) {
  if (element == null) return 'unknown';

  final StringBuffer buffer = StringBuffer(_perfReadTagName(element));
  final String? id = _perfReadStringProperty(element, 'id');
  if (id != null && id.isNotEmpty) {
    buffer
      ..write('#')
      ..write(_perfSanitizeToken(id, maxLength: 32));
  }

  for (final String className
      in _perfReadClasses(element, maxCount: maxClasses)) {
    buffer
      ..write('.')
      ..write(className);
  }

  return buffer.toString();
}

String perfDescribeElementPath(
  dynamic element, {
  int maxDepth = 4,
  int maxClassesPerSegment = 1,
}) {
  if (element == null) return 'unknown';

  final List<String> segments = <String>[];
  dynamic cursor = element;
  bool truncated = false;

  while (cursor != null) {
    if (segments.length >= maxDepth) {
      truncated = true;
      break;
    }
    segments
        .add(perfDescribeElementNode(cursor, maxClasses: maxClassesPerSegment));
    cursor = _perfReadParentElement(cursor);
  }

  final String path = segments.reversed.join('>');
  return truncated ? '...>$path' : path;
}

String perfFormatMilliseconds(int microseconds, {int fractionDigits = 1}) {
  return (microseconds / 1000.0).toStringAsFixed(fractionDigits);
}

List<String> _perfReadClasses(dynamic element, {required int maxCount}) {
  final List<String> classes = <String>[];
  if (maxCount <= 0) return classes;

  try {
    final dynamic raw = element.classList;
    if (raw is Iterable) {
      for (final dynamic value in raw) {
        if (value is! String || value.isEmpty) continue;
        final String sanitized = _perfSanitizeToken(value, maxLength: 24);
        if (sanitized.isEmpty || classes.contains(sanitized)) continue;
        classes.add(sanitized);
        if (classes.length >= maxCount) return classes;
      }
    }
  } catch (_) {}

  try {
    final dynamic raw = element.className;
    if (raw is String && raw.isNotEmpty) {
      for (final String value in raw.split(RegExp(r'\s+'))) {
        if (value.isEmpty) continue;
        final String sanitized = _perfSanitizeToken(value, maxLength: 24);
        if (sanitized.isEmpty || classes.contains(sanitized)) continue;
        classes.add(sanitized);
        if (classes.length >= maxCount) return classes;
      }
    }
  } catch (_) {}

  return classes;
}

dynamic _perfReadParentElement(dynamic element) {
  try {
    return element.parentElement;
  } catch (_) {
    return null;
  }
}

String _perfReadTagName(dynamic element) {
  final String? tagName = _perfReadStringProperty(element, 'tagName');
  if (tagName != null && tagName.isNotEmpty) {
    return _perfSanitizeToken(tagName.toLowerCase(), maxLength: 20);
  }
  return _perfSanitizeToken(element.runtimeType.toString().toLowerCase(),
      maxLength: 20);
}

String? _perfReadStringProperty(dynamic element, String propertyName) {
  try {
    final dynamic value;
    switch (propertyName) {
      case 'id':
        value = element.id;
        break;
      case 'tagName':
        value = element.tagName;
        break;
      default:
        return null;
    }
    if (value is String) {
      return value;
    }
  } catch (_) {}
  return null;
}

String _perfSanitizeToken(String value, {required int maxLength}) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < value.length; i++) {
    final int codeUnit = value.codeUnitAt(i);
    final bool isDigit = codeUnit >= 48 && codeUnit <= 57;
    final bool isUpper = codeUnit >= 65 && codeUnit <= 90;
    final bool isLower = codeUnit >= 97 && codeUnit <= 122;
    final bool isSafePunctuation =
        codeUnit == 45 || codeUnit == 95 || codeUnit == 58;
    if (isDigit || isUpper || isLower || isSafePunctuation) {
      buffer.writeCharCode(codeUnit);
    } else {
      buffer.write('_');
    }
    if (buffer.length >= maxLength) break;
  }

  if (buffer.isEmpty) {
    return 'x';
  }
  return buffer.toString();
}
