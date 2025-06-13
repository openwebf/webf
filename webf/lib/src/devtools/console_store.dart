/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'dart:collection';
import 'remote_object_service.dart';

/// Log levels matching the C++ implementation
enum ConsoleLogLevel {
  log(1, 'log'),
  warning(2, 'warning'),
  error(3, 'error'),
  debug(4, 'debug'),
  info(5, 'info');

  final int value;
  final String name;
  const ConsoleLogLevel(this.value, this.name);

  static ConsoleLogLevel fromInt(int value) {
    return ConsoleLogLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => ConsoleLogLevel.log,
    );
  }
}

/// Represents a JavaScript value that can be displayed in the console
abstract class ConsoleValue {
  const ConsoleValue();
}

/// A primitive value (string, number, boolean, null, undefined)
class ConsolePrimitiveValue extends ConsoleValue {
  final dynamic value;
  final String type; // 'string', 'number', 'boolean', 'null', 'undefined'
  
  const ConsolePrimitiveValue(this.value, this.type);
  
  String get displayString {
    if (type == 'string') return '"$value"';
    if (type == 'undefined') return 'undefined';
    if (type == 'null') return 'null';
    return value.toString();
  }
}

/// A JavaScript object with properties
class ConsoleObjectValue extends ConsoleValue {
  final String className; // e.g., 'Object', 'Array', 'Date', etc.
  final Map<String, ConsoleValue> properties;
  final bool hasPrototype;
  final int? length; // For arrays
  final String? preview; // Short preview string
  
  const ConsoleObjectValue({
    required this.className,
    required this.properties,
    this.hasPrototype = false,
    this.length,
    this.preview,
  });
  
  String get displayString {
    if (className == 'Array') {
      return 'Array($length)';
    }
    return preview ?? '$className {...}';
  }
}

/// A JavaScript function
class ConsoleFunctionValue extends ConsoleValue {
  final String name;
  final int parameterCount;
  
  const ConsoleFunctionValue({
    required this.name,
    required this.parameterCount,
  });
  
  String get displayString => 'ƒ $name()';
}

/// Remote object types matching the C++ RemoteObjectType enum
enum RemoteObjectType {
  object,
  function,
  array,
  date,
  regExp,
  error,
  promise,
  map,
  set,
  weakMap,
  weakSet,
  symbol,
  bigInt,
  undefined,
  nullType,
  boolean,
  number,
  string
}

/// A remote JavaScript object reference
class ConsoleRemoteObject extends ConsoleValue {
  final String objectId;
  final String className;
  final String description;
  final RemoteObjectType objectType;
  
  const ConsoleRemoteObject({
    required this.objectId,
    required this.className,
    required this.description,
    required this.objectType,
  });
  
  String get displayString => description;
  bool get isExpandable => objectType == RemoteObjectType.object || 
                           objectType == RemoteObjectType.array ||
                           objectType == RemoteObjectType.function ||
                           objectType == RemoteObjectType.map ||
                           objectType == RemoteObjectType.set;
}

/// Represents a single console log entry
class ConsoleLogEntry {
  final int contextId;
  final ConsoleLogLevel level;
  final List<ConsoleValue> args; // Support multiple arguments
  final String message; // Formatted message string
  final DateTime timestamp;
  final String? stackTrace;

  ConsoleLogEntry({
    required this.contextId,
    required this.level,
    required this.args,
    required this.message,
    required this.timestamp,
    this.stackTrace,
  });
}

/// Singleton store for console logs across all WebF contexts
class ConsoleStore {
  ConsoleStore._();
  static final ConsoleStore instance = ConsoleStore._();

  /// Maximum number of logs to store per context
  static const int maxLogsPerContext = 1000;

  /// All console logs grouped by context ID
  final Map<int, Queue<ConsoleLogEntry>> _logsByContext = {};

  /// Add a new console log entry with simple string message (for backward compatibility)
  void addLog(int contextId, int level, String message) {
    addStructuredLog(
      contextId, 
      level, 
      [ConsolePrimitiveValue(message, 'string')],
      message
    );
  }
  
  /// Add a new console log entry with structured data
  void addStructuredLog(int contextId, int level, List<ConsoleValue> args, String message) {
    final consoleLevel = ConsoleLogLevel.fromInt(level);
    final entry = ConsoleLogEntry(
      contextId: contextId,
      level: consoleLevel,
      args: args,
      message: message,
      timestamp: DateTime.now(),
    );

    _logsByContext.putIfAbsent(contextId, () => Queue<ConsoleLogEntry>());
    final logs = _logsByContext[contextId]!;
    
    // Add the new log
    logs.add(entry);
    
    // Remove old logs if we exceed the limit
    while (logs.length > maxLogsPerContext) {
      logs.removeFirst();
    }
  }

  /// Get all logs for a specific context
  List<ConsoleLogEntry> getLogsForContext(int contextId) {
    final logs = _logsByContext[contextId];
    return logs?.toList() ?? [];
  }

  /// Get all logs across all contexts
  List<ConsoleLogEntry> getAllLogs() {
    final allLogs = <ConsoleLogEntry>[];
    _logsByContext.forEach((_, logs) {
      allLogs.addAll(logs);
    });
    // Sort by timestamp
    allLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return allLogs;
  }

  /// Clear logs for a specific context
  void clearLogsForContext(int contextId) {
    // Clear all remote object references before clearing logs
    final logs = _logsByContext[contextId];
    if (logs != null) {
      for (final log in logs) {
        _releaseRemoteObjects(log.args, contextId);
      }
      logs.clear();
    }
  }
  
  /// Release remote object references
  void _releaseRemoteObjects(List<ConsoleValue> args, int contextId) {
    for (final arg in args) {
      if (arg is ConsoleRemoteObject) {
        RemoteObjectService.instance.releaseObject(contextId, arg.objectId);
      } else if (arg is ConsoleObjectValue) {
        // Release nested objects
        for (final value in arg.properties.values) {
          if (value is ConsoleRemoteObject) {
            RemoteObjectService.instance.releaseObject(contextId, value.objectId);
          }
        }
      }
    }
  }

  /// Clear all logs
  void clearAllLogs() {
    // Release all remote objects before clearing
    _logsByContext.forEach((contextId, logs) {
      for (final log in logs) {
        _releaseRemoteObjects(log.args, contextId);
      }
    });
    _logsByContext.clear();
  }

  /// Remove logs for a context (when the context is disposed)
  void removeContext(int contextId) {
    // Release all remote objects for this context
    final logs = _logsByContext[contextId];
    if (logs != null) {
      for (final log in logs) {
        _releaseRemoteObjects(log.args, contextId);
      }
    }
    _logsByContext.remove(contextId);
  }

  /// Get log count for a specific context
  int getLogCountForContext(int contextId) {
    return _logsByContext[contextId]?.length ?? 0;
  }

  /// Get total log count across all contexts
  int getTotalLogCount() {
    int count = 0;
    _logsByContext.forEach((_, logs) {
      count += logs.length;
    });
    return count;
  }

  /// Filter logs by level
  List<ConsoleLogEntry> getLogsByLevel(ConsoleLogLevel level, {int? contextId}) {
    final logs = contextId != null 
        ? getLogsForContext(contextId)
        : getAllLogs();
    return logs.where((log) => log.level == level).toList();
  }
}