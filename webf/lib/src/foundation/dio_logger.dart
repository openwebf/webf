/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert' as convert;

import 'package:dio/dio.dart';

const _timeStampKey = '_pdl_timeStamp_';

/// A pretty logger for Dio
/// it will print request/response info with a pretty format
/// and also can filter the request/response by [RequestOptions]
class PrettyDioLogger extends Interceptor {
  /// Print request [Options]
  final bool request;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// InitialTab count to logPrint json response
  static const int kInitialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  /// Print compact json response
  final bool compact;

  /// Width size per logPrint
  final int maxWidth;

  /// Max characters to log for response body; null means unlimited.
  final int? maxBodyLength;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  final void Function(Object object) logPrint;

  /// Filter request/response by [RequestOptions]
  final bool Function(RequestOptions options, FilterArgs args)? filter;

  /// Enable logPrint
  final bool enabled;

  /// Default constructor
  PrettyDioLogger({
    this.request = true,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.logPrint = print,
    this.filter,
    this.enabled = true,
    this.maxBodyLength,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final extra = Map.of(options.extra);
    options.extra[_timeStampKey] = DateTime.timestamp().millisecondsSinceEpoch;

    if (!enabled ||
        (filter != null &&
            !filter!(options, FilterArgs(false, options.data)))) {
      handler.next(options);
      return;
    }

    if (request) {
      _printRequestHeader(options);
    }
    if (requestHeader) {
      _printMapAsTable(options.queryParameters, header: 'Query Parameters');
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      if (options.contentType != null) {
        requestHeaders['contentType'] = options.contentType?.toString();
      }
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      if (options.connectTimeout != null) {
        requestHeaders['connectTimeout'] = options.connectTimeout?.toString();
      }
      if (options.receiveTimeout != null) {
        requestHeaders['receiveTimeout'] = options.receiveTimeout?.toString();
      }
      _printMapAsTable(requestHeaders, header: 'Headers');
      _printMapAsTable(extra, header: 'Extras');
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) _printMapAsTable(options.data as Map?, header: 'Body');
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
        } else {
          _printBlock(data.toString());
        }
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled ||
        (filter != null &&
            !filter!(
                err.requestOptions, FilterArgs(true, err.response?.data)))) {
      handler.next(err);
      return;
    }

    final triggerTime = err.requestOptions.extra[_timeStampKey];

    if (error) {
      if (err.type == DioExceptionType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        int diff = 0;
        if (triggerTime is int) {
          diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
        }
        _printBoxed(
            header:
            'DioError ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage} ║ Time: $diff ms',
            text: uri.toString());
        _printLine('╚');
        logPrint('');
      } else if (err.error != null) {
        _printBoxed(header: 'DioError', text: err.error.toString());
      } else {
        _printBoxed(header: 'DioError ║ ${err.type}', text: err.message);
      }
    }
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled ||
        (filter != null &&
            !filter!(
                response.requestOptions, FilterArgs(true, response.data)))) {
      handler.next(response);
      return;
    }

    final triggerTime = response.requestOptions.extra[_timeStampKey];

    int diff = 0;
    if (triggerTime is int) {
      diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
    }
    _printResponseHeader(response, diff);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers
          .forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(responseHeaders, header: 'Headers');
    }

    if (responseBody) {
      logPrint('╔ Body');
      logPrint('║');
      _printResponse(response);
      logPrint('║');
      _printLine('╚');
    }
    handler.next(response);
  }

  void _printBoxed({String? header, String? text}) {
    logPrint('');
    logPrint('╔╣ $header');
    logPrint('║  $text');
    _printLine('╚');
  }

  void _printResponse(Response response) {
    final data = response.data;
    if (data == null) return;

    final contentType = response.headers.value(Headers.contentTypeHeader)?.toLowerCase();

    // Prefer content-type to decide how to print
    if (_isJsonContentType(contentType)) {
      if (data is Map) {
        if (maxBodyLength != null) {
          final s = _truncateBody(_encodeJsonCompact(data));
          _printBlock(s);
        } else {
          _printPrettyMap(data);
        }
        return;
      }
      if (data is List) {
        if (maxBodyLength != null) {
          final s = _truncateBody(_encodeJsonCompact(data));
          _printBlock(s);
        } else {
          logPrint('║${_indent()}[');
          _printList(data);
          logPrint('║${_indent()}]');
        }
        return;
      }
      if (data is String) {
        try {
          final decoded = convert.jsonDecode(data);
          if (maxBodyLength != null) {
            final s = _truncateBody(_encodeJsonCompact(decoded));
            _printBlock(s);
          } else if (decoded is Map) {
            _printPrettyMap(decoded);
          } else if (decoded is List) {
            logPrint('║${_indent()}[');
            _printList(decoded);
            logPrint('║${_indent()}]');
          } else {
            _printBlock(data);
          }
        } catch (_) {
          _printBlock(_truncateBody(data));
        }
        return;
      }
      if (data is Uint8List) {
        final enc = _encodingForContentType(contentType);
        final text = enc.decode(data);
        try {
          final decoded = convert.jsonDecode(text);
          if (maxBodyLength != null) {
            final s = _truncateBody(_encodeJsonCompact(decoded));
            _printBlock(s);
          } else if (decoded is Map) {
            _printPrettyMap(decoded);
          } else if (decoded is List) {
            logPrint('║${_indent()}[');
            _printList(decoded);
            logPrint('║${_indent()}]');
          } else {
            _printBlock(text);
          }
        } catch (_) {
          _printBlock(_truncateBody(text));
        }
        return;
      }
      _printBlock(_truncateBody(data.toString()));
      return;
    }

    if (_isTextContentType(contentType)) {
      if (data is Uint8List) {
        final enc = _encodingForContentType(contentType);
        _printBlock(_truncateBody(enc.decode(data)));
      } else {
        _printBlock(_truncateBody(data.toString()));
      }
      return;
    }

    // Binary or unknown content types: avoid logging full body
    if (data is Uint8List) {
      final ct = contentType ?? 'unknown';
      final len = data.length;
      logPrint('║${_indent()}<binary body omitted> ($ct, $len bytes)');
      return;
    }

    // Fallback
    _printBlock(_truncateBody(data.toString()));
  }

  void _printResponseHeader(Response response, int responseTime) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
        header:
        'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}  ║ Time: $responseTime ms',
        text: uri.toString());
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString());
  }

  void _printLine([String pre = '', String suf = '╝']) =>
      logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(msg);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logPrint((i >= 0 ? '║ ' : '') +
          msg.substring(i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  void _printPrettyMap(
      Map data, {
        int initialTab = kInitialTab,
        bool isListItem = false,
        bool isLast = false,
      }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    for (var index = 0; index < data.length; index++) {
      final isLast = index == data.length - 1;
      final key = '"${data.keys.elementAt(index)}"';
      dynamic value = data[data.keys.elementAt(index)];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('║${_indent(tabs)} $key: {');
          _printPrettyMap(value, initialTab: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('║${_indent(tabs)} $key: ${value.toString()}');
        } else {
          logPrint('║${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
          logPrint('║${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            final multilineKey = i == 0 ? "$key:" : "";
            logPrint(
                '║${_indent(tabs)} $multilineKey ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          logPrint('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    }

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = kInitialTab}) {
    for (var i = 0; i < list.length; i++) {
      final element = list[i];
      final isLast = i == list.length - 1;
      if (element is Map) {
        if (compact && _canFlattenMap(element)) {
          logPrint('║${_indent(tabs)}  $element${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            element,
            initialTab: tabs + 1,
            isListItem: true,
            isLast: isLast,
          );
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $element${isLast ? '' : ','}');
      }
    }
  }

  bool _canFlattenMap(Map map) {
    return map.values
        .where((dynamic val) => val is Map || val is List)
        .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    for (final entry in map.entries) {
      _printKV(entry.key.toString(), entry.value);
    }
    _printLine('╚');
  }

  String _truncateBody(String input) {
    if (maxBodyLength == null) return input;
    if (input.length <= maxBodyLength!) return input;
    final omitted = input.length - maxBodyLength!;
    return '${input.substring(0, maxBodyLength!)}… [truncated $omitted chars]';
  }

  String _encodeJsonCompact(dynamic data) {
    try {
      return const convert.JsonEncoder().convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  bool _isJsonContentType(String? contentType) {
    if (contentType == null) return false;
    return contentType.contains('application/json') ||
        contentType.contains('+json');
  }

  bool _isTextContentType(String? contentType) {
    if (contentType == null) return false;
    return contentType.startsWith('text/') ||
        contentType.contains('xml') ||
        contentType.contains('+xml') ||
        contentType.contains('html') ||
        contentType.contains('javascript') ||
        contentType.contains('css') ||
        contentType.contains('csv') ||
        contentType.contains('x-www-form-urlencoded');
  }

  convert.Encoding _encodingForContentType(String? contentType) {
    if (contentType == null) return convert.utf8;
    final match = RegExp(r'charset=([^;]+)', caseSensitive: false).firstMatch(contentType);
    final name = match?.group(1)?.trim();
    return convert.Encoding.getByName(name?.toLowerCase() ?? '') ?? convert.utf8;
  }
}

/// Filter arguments
class FilterArgs {
  /// If the filter is for a request or response
  final bool isResponse;

  /// if the [isResponse] is false, the data is the [RequestOptions.data]
  /// if the [isResponse] is true, the data is the [Response.data]
  final dynamic data;

  /// Returns true if the data is a string
  bool get hasStringData => data is String;

  /// Returns true if the data is a map
  bool get hasMapData => data is Map;

  /// Returns true if the data is a list
  bool get hasListData => data is List;

  /// Returns true if the data is a Uint8List
  bool get hasUint8ListData => data is Uint8List;

  /// Returns true if the data is a json data
  bool get hasJsonData => hasMapData || hasListData;

  /// Default constructor
  const FilterArgs(this.isResponse, this.data);
}
