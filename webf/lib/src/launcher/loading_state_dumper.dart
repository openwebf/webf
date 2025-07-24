/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'package:flutter/widgets.dart';

/// Represents a single phase in the WebFController loading lifecycle
class LoadingPhase {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final Duration? duration;

  LoadingPhase({
    required this.name,
    required this.timestamp,
    Map<String, dynamic>? parameters,
    this.duration,
  }) : parameters = parameters ?? {};
}

/// Represents a network request during loading
class LoadingNetworkRequest {
  final String url;
  final String method;
  final DateTime startTime;
  DateTime? endTime;
  int? statusCode;
  int? responseSize;
  String? contentType;
  Map<String, String>? headers;
  String? error;

  LoadingNetworkRequest({
    required this.url,
    required this.method,
    required this.startTime,
    this.endTime,
    this.statusCode,
    this.responseSize,
    this.contentType,
    this.headers,
    this.error,
  });

  Duration? get duration => endTime != null ? endTime!.difference(startTime) : null;
  bool get isComplete => endTime != null;
  bool get isSuccessful => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

/// Represents an error that occurred during loading
class LoadingError {
  final String phase;
  final DateTime timestamp;
  final Object error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  LoadingError({
    required this.phase,
    required this.timestamp,
    required this.error,
    this.stackTrace,
    this.context,
  });
}

/// Represents a script element loading status
class LoadingScriptElement {
  final String source;
  final bool isInline;
  final bool isModule;
  final bool isAsync;
  final bool isDefer;
  final DateTime queueTime;
  DateTime? loadStartTime;
  DateTime? loadEndTime;
  DateTime? executeStartTime;
  DateTime? executeEndTime;
  String readyState;
  String? error;
  int? dataSize;

  LoadingScriptElement({
    required this.source,
    required this.isInline,
    required this.isModule,
    required this.isAsync,
    required this.isDefer,
    required this.queueTime,
    this.readyState = 'loading',
  });

  Duration? get loadDuration => 
      loadStartTime != null && loadEndTime != null 
          ? loadEndTime!.difference(loadStartTime!) 
          : null;

  Duration? get executeDuration => 
      executeStartTime != null && executeEndTime != null 
          ? executeEndTime!.difference(executeStartTime!) 
          : null;

  Duration? get totalDuration => 
      executeEndTime != null 
          ? executeEndTime!.difference(queueTime) 
          : null;

  bool get isComplete => executeEndTime != null || error != null;
  bool get isSuccessful => isComplete && error == null;
}

/// Tracks and records the loading state across the WebFController lifecycle
class LoadingStateDumper {
  final LinkedHashMap<String, LoadingPhase> _phases = LinkedHashMap();
  final List<LoadingNetworkRequest> _networkRequests = [];
  final Map<String, LoadingNetworkRequest> _pendingRequests = {};
  final List<LoadingError> _errors = [];
  final List<LoadingScriptElement> _scriptElements = [];
  final Map<String, LoadingScriptElement> _pendingScripts = {};
  DateTime? _startTime;
  DateTime? _lastPhaseTime;

  // Common phase names
  static const String phaseConstructor = 'constructor';
  static const String phaseInit = 'init';
  static const String phaseAttachToFlutter = 'attachToFlutter';
  static const String phaseLoadStart = 'loadStart';
  static const String phaseResolveEntrypoint = 'resolveEntrypoint';
  static const String phasePreload = 'preload';
  static const String phasePreRender = 'preRender';
  static const String phaseEvaluateStart = 'evaluateStart';
  static const String phaseParseHTML = 'parseHTML';
  static const String phaseEvaluateScripts = 'evaluateScripts';
  static const String phaseEvaluateComplete = 'evaluateComplete';
  static const String phaseDOMContentLoaded = 'domContentLoaded';
  static const String phaseWindowLoad = 'windowLoad';
  static const String phaseFirstPaint = 'firstPaint';
  static const String phaseFirstContentfulPaint = 'firstContentfulPaint';
  static const String phaseLargestContentfulPaint = 'largestContentfulPaint';
  static const String phaseBuildRootView = 'buildRootView';
  static const String phaseDetachFromFlutter = 'detachFromFlutter';
  static const String phaseDispose = 'dispose';
  
  // Network phase names
  static const String phaseNetworkStart = 'networkStart';
  static const String phaseNetworkComplete = 'networkComplete';
  static const String phaseNetworkError = 'networkError';

  LoadingStateDumper() {
    _startTime = DateTime.now();
    _lastPhaseTime = _startTime;
  }

  /// Records a loading phase with optional parameters
  void recordPhase(String phaseName, {Map<String, dynamic>? parameters}) {
    final now = DateTime.now();
    final duration = _lastPhaseTime != null ? now.difference(_lastPhaseTime!) : null;
    
    _phases[phaseName] = LoadingPhase(
      name: phaseName,
      timestamp: now,
      parameters: parameters,
      duration: duration,
    );
    
    _lastPhaseTime = now;
  }

  /// Records the start of a phase and returns a function to record its completion
  VoidCallback recordPhaseStart(String phaseName, {Map<String, dynamic>? parameters}) {
    final startTime = DateTime.now();
    recordPhase('$phaseName.start', parameters: parameters);
    
    return () {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      recordPhase('$phaseName.end', parameters: {
        ...?parameters,
        'duration': duration.inMilliseconds,
      });
    };
  }

  /// Records the start of a network request
  void recordNetworkRequestStart(String url, {String method = 'GET', Map<String, String>? headers}) {
    final request = LoadingNetworkRequest(
      url: url,
      method: method,
      startTime: DateTime.now(),
      headers: headers,
    );
    _pendingRequests[url] = request;
    _networkRequests.add(request);
    
    recordPhase(phaseNetworkStart, parameters: {
      'url': url,
      'method': method,
      'requestCount': _networkRequests.length,
    });
  }

  /// Records the completion of a network request
  void recordNetworkRequestComplete(String url, {
    int? statusCode,
    int? responseSize,
    String? contentType,
    Map<String, String>? headers,
  }) {
    final request = _pendingRequests[url];
    if (request != null) {
      request.endTime = DateTime.now();
      request.statusCode = statusCode;
      request.responseSize = responseSize;
      request.contentType = contentType;
      if (headers != null) {
        request.headers = {...?request.headers, ...headers};
      }
      _pendingRequests.remove(url);
      
      recordPhase(phaseNetworkComplete, parameters: {
        'url': url,
        'statusCode': statusCode,
        'responseSize': responseSize,
        'duration': request.duration?.inMilliseconds,
        'contentType': contentType,
      });
    }
  }

  /// Records a network request error
  void recordNetworkRequestError(String url, String error) {
    final request = _pendingRequests[url];
    if (request != null) {
      request.endTime = DateTime.now();
      request.error = error;
      _pendingRequests.remove(url);
      
      recordPhase(phaseNetworkError, parameters: {
        'url': url,
        'error': error,
        'duration': request.duration?.inMilliseconds,
      });
    }
  }

  /// Records an error that occurred during a specific phase
  void recordError(String phase, Object error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _errors.add(LoadingError(
      phase: phase,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// Records an error with the current phase context
  void recordCurrentPhaseError(Object error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    final currentPhase = _phases.values.isNotEmpty ? _phases.values.last.name : 'unknown';
    recordError(currentPhase, error, stackTrace: stackTrace, context: context);
  }

  /// Records a script element being queued for loading
  LoadingScriptElement recordScriptElementQueue({
    required String source,
    required bool isInline,
    required bool isModule,
    required bool isAsync,
    required bool isDefer,
  }) {
    final script = LoadingScriptElement(
      source: source,
      isInline: isInline,
      isModule: isModule,
      isAsync: isAsync,
      isDefer: isDefer,
      queueTime: DateTime.now(),
    );
    
    _scriptElements.add(script);
    _pendingScripts[source] = script;
    
    recordPhase('scriptQueue', parameters: {
      'source': isInline ? '<inline>' : source,
      'type': isModule ? 'module' : 'script',
      'async': isAsync,
      'defer': isDefer,
      'scriptCount': _scriptElements.length,
    });
    
    return script;
  }

  /// Records the start of script loading
  void recordScriptElementLoadStart(String source) {
    final script = _pendingScripts[source];
    if (script != null) {
      script.loadStartTime = DateTime.now();
      script.readyState = 'interactive';
      
      recordPhase('scriptLoadStart', parameters: {
        'source': script.isInline ? '<inline>' : source,
        'type': script.isModule ? 'module' : 'script',
      });
    }
  }

  /// Records the completion of script loading
  void recordScriptElementLoadComplete(String source, {int? dataSize}) {
    final script = _pendingScripts[source];
    if (script != null) {
      script.loadEndTime = DateTime.now();
      script.dataSize = dataSize;
      
      recordPhase('scriptLoadComplete', parameters: {
        'source': script.isInline ? '<inline>' : source,
        'loadDuration': script.loadDuration?.inMilliseconds,
        'dataSize': dataSize,
      });
    }
  }

  /// Records the start of script execution
  void recordScriptElementExecuteStart(String source) {
    final script = _pendingScripts[source];
    if (script != null) {
      script.executeStartTime = DateTime.now();
      
      recordPhase('scriptExecuteStart', parameters: {
        'source': script.isInline ? '<inline>' : source,
        'type': script.isModule ? 'module' : 'script',
      });
    }
  }

  /// Records the completion of script execution
  void recordScriptElementExecuteComplete(String source) {
    final script = _pendingScripts[source];
    if (script != null) {
      script.executeEndTime = DateTime.now();
      script.readyState = 'complete';
      _pendingScripts.remove(source);
      
      recordPhase('scriptExecuteComplete', parameters: {
        'source': script.isInline ? '<inline>' : source,
        'executeDuration': script.executeDuration?.inMilliseconds,
        'totalDuration': script.totalDuration?.inMilliseconds,
      });
    }
  }

  /// Records a script loading error
  void recordScriptElementError(String source, String error) {
    final script = _pendingScripts[source];
    if (script != null) {
      script.error = error;
      script.readyState = 'error';
      _pendingScripts.remove(source);
      
      recordPhase('scriptError', parameters: {
        'source': script.isInline ? '<inline>' : source,
        'error': error,
      });
    }
  }

  /// Gets all script elements
  List<LoadingScriptElement> get scriptElements => List.unmodifiable(_scriptElements);

  /// Gets count of successful scripts
  int get successfulScriptsCount => _scriptElements.where((s) => s.isSuccessful).length;

  /// Gets count of failed scripts
  int get failedScriptsCount => _scriptElements.where((s) => s.error != null).length;

  /// Dumps the loading state as a formatted ASCII timeline
  String dump({bool verbose = false}) {
    if (_phases.isEmpty) {
      return 'No loading phases recorded';
    }

    final buffer = StringBuffer();
    final totalDuration = _phases.values.last.timestamp.difference(_startTime!);
    
    // Calculate network statistics
    final completedRequests = _networkRequests.where((r) => r.isComplete).toList();
    final successfulRequests = completedRequests.where((r) => r.isSuccessful).toList();
    final failedRequests = completedRequests.where((r) => !r.isSuccessful && r.error == null).toList();
    final errorRequests = _networkRequests.where((r) => r.error != null).toList();
    final totalResponseSize = completedRequests.fold<int>(0, (sum, r) => sum + (r.responseSize ?? 0));
    final totalNetworkTime = completedRequests.fold<int>(0, (sum, r) => sum + (r.duration?.inMilliseconds ?? 0));
    
    // Header
    buffer.writeln('╔══════════════════════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                        WebFController Loading State Dump                      ║');
    buffer.writeln('╠══════════════════════════════════════════════════════════════════════════════╣');
    buffer.writeln('║ Total Duration: ${_formatDuration(totalDuration)}');
    buffer.writeln('║ Phases: ${_phases.length}');
    if (_errors.isNotEmpty) {
      buffer.writeln('║ ⚠️  Errors: ${_errors.length}');
    }
    buffer.writeln('║ Network Requests: ${_networkRequests.length} (${successfulRequests.length} successful, ${failedRequests.length} failed, ${errorRequests.length} errors)');
    if (_networkRequests.isNotEmpty) {
      buffer.writeln('║ Total Network Time: ${_formatDuration(Duration(milliseconds: totalNetworkTime))}');
      buffer.writeln('║ Total Downloaded: ${_formatBytes(totalResponseSize)}');
    }
    if (_scriptElements.isNotEmpty) {
      buffer.writeln('║ Script Elements: ${_scriptElements.length} ($successfulScriptsCount successful, $failedScriptsCount failed)');
    }
    buffer.writeln('╠══════════════════════════════════════════════════════════════════════════════╣');
    
    // Timeline
    buffer.writeln('║ Timeline:');
    buffer.writeln('║');
    
    int maxPhaseNameLength = _phases.keys.map((k) => k.length).reduce((a, b) => a > b ? a : b);
    maxPhaseNameLength = maxPhaseNameLength < 30 ? 30 : maxPhaseNameLength;
    
    _phases.forEach((phaseName, phase) {
      final elapsed = phase.timestamp.difference(_startTime!);
      final percentage = (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1);
      
      // Phase name and timing
      final paddedName = phaseName.padRight(maxPhaseNameLength);
      final timing = '+${_formatDuration(elapsed)} (${percentage.padLeft(5)}%)';
      
      buffer.writeln('║ $paddedName │ $timing');
      
      // Parameters (if verbose mode)
      if (verbose && phase.parameters.isNotEmpty) {
        phase.parameters.forEach((key, value) {
          final paramLine = '  └─ $key: $value';
          buffer.writeln('║ ${' ' * maxPhaseNameLength} │ $paramLine');
        });
      }
      
      // Duration between phases
      if (phase.duration != null && phase.duration!.inMilliseconds > 0) {
        final durationLine = '  ⤷ ${_formatDuration(phase.duration!)}';
        buffer.writeln('║ ${' ' * maxPhaseNameLength} │ $durationLine');
      }
    });
    
    // Add network timeline if there are requests
    if (_networkRequests.isNotEmpty && verbose) {
      buffer.writeln('║');
      buffer.writeln('║ Network Activity:');
      buffer.writeln('║');
      
      for (final request in _networkRequests) {
        final startOffset = request.startTime.difference(_startTime!);
        final endOffset = request.endTime?.difference(_startTime!) ?? totalDuration;
        final duration = request.duration ?? Duration(milliseconds: endOffset.inMilliseconds - startOffset.inMilliseconds);
        
        // Format URL to fit
        final maxUrlLength = 40;
        final displayUrl = request.url.length > maxUrlLength 
            ? '...${request.url.substring(request.url.length - maxUrlLength + 3)}'
            : request.url.padRight(maxUrlLength);
        
        final statusStr = request.error != null 
            ? 'ERROR'
            : request.statusCode?.toString() ?? 'PENDING';
        final sizeStr = request.responseSize != null 
            ? _formatBytes(request.responseSize!) 
            : '-';
        
        buffer.writeln('║ $displayUrl │ ${request.method.padRight(6)} │ $statusStr │ ${sizeStr.padLeft(10)} │ ${_formatDuration(duration).padLeft(8)}');
      }
    }
    
    // Add script elements timeline if there are scripts
    if (_scriptElements.isNotEmpty && verbose) {
      buffer.writeln('║');
      buffer.writeln('║ Script Elements:');
      buffer.writeln('║');
      
      for (final script in _scriptElements) {
        // Format source to fit
        final maxSourceLength = 40;
        final displaySource = script.isInline 
            ? '<inline script>'
            : (script.source.length > maxSourceLength 
                ? '...${script.source.substring(script.source.length - maxSourceLength + 3)}'
                : script.source).padRight(maxSourceLength);
        
        final typeStr = script.isModule ? 'module' : 'script';
        final asyncStr = script.isAsync ? 'async' : (script.isDefer ? 'defer' : 'sync ');
        final statusStr = script.error != null 
            ? 'ERROR'
            : (script.readyState == 'complete' ? 'OK' : script.readyState.toUpperCase());
        
        String durationStr = '-';
        if (script.totalDuration != null) {
          durationStr = _formatDuration(script.totalDuration!);
        }
        
        String sizeStr = '-';
        if (script.dataSize != null) {
          sizeStr = _formatBytes(script.dataSize!);
        }
        
        buffer.writeln('║ $displaySource │ $typeStr │ $asyncStr │ $statusStr │ ${sizeStr.padLeft(10)} │ ${durationStr.padLeft(8)}');
        
        // Show error details if any
        if (script.error != null && verbose) {
          buffer.writeln('║   └─ Error: ${script.error}');
        }
      }
    }
    
    // ASCII timeline visualization
    buffer.writeln('║');
    buffer.writeln('║ Visual Timeline:');
    buffer.writeln('║');
    
    const int timelineWidth = 60;
    buffer.write('║ 0ms ');
    buffer.write('─' * (timelineWidth - 10));
    buffer.writeln(' ${_formatDuration(totalDuration)}');
    
    // Key phases on timeline
    final keyPhases = [
      phaseInit,
      phaseLoadStart,
      phaseEvaluateStart,
      phaseDOMContentLoaded,
      phaseBuildRootView,
      phaseFirstPaint,
      phaseFirstContentfulPaint,
      phaseLargestContentfulPaint,
      phaseWindowLoad,
    ];
    
    for (final phaseName in keyPhases) {
      if (_phases.containsKey(phaseName)) {
        final phase = _phases[phaseName]!;
        final elapsed = phase.timestamp.difference(_startTime!);
        
        // Guard against zero duration
        final position = totalDuration.inMilliseconds > 0 
            ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * timelineWidth).round()
            : 0;
        
        // Ensure position is within bounds
        final clampedPosition = position.clamp(0, timelineWidth - 1);
        
        buffer.write('║ ');
        buffer.write(' ' * clampedPosition);
        buffer.write('▼');
        buffer.write(' ' * (timelineWidth - clampedPosition - 1));
        buffer.writeln(' $phaseName');
      }
    }
    
    // Error section if there are errors
    if (_errors.isNotEmpty) {
      buffer.writeln('║');
      buffer.writeln('║ ⚠️  Errors and Exceptions:');
      buffer.writeln('║');
      
      for (final error in _errors) {
        final errorOffset = error.timestamp.difference(_startTime!);
        final errorType = error.error.runtimeType.toString();
        
        buffer.writeln('║ ERROR at +${_formatDuration(errorOffset)} during ${error.phase}:');
        buffer.writeln('║   Type: $errorType');
        buffer.writeln('║   Message: ${error.error.toString()}');
        
        if (verbose && error.context != null && error.context!.isNotEmpty) {
          buffer.writeln('║   Context:');
          error.context!.forEach((key, value) {
            buffer.writeln('║     $key: $value');
          });
        }
        
        if (verbose && error.stackTrace != null) {
          buffer.writeln('║   Stack trace:');
          final stackLines = error.stackTrace.toString().split('\n').take(5);
          for (final line in stackLines) {
            if (line.trim().isNotEmpty) {
              buffer.writeln('║     ${line.trim()}');
            }
          }
          buffer.writeln('║     ...');
        }
        
        buffer.writeln('║');
      }
    }
    
    // Footer
    buffer.writeln('╚══════════════════════════════════════════════════════════════════════════════╝');
    
    return buffer.toString();
  }

  /// Formats a duration into a human-readable string
  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else if (duration.inSeconds < 60) {
      return '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }

  /// Formats bytes into human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// Resets the dumper to start recording from scratch
  void reset() {
    _phases.clear();
    _networkRequests.clear();
    _pendingRequests.clear();
    _errors.clear();
    _scriptElements.clear();
    _pendingScripts.clear();
    _startTime = DateTime.now();
    _lastPhaseTime = _startTime;
  }

  /// Gets all recorded phases
  List<LoadingPhase> get phases => _phases.values.toList();
  
  /// Gets all network requests
  List<LoadingNetworkRequest> get networkRequests => List.unmodifiable(_networkRequests);
  
  /// Gets all recorded errors
  List<LoadingError> get errors => List.unmodifiable(_errors);
  
  /// Checks if there are any errors
  bool get hasErrors => _errors.isNotEmpty;

  /// Gets the total duration from start to the last recorded phase
  Duration? get totalDuration {
    if (_phases.isEmpty || _startTime == null) return null;
    return _phases.values.last.timestamp.difference(_startTime!);
  }
}