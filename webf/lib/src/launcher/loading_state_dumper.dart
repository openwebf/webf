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
  final List<LoadingPhase> substeps = [];
  final String? parentPhase;

  LoadingPhase({
    required this.name,
    required this.timestamp,
    Map<String, dynamic>? parameters,
    this.duration,
    this.parentPhase,
  }) : parameters = parameters ?? {};

  void addSubstep(LoadingPhase substep) {
    substeps.add(substep);
  }
}

/// Represents a stage in the network request lifecycle
class NetworkRequestStage {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  NetworkRequestStage({
    required this.name,
    required this.timestamp,
    this.metadata,
  });
}

/// Represents cache information for a network request
class NetworkCacheInfo {
  final bool cacheHit;
  final String? cacheType; // 'memory', 'disk', 'network'
  final DateTime? cacheEntryTime;
  final Duration? cacheAge;
  final Map<String, String>? cacheHeaders;
  final int? cacheSize;

  NetworkCacheInfo({
    required this.cacheHit,
    this.cacheType,
    this.cacheEntryTime,
    this.cacheAge,
    this.cacheHeaders,
    this.cacheSize,
  });
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
  Map<String, String>? requestHeaders;
  Map<String, String>? responseHeaders;
  String? error;

  // Network stages tracking
  final List<NetworkRequestStage> _stages = [];

  // Cache information
  NetworkCacheInfo? cacheInfo;

  // Redirect tracking
  final List<String> redirectChain = [];
  String? finalUrl;

  // Protocol information
  String? protocol; // 'http/1.1', 'h2', 'h3'
  String? remoteAddress;
  int? remotePort;

  // Timing details
  DateTime? dnsStart;
  DateTime? dnsEnd;
  DateTime? connectStart;
  DateTime? connectEnd;
  DateTime? tlsStart;
  DateTime? tlsEnd;
  DateTime? requestStart;
  DateTime? responseStart;
  DateTime? responseEnd;

  LoadingNetworkRequest({
    required this.url,
    required this.method,
    required this.startTime,
    this.endTime,
    this.statusCode,
    this.responseSize,
    this.contentType,
    this.requestHeaders,
    this.responseHeaders,
    this.error,
    this.protocol,
    this.remoteAddress,
    this.remotePort,
  });

  Duration? get duration =>
      endTime != null ? endTime!.difference(startTime) : null;
  bool get isComplete => endTime != null;
  bool get isSuccessful =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isFromCache => cacheInfo?.cacheHit ?? false;
  bool get hasRedirects => redirectChain.isNotEmpty;

  // Backward compatibility for inspector panel
  Map<String, String>? get headers => responseHeaders ?? requestHeaders;

  // Get stages as read-only list
  List<NetworkRequestStage> get stages => List.unmodifiable(_stages);

  // Add a stage to the request
  void addStage(String name, {Map<String, dynamic>? metadata}) {
    _stages.add(NetworkRequestStage(
      name: name,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }

  // Timing durations
  Duration? get dnsDuration =>
      dnsStart != null && dnsEnd != null ? dnsEnd!.difference(dnsStart!) : null;
  Duration? get connectDuration => connectStart != null && connectEnd != null
      ? connectEnd!.difference(connectStart!)
      : null;
  Duration? get tlsDuration =>
      tlsStart != null && tlsEnd != null ? tlsEnd!.difference(tlsStart!) : null;
  Duration? get waitingDuration => requestStart != null && responseStart != null
      ? responseStart!.difference(requestStart!)
      : null;
  Duration? get downloadDuration => responseStart != null && responseEnd != null
      ? responseEnd!.difference(responseStart!)
      : null;
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

  Duration? get loadDuration => loadStartTime != null && loadEndTime != null
      ? loadEndTime!.difference(loadStartTime!)
      : null;

  Duration? get executeDuration =>
      executeStartTime != null && executeEndTime != null
          ? executeEndTime!.difference(executeStartTime!)
          : null;

  Duration? get totalDuration =>
      executeEndTime != null ? executeEndTime!.difference(queueTime) : null;

  bool get isComplete => executeEndTime != null || error != null;
  bool get isSuccessful => isComplete && error == null;
}

/// Options for controlling what to display in the loading state dump
class LoadingStateDumpOptions {
  final bool showMainPhases;
  final bool showAdditionalPhases;
  final bool showScripts;
  final bool showErrors;
  final bool showMainEntrypoint;
  final bool showScriptRequests;
  final bool showXHRRequests;
  final bool showImageRequests;
  final bool showOtherRequests;
  final bool showNetworkDetails;

  const LoadingStateDumpOptions({
    this.showMainPhases = true,
    this.showAdditionalPhases = true,
    this.showScripts = true,
    this.showErrors = true,
    this.showMainEntrypoint = true,
    this.showScriptRequests = true,
    this.showXHRRequests = true,
    this.showImageRequests = true,
    this.showOtherRequests = true,
    this.showNetworkDetails = false,
  });

  // Preset configurations
  static const LoadingStateDumpOptions minimal = LoadingStateDumpOptions(
    showAdditionalPhases: false,
    showScripts: false,
    showNetworkDetails: false,
  );

  static const LoadingStateDumpOptions full = LoadingStateDumpOptions(
    showNetworkDetails: true,
  );
}

/// Represents the complete loading state dump with both text and JSON representations
class LoadingStateDump {
  final DateTime startTime;
  final Duration totalDuration;
  final List<LoadingPhase> phases;
  final List<LoadingNetworkRequest> networkRequests;
  final List<LoadingError> errors;
  final List<LoadingScriptElement> scriptElements;
  final LoadingStateDumpOptions options;
  final LoadingState? dumper;

  LoadingStateDump({
    required this.startTime,
    required this.totalDuration,
    required this.phases,
    required this.networkRequests,
    required this.errors,
    required this.scriptElements,
    this.options = const LoadingStateDumpOptions(),
    this.dumper,
  });

  /// Checks if the loading has reached the FP (First Paint) stage
  bool get hasReachedFP {
    return phases.any((phase) => phase.name == LoadingState.phaseFirstPaint);
  }

  /// Checks if the loading has reached the FCP (First Contentful Paint) stage
  bool get hasReachedFCP {
    return phases.any((phase) => phase.name == LoadingState.phaseFirstContentfulPaint);
  }

  /// Checks if the loading has reached the LCP (Largest Contentful Paint) stage
  bool get hasReachedLCP {
    return phases.any((phase) => phase.name == LoadingState.phaseLargestContentfulPaint);
  }

  /// Checks if LCP has been finalized (not just a candidate)
  bool get hasLCPFinalized {
    final lcpPhase = phases.firstWhere(
      (phase) => phase.name == LoadingState.phaseLargestContentfulPaint,
      orElse: () => LoadingPhase(name: '', timestamp: DateTime.now()),
    );

    if (lcpPhase.name.isEmpty) return false;

    // Check if this is the final LCP (not a candidate)
    return lcpPhase.parameters['isFinal'] == true;
  }

  /// Gets the LCP time in milliseconds if available
  double? get lcpTime {
    final lcpPhase = phases.firstWhere(
      (phase) => phase.name == LoadingState.phaseLargestContentfulPaint,
      orElse: () => LoadingPhase(name: '', timestamp: DateTime.now()),
    );

    if (lcpPhase.name.isEmpty) return null;

    // Return the time since navigation start
    final timeSinceNavStart = lcpPhase.parameters['timeSinceNavigationStart'];
    if (timeSinceNavStart is num) {
      return timeSinceNavStart.toDouble();
    }
    return null;
  }

  /// Gets the LCP element tag if available
  String? get lcpElementTag {
    final lcpPhase = phases.firstWhere(
      (phase) => phase.name == LoadingState.phaseLargestContentfulPaint,
      orElse: () => LoadingPhase(name: '', timestamp: DateTime.now()),
    );

    if (lcpPhase.name.isEmpty) return null;

    return lcpPhase.parameters['elementTag'] as String?;
  }

  /// Gets the size of the largest contentful element if available
  double? get lcpContentSize {
    final lcpPhase = phases.firstWhere(
      (phase) => phase.name == LoadingState.phaseLargestContentfulPaint,
      orElse: () => LoadingPhase(name: '', timestamp: DateTime.now()),
    );

    if (lcpPhase.name.isEmpty) return null;

    final size = lcpPhase.parameters['largestContentSize'];
    if (size is num) {
      return size.toDouble();
    }
    return null;
  }

  /// Determines if the loading should be displayed as two separate parts
  /// Returns true if in preload mode and pause is significant (> 100ms)
  bool get shouldDisplayAsTwoParts {
    if (dumper == null) return false;

    final pauseDuration = dumper!._getPauseDuration();
    // Consider it two parts if pause is more than 100ms
    return pauseDuration.inMilliseconds > 100;
  }

  /// Categorizes network requests by type
  Map<String, List<LoadingNetworkRequest>> get categorizedNetworkRequests {
    final Map<String, List<LoadingNetworkRequest>> categorized = {
      'mainEntrypoint': [],
      'scripts': [],
      'xhr': [],
      'images': [],
      'other': [],
    };

    for (final request in networkRequests) {
      final url = request.url.toLowerCase();
      final contentType = (request.contentType ?? '').toLowerCase();

      // Check if it's the main entrypoint (HTML file)
      if (contentType.contains('text/html') ||
          (url.endsWith('.html') || url.endsWith('.htm')) ||
          (request.method == 'GET' && phases.any((p) =>
            p.name == LoadingState.phaseLoadStart &&
            p.parameters['bundle'] == request.url))) {
        categorized['mainEntrypoint']!.add(request);
      }
      // Check if it's a script
      else if (contentType.contains('javascript') ||
               contentType.contains('ecmascript') ||
               url.endsWith('.js') ||
               url.endsWith('.mjs') ||
               url.endsWith('.ts')) {
        categorized['scripts']!.add(request);
      }
      // Check if it's an image
      else if (contentType.contains('image/') ||
               url.endsWith('.png') ||
               url.endsWith('.jpg') ||
               url.endsWith('.jpeg') ||
               url.endsWith('.gif') ||
               url.endsWith('.webp') ||
               url.endsWith('.svg') ||
               url.endsWith('.ico')) {
        categorized['images']!.add(request);
      }
      // Check if it's an XHR/Fetch request (typically API calls)
      else if (contentType.contains('application/json') ||
               contentType.contains('application/xml') ||
               contentType.contains('text/xml') ||
               request.method != 'GET' ||
               url.contains('/api/') ||
               url.contains('/graphql')) {
        categorized['xhr']!.add(request);
      }
      // Everything else
      else {
        categorized['other']!.add(request);
      }
    }

    return categorized;
  }

  Map<String, dynamic> toJson() {
    // Helper function to convert LoadingPhase to JSON
    Map<String, dynamic> phaseToJson(LoadingPhase phase) {
      return {
        'name': phase.name,
        'timestamp': phase.timestamp.toIso8601String(),
        'elapsed': dumper?._getAdjustedElapsedTime(phase).inMilliseconds ?? phase.timestamp.difference(startTime).inMilliseconds,
        'duration': phase.duration?.inMilliseconds,
        'parameters': phase.parameters,
        if (phase.substeps.isNotEmpty)
          'substeps': phase.substeps.map((s) => phaseToJson(s)).toList(),
      };
    }

    // Calculate network stats
    final cachedRequests = networkRequests.where((r) => r.isFromCache).toList();
    final totalResponseSize = networkRequests.fold<int>(0, (sum, r) => sum + (r.responseSize ?? 0));

    return {
      'startTime': startTime.toIso8601String(),
      'totalDuration': totalDuration.inMilliseconds,
      'summary': {
        'totalPhases': phases.length,
        'totalNetworkRequests': networkRequests.length,
        'totalErrors': errors.length,
        'totalScripts': scriptElements.length,
        'successfulRequests': networkRequests.where((r) => r.isSuccessful).length,
        'failedRequests': networkRequests.where((r) => !r.isSuccessful && r.error == null).length,
        'errorRequests': networkRequests.where((r) => r.error != null).length,
        'cachedRequests': cachedRequests.length,
        'totalResponseSize': totalResponseSize,
        // Add performance metrics
        'hasReachedFP': hasReachedFP,
        'hasReachedFCP': hasReachedFCP,
        'hasReachedLCP': hasReachedLCP,
        'hasLCPFinalized': hasLCPFinalized,
        'lcpTime': lcpTime,
        'lcpElementTag': lcpElementTag,
        'lcpContentSize': lcpContentSize,
      },
      'phases': phases.map((p) => phaseToJson(p)).toList(),
      'networkRequests': networkRequests.map((r) => {
        'url': r.url,
        'method': r.method,
        'startTime': r.startTime.toIso8601String(),
        'endTime': r.endTime?.toIso8601String(),
        'duration': r.duration?.inMilliseconds,
        'statusCode': r.statusCode,
        'responseSize': r.responseSize,
        'contentType': r.contentType,
        'fromCache': r.isFromCache,
        'error': r.error,
        'protocol': r.protocol,
        'cacheInfo': r.cacheInfo != null ? {
          'cacheHit': r.cacheInfo!.cacheHit,
          'cacheType': r.cacheInfo!.cacheType,
          'cacheAge': r.cacheInfo!.cacheAge?.inSeconds,
          'cacheSize': r.cacheInfo!.cacheSize,
        } : null,
        'redirects': r.redirectChain,
        'stages': r.stages.map((s) => {
          'name': s.name,
          'timestamp': s.timestamp.toIso8601String(),
          'metadata': s.metadata,
        }).toList(),
      }).toList(),
      'errors': errors.map((e) => {
        'phase': e.phase,
        'timestamp': e.timestamp.toIso8601String(),
        'error': e.error.toString(),
        'context': e.context,
      }).toList(),
      'scriptElements': scriptElements.map((s) => {
        'source': s.source,
        'isInline': s.isInline,
        'isModule': s.isModule,
        'isAsync': s.isAsync,
        'isDefer': s.isDefer,
        'queueTime': s.queueTime.toIso8601String(),
        'loadDuration': s.loadDuration?.inMilliseconds,
        'executeDuration': s.executeDuration?.inMilliseconds,
        'totalDuration': s.totalDuration?.inMilliseconds,
        'dataSize': s.dataSize,
        'error': s.error,
        'isComplete': s.isComplete,
        'isSuccessful': s.isSuccessful,
      }).toList(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    // Calculate statistics
    final completedRequests = networkRequests.where((r) => r.isComplete).toList();
    final successfulRequests = completedRequests.where((r) => r.isSuccessful).toList();
    final failedRequests = completedRequests.where((r) => !r.isSuccessful && r.error == null).toList();
    final errorRequests = networkRequests.where((r) => r.error != null).toList();
    final cachedRequests = networkRequests.where((r) => r.isFromCache).toList();
    final redirectedRequests = networkRequests.where((r) => r.hasRedirects).toList();
    final totalResponseSize = completedRequests.fold<int>(0, (sum, r) => sum + (r.responseSize ?? 0));
    final totalNetworkTime = completedRequests.fold<int>(0, (sum, r) => sum + (r.duration?.inMilliseconds ?? 0));

    // Header
    buffer.writeln(
        '\n╔══════════════════════════════════════════════════════════════════════════════╗');
    buffer.writeln(
        '║                        WebFController Loading State Dump                      ║');
    buffer.writeln(
        '╠══════════════════════════════════════════════════════════════════════════════╣');
    buffer.writeln('║ Total Duration: ${_formatDuration(totalDuration)}');
    buffer.writeln('║ Phases: ${phases.length}');
    if (errors.isNotEmpty) {
      buffer.writeln('║ ⚠️  Errors: ${errors.length}');
    }
    buffer.writeln(
        '║ Network Requests: ${networkRequests.length} (${successfulRequests.length} successful, ${failedRequests.length} failed, ${errorRequests.length} errors)');
    if (networkRequests.isNotEmpty) {
      buffer.writeln(
          '║ Total Network Time: ${_formatDuration(Duration(milliseconds: totalNetworkTime))}');
      buffer.writeln('║ Total Downloaded: ${_formatBytes(totalResponseSize)}');
      if (cachedRequests.isNotEmpty) {
        buffer.writeln(
            '║ Cache Hits: ${cachedRequests.length} (${(cachedRequests.length / networkRequests.length * 100).toStringAsFixed(1)}%)');
      }
      if (redirectedRequests.isNotEmpty) {
        buffer.writeln('║ Redirected Requests: ${redirectedRequests.length}');
      }
    }
    if (scriptElements.isNotEmpty) {
      final successfulScriptsCount = scriptElements.where((s) => s.isSuccessful).length;
      final failedScriptsCount = scriptElements.where((s) => s.error != null).length;
      buffer.writeln(
          '║ Script Elements: ${scriptElements.length} ($successfulScriptsCount successful, $failedScriptsCount failed)');
    }
    buffer.writeln(
        '╠══════════════════════════════════════════════════════════════════════════════╣');

    // Find windowLoad phase timestamp to use as divider
    final windowLoadPhase = phases.firstWhere(
      (p) => p.name == LoadingState.phaseWindowLoad,
      orElse: () => LoadingPhase(name: '', timestamp: DateTime(9999)),
    );
    final windowLoadTimestamp = windowLoadPhase.name.isNotEmpty ? windowLoadPhase.timestamp : null;

    // Separate phases into main (before windowLoad) and additional (after windowLoad)
    final mainPhases = <LoadingPhase>[];
    final additionalPhasesAfterWindow = <LoadingPhase>[];

    for (final phase in phases) {
      // Skip network phases for main table
      if (phase.name.startsWith('networkStart:') ||
          phase.name.startsWith('networkComplete:') ||
          phase.name.startsWith('networkError:')) {
        continue;
      }

      // Skip .start and .end phases except for specific ones we want to show
      if ((phase.name.contains('.start') || phase.name.contains('.end')) &&
          !phase.name.startsWith('resolveEntrypoint') &&
          !phase.name.startsWith('parseHTML')) {
        continue;
      }

      // Always include paint phases in main phases regardless of windowLoad timing
      if (phase.name == LoadingState.phaseFirstPaint ||
          phase.name == LoadingState.phaseFirstContentfulPaint ||
          phase.name == LoadingState.phaseLargestContentfulPaint ||
          phase.name == LoadingState.phaseBuildRootView) {
        mainPhases.add(phase);
      } else if (windowLoadTimestamp == null || phase.timestamp.isBefore(windowLoadTimestamp) || phase.timestamp == windowLoadTimestamp) {
        mainPhases.add(phase);
      } else {
        additionalPhasesAfterWindow.add(phase);
      }
    }

    // Check if we should display as two parts
    if (shouldDisplayAsTwoParts) {
      // Split phases into Part I (up to scriptLoadComplete) and Part II (from attachToFlutter onwards)
      final part1Phases = <LoadingPhase>[];
      final part2Phases = <LoadingPhase>[];

      LoadingPhase? scriptLoadCompletePhase;
      LoadingPhase? attachToFlutterPhase;

      // Find key phases
      for (final phase in phases) {
        if (phase.name == LoadingState.phaseScriptLoadComplete) {
          scriptLoadCompletePhase = phase;
        }
        if (phase.name == LoadingState.phaseAttachToFlutter) {
          attachToFlutterPhase = phase;
        }
      }

      // Categorize phases
      for (final phase in mainPhases) {
        // Skip network phases for main table
        if (phase.name.startsWith('networkStart:') ||
            phase.name.startsWith('networkComplete:') ||
            phase.name.startsWith('networkError:')) {
          continue;
        }

        // Skip .start and .end phases except for specific ones
        if ((phase.name.contains('.start') || phase.name.contains('.end')) &&
            !phase.name.startsWith('resolveEntrypoint') &&
            !phase.name.startsWith('parseHTML')) {
          continue;
        }

        if (scriptLoadCompletePhase != null && attachToFlutterPhase != null) {
          if (!phase.timestamp.isAfter(scriptLoadCompletePhase.timestamp)) {
            part1Phases.add(phase);
          } else if (!phase.timestamp.isBefore(attachToFlutterPhase.timestamp)) {
            part2Phases.add(phase);
          }
        } else {
          part1Phases.add(phase);
        }
      }

      // Display Part I
      buffer.writeln('║ Loading Phases - Part I (Preloading):');
      buffer.writeln('║');
      buffer.writeln('║ ┌─────────────────────────────────┬──────────────┬──────────┬────────────┐');
      buffer.writeln('║ │ Phase                           │ Time         │ Elapsed  │ Percentage │');
      buffer.writeln('║ ├─────────────────────────────────┼──────────────┼──────────┼────────────┤');

      DateTime? previousTime = startTime;
      for (final phase in part1Phases) {
        final elapsed = dumper?._getAdjustedElapsedTime(phase) ?? phase.timestamp.difference(startTime);
        final percentage = totalDuration.inMilliseconds > 0
            ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)
            : '0.0';

        final timeSincePrev = previousTime != null
            ? phase.timestamp.difference(previousTime)
            : Duration.zero;
        previousTime = phase.timestamp;

        // Get display name
        final displayName = _getPhaseDisplayName(phase.name);
        final phaseDisplay = displayName.padRight(31);
        final timeDisplay = _formatDuration(timeSincePrev).padLeft(12);
        final elapsedDisplay = _formatDuration(elapsed).padLeft(8);
        final percentDisplay = '$percentage%'.padLeft(10);

        buffer.writeln('║ │ $phaseDisplay │ $timeDisplay │ $elapsedDisplay │ $percentDisplay │');
      }

      buffer.writeln('║ └─────────────────────────────────┴──────────────┴──────────┴────────────┘');

      // Display pause duration
      final pauseDuration = dumper?._getPauseDuration() ?? Duration.zero;
      buffer.writeln('║');
      buffer.writeln('║                        ⏸️  Paused for ${_formatDuration(pauseDuration)}');
      buffer.writeln('║                                  │');
      buffer.writeln('║                                  ▼');
      buffer.writeln('║');

      // Display Part II
      buffer.writeln('║ Loading Phases - Part II (Rendering):');
      buffer.writeln('║');
      buffer.writeln('║ ┌─────────────────────────────────┬──────────────┬──────────┬────────────┐');
      buffer.writeln('║ │ Phase                           │ Time         │ Elapsed  │ Percentage │');
      buffer.writeln('║ ├─────────────────────────────────┼──────────────┼──────────┼────────────┤');

      previousTime = attachToFlutterPhase?.timestamp;
      for (final phase in part2Phases) {
        final elapsed = dumper?._getAdjustedElapsedTime(phase) ?? phase.timestamp.difference(startTime);
        final percentage = totalDuration.inMilliseconds > 0
            ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)
            : '0.0';

        final timeSincePrev = previousTime != null
            ? phase.timestamp.difference(previousTime)
            : Duration.zero;
        previousTime = phase.timestamp;

        // Get display name
        final displayName = _getPhaseDisplayName(phase.name);
        final phaseDisplay = displayName.padRight(31);
        final timeDisplay = _formatDuration(timeSincePrev).padLeft(12);
        final elapsedDisplay = _formatDuration(elapsed).padLeft(8);
        final percentDisplay = '$percentage%'.padLeft(10);

        buffer.writeln('║ │ $phaseDisplay │ $timeDisplay │ $elapsedDisplay │ $percentDisplay │');
      }

      buffer.writeln('║ └─────────────────────────────────┴──────────────┴──────────┴────────────┘');
    } else {
      // Display as single table (original logic)
      buffer.writeln('║ Loading Phases:');
      buffer.writeln('║');
      buffer.writeln('║ ┌─────────────────────────────────┬──────────────┬──────────┬────────────┐');
      buffer.writeln('║ │ Phase                           │ Time         │ Elapsed  │ Percentage │');
      buffer.writeln('║ ├─────────────────────────────────┼──────────────┼──────────┼────────────┤');

      // Display main phases
      DateTime? previousTime = startTime;
      for (final phase in mainPhases) {
        final elapsed = dumper?._getAdjustedElapsedTime(phase) ?? phase.timestamp.difference(startTime);
        final percentage = totalDuration.inMilliseconds > 0
            ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)
            : '0.0';

        final timeSincePrev = previousTime != null
            ? phase.timestamp.difference(previousTime)
            : Duration.zero;
        previousTime = phase.timestamp;

        // Get display name for phase
        final displayName = _getPhaseDisplayName(phase.name);

        final phaseDisplay = displayName.padRight(31);
        final timeDisplay = _formatDuration(timeSincePrev).padLeft(12);
        final elapsedDisplay = _formatDuration(elapsed).padLeft(8);
        final percentDisplay = '$percentage%'.padLeft(10);

        buffer.writeln('║ │ $phaseDisplay │ $timeDisplay │ $elapsedDisplay │ $percentDisplay │');

        // Display substeps if any
        if (phase.substeps.isNotEmpty && options.showNetworkDetails) {
          for (final substep in phase.substeps) {
            final substepElapsed = dumper?._getAdjustedElapsedTime(substep) ?? substep.timestamp.difference(startTime);
            final substepPercentage = totalDuration.inMilliseconds > 0
                ? (substepElapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)
                : '0.0';

            final substepName = substep.name.split(':').last;
            final substepDisplay = '  └─ $substepName'.padRight(31);
            final substepTimeDisplay = _formatDuration(substep.duration ?? Duration.zero).padLeft(12);
            final substepElapsedDisplay = _formatDuration(substepElapsed).padLeft(8);
            final substepPercentDisplay = '$substepPercentage%'.padLeft(10);

            buffer.writeln('║ │ $substepDisplay │ $substepTimeDisplay │ $substepElapsedDisplay │ $substepPercentDisplay │');
          }
        }
      }

      buffer.writeln('║ └─────────────────────────────────┴──────────────┴──────────┴────────────┘');
    }

    // Show additional phases in verbose mode
    // Collect all other phases not shown in main table
    final shownPhaseNames = mainPhases.map((p) => p.name).toSet();
    final additionalPhases = phases.where((p) => !shownPhaseNames.contains(p.name)).toList();

    if (additionalPhases.isNotEmpty) {
      buffer.writeln('║');
      buffer.writeln('║ Additional Phases:');
      buffer.writeln('║');
      buffer.writeln('║ ┌─────────────────────────────────────────────────┬──────────────┬────────────┐');
      buffer.writeln('║ │ Phase                                           │ Elapsed      │ Percentage │');
      buffer.writeln('║ ├─────────────────────────────────────────────────┼──────────────┼────────────┤');

      for (final phase in additionalPhases) {
        final elapsed = dumper?._getAdjustedElapsedTime(phase) ?? phase.timestamp.difference(startTime);
        final percentage = totalDuration.inMilliseconds > 0
            ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)
            : '0.0';

        // Special handling for network phases that have substeps
        if (phase.name.startsWith('networkStart:')) {
          final url = phase.name.substring('networkStart:'.length);

          // Find the corresponding network request to get additional info
          final request = networkRequests.firstWhere(
                (r) => r.url == url,
            orElse: () => LoadingNetworkRequest(
              url: url,
              method: 'GET',
              startTime: phase.timestamp,
            ),
          );

          // Build status string
          String statusInfo = '';
          if (request.error != null) {
            statusInfo = request.error == 'Superseded by new request' ? ' [REPLACED]' : ' [ERROR]';
          } else if (request.isFromCache) {
            statusInfo = ' [CACHED]';
          } else if (request.statusCode != null) {
            statusInfo = ' [${request.statusCode}]';
          }

          // Add response size if available
          if (request.responseSize != null) {
            statusInfo += ' ${_formatBytes(request.responseSize!)}';
          }

          final networkLabel = 'Network:$statusInfo';
          final phaseDisplay = networkLabel.padRight(47);
          final elapsedDisplay = _formatDuration(elapsed).padLeft(12);
          final percentDisplay = '$percentage%'.padLeft(10);

          buffer.writeln('║ │ $phaseDisplay │ $elapsedDisplay │ $percentDisplay │');

          // Show full URL as the first substep
          final urlDisplay = '  └─ URL: $url';
          if (urlDisplay.length > 47) {
            // Split long URLs into multiple lines
            final words = url.split('/');
            var currentLine = '  └─ URL: ';
            for (int i = 0; i < words.length; i++) {
              final word = words[i];
              final separator = i < words.length - 1 ? '/' : '';
              if (currentLine.length + word.length + separator.length > 47) {
                buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
                currentLine = '       ';
              }
              currentLine += word + separator;
            }
            if (currentLine.trim().isNotEmpty) {
              buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
            }
          } else {
            buffer.writeln('║ │ ${urlDisplay.padRight(47)} │              │            │');
          }

          // Show substeps (network stages)
          if (phase.substeps.isNotEmpty) {
            for (final substep in phase.substeps) {
              final substepElapsed = dumper?._getAdjustedElapsedTime(substep) ?? substep.timestamp.difference(startTime);
              final substepPercentage = totalDuration.inMilliseconds > 0
                  ? (substepElapsed.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)
                  : '0.0';

              final substepName = substep.name.split(':').last;
              final substepDisplay = '  └─ ${substepName.replaceAll('_', ' ')}';
              final paddedSubstepDisplay = substepDisplay.padRight(47);
              final substepElapsedDisplay = _formatDuration(substepElapsed).padLeft(12);
              final substepPercentDisplay = '$substepPercentage%'.padLeft(10);

              buffer.writeln('║ │ $paddedSubstepDisplay │ $substepElapsedDisplay │ $substepPercentDisplay │');
            }
          }
        } else {
          // Regular phase
          final phaseName = phase.name;
          final displayName = phaseName.length > 47
              ? '${phaseName.substring(0, 44)}...'
              : phaseName.padRight(47);

          final elapsedDisplay = _formatDuration(elapsed).padLeft(12);
          final percentDisplay = '$percentage%'.padLeft(10);

          buffer.writeln('║ │ $displayName │ $elapsedDisplay │ $percentDisplay │');

          // Show parameters as substeps if any
          if (phase.parameters.isNotEmpty) {
            phase.parameters.forEach((key, value) {
              final paramDisplay = '  └─ $key: $value';

              // Special handling for URL-like parameters - show full URL
              final valueStr = value.toString();
              final isUrlLike = (key == 'url' || key == 'source' || valueStr.contains('://'));

              if (isUrlLike && valueStr.length > 40) {
                buffer.writeln('║ │ ${'  └─ $key:'.padRight(47)} │              │            │');

                // Split long URL into multiple lines
                final urlParts = valueStr.split('/');
                var currentLine = '       ';

                for (int i = 0; i < urlParts.length; i++) {
                  final part = urlParts[i];
                  final separator = i < urlParts.length - 1 ? '/' : '';

                  if (currentLine.length + part.length + separator.length > 47) {
                    if (currentLine.trim().isNotEmpty) {
                      buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
                    }
                    currentLine = '       ';
                  }
                  currentLine += part + separator;
                }

                if (currentLine.trim().isNotEmpty) {
                  buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
                }
              } else {
                // Regular parameter display
                final paddedParamDisplay = paramDisplay.length > 47
                    ? '${paramDisplay.substring(0, 44)}...'
                    : paramDisplay.padRight(47);
                buffer.writeln('║ │ $paddedParamDisplay │              │            │');
              }
            });
          }
        }
      }

      buffer.writeln('║ └─────────────────────────────────────────────────┴──────────────┴────────────┘');
    }

    // Add script elements timeline if there are scripts
    if (scriptElements.isNotEmpty) {
      buffer.writeln('║');
      buffer.writeln('║ Script Elements:');
      buffer.writeln('║');

      for (final script in scriptElements) {
        // Format source to fit
        final maxSourceLength = 40;
        final displaySource = script.isInline
            ? '<inline script>'
            : (script.source.length > maxSourceLength
                    ? '...${script.source.substring(script.source.length - maxSourceLength + 3)}'
                    : script.source)
                .padRight(maxSourceLength);

        final typeStr = script.isModule ? 'module' : 'script';
        final asyncStr =
            script.isAsync ? 'async' : (script.isDefer ? 'defer' : 'sync ');
        final statusStr = script.error != null
            ? 'ERROR'
            : (script.readyState == 'complete'
                ? 'OK'
                : script.readyState.toUpperCase());

        String durationStr = '-';
        if (script.totalDuration != null) {
          durationStr = _formatDuration(script.totalDuration!);
        }

        String sizeStr = '-';
        if (script.dataSize != null) {
          sizeStr = _formatBytes(script.dataSize!);
        }

        buffer.writeln(
            '║ $displaySource │ $typeStr │ $asyncStr │ $statusStr │ ${sizeStr.padLeft(10)} │ ${durationStr.padLeft(8)}');

        // Show error details if any
        if (script.error != null) {
          buffer.writeln('║   └─ Error: ${script.error}');
        }
      }
    }

    // Error section if there are errors
    if (errors.isNotEmpty) {
      buffer.writeln('║');
      buffer.writeln('║ ⚠️  Errors and Exceptions:');
      buffer.writeln('║');

      for (final error in errors) {
        final errorOffset = dumper?._getAdjustedElapsedTime(LoadingPhase(name: '', timestamp: error.timestamp)) ?? error.timestamp.difference(startTime);
        final errorType = error.error.runtimeType.toString();

        buffer.writeln(
            '║ ERROR at +${_formatDuration(errorOffset)} during ${error.phase}:');
        buffer.writeln('║   Type: $errorType');
        buffer.writeln('║   Message: ${error.error.toString()}');

        if (error.context != null && error.context!.isNotEmpty) {
          buffer.writeln('║   Context:');
          error.context!.forEach((key, value) {
            buffer.writeln('║     $key: $value');
          });
        }

        if (error.stackTrace != null) {
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
    buffer.writeln(
        '╚══════════════════════════════════════════════════════════════════════════════╝');

    return buffer.toString();
  }

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

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String _getPhaseDisplayName(String phaseName) {
    if (phaseName == LoadingState.phaseConstructor) return 'Constructor';
    else if (phaseName == LoadingState.phaseInit) return 'Initialize';
    else if (phaseName == LoadingState.phaseLoadStart) return 'Load Start';
    else if (phaseName == LoadingState.phasePreload) return 'Preload';
    else if (phaseName == LoadingState.phaseResolveEntrypoint) return 'Resolve Entrypoint';
    else if (phaseName == 'resolveEntrypoint.start') return 'Resolve Entrypoint Start';
    else if (phaseName == 'resolveEntrypoint.end') return 'Resolve Entrypoint End';
    else if (phaseName == LoadingState.phaseEvaluateStart) return 'Evaluate Start';
    else if (phaseName == LoadingState.phaseParseHTML) return 'Parse HTML';
    else if (phaseName == 'parseHTML.start') return 'Parse HTML Start';
    else if (phaseName == 'parseHTML.end') return 'Parse HTML End';
    else if (phaseName == LoadingState.phaseEvaluateScripts) return 'Evaluate Scripts';
    else if (phaseName == LoadingState.phaseEvaluateComplete) return 'Evaluate Complete';
    else if (phaseName == LoadingState.phaseDOMContentLoaded) return 'DOM Content Loaded';
    else if (phaseName == LoadingState.phaseWindowLoad) return 'Window Load';
    else if (phaseName == LoadingState.phaseBuildRootView) return 'Build Root View';
    else if (phaseName == LoadingState.phaseFirstPaint) return 'First Paint (FP)';
    else if (phaseName == LoadingState.phaseFirstContentfulPaint) return 'First Contentful Paint (FCP)';
    else if (phaseName == LoadingState.phaseLargestContentfulPaint) return 'Largest Contentful Paint (LCP)';
    else if (phaseName == LoadingState.phaseAttachToFlutter) return 'Attach to Flutter';
    else if (phaseName == LoadingState.phaseScriptQueue) return 'Script Queue';
    else if (phaseName == LoadingState.phaseScriptLoadStart) return 'Script Load Start';
    else if (phaseName == LoadingState.phaseScriptLoadComplete) return 'Script Load Complete';
    else if (phaseName == LoadingState.phaseScriptExecuteStart) return 'Script Execute Start';
    else if (phaseName == LoadingState.phaseScriptExecuteComplete) return 'Script Execute Complete';
    else return phaseName;
  }

  void _displayNetworkCategory(StringBuffer buffer, String categoryName, List<LoadingNetworkRequest> requests,
      Duration totalDuration, DateTime startTime) {
    buffer.writeln('║');
    buffer.writeln('║ $categoryName:');
    buffer.writeln('║ ┌─────────────────────────────────────────────────┬──────────────┬────────────┐');
    buffer.writeln('║ │ URL                                             │ Duration     │ Status     │');
    buffer.writeln('║ ├─────────────────────────────────────────────────┼──────────────┼────────────┤');

    for (final request in requests) {
      // Format URL to fit
      String displayUrl = request.url;
      if (displayUrl.length > 47) {
        // Try to show domain and end of path
        final uri = Uri.tryParse(displayUrl);
        if (uri != null) {
          final domain = uri.host;
          final path = uri.path;
          if (domain.length + path.length > 44) {
            displayUrl = '$domain...${path.substring(path.length - (44 - domain.length - 3))}';
          } else {
            displayUrl = '$domain$path';
          }
        } else {
          displayUrl = '...${displayUrl.substring(displayUrl.length - 44)}';
        }
      }
      displayUrl = displayUrl.padRight(47);

      // Format duration
      String durationStr = '-'.padLeft(12);
      if (request.endTime != null) {
        final duration = request.endTime!.difference(request.startTime);
        durationStr = _formatDuration(duration).padLeft(12);
      }

      // Format status
      String statusStr;
      if (request.error != null) {
        statusStr = 'ERROR';
      } else if (request.isFromCache) {
        statusStr = 'CACHED';
      } else if (request.statusCode != null) {
        statusStr = '${request.statusCode}';
        if (request.responseSize != null) {
          statusStr += ' ${_formatBytes(request.responseSize!)}';
        }
      } else {
        statusStr = 'PENDING';
      }
      statusStr = statusStr.padLeft(10);

      buffer.writeln('║ │ $displayUrl │ $durationStr │ $statusStr │');

      // Show detailed network stages if requested
      if (options.showNetworkDetails) {
        // Find the corresponding phase for this request
        final networkPhase = phases.firstWhere(
          (p) => p.name == 'networkStart:${request.url}',
          orElse: () => LoadingPhase(name: '', timestamp: DateTime.now()),
        );

        if (networkPhase.name.isNotEmpty && networkPhase.substeps.isNotEmpty) {
          for (final substep in networkPhase.substeps) {
            final substepName = substep.name.split(':').last.replaceAll('_', ' ');
            final substepDisplay = '  └─ $substepName'.padRight(47);
            final substepElapsed = dumper?._getAdjustedElapsedTime(substep) ?? substep.timestamp.difference(startTime);
            final substepDuration = _formatDuration(substepElapsed).padLeft(12);

            buffer.writeln('║ │ $substepDisplay │ $substepDuration │            │');
          }
        }
      }
    }

    buffer.writeln('║ └─────────────────────────────────────────────────┴──────────────┴────────────┘');
  }
}

/// Represents a phase event with additional timing information
class LoadingPhaseEvent {
  final LoadingPhase phase;
  final Duration elapsed;

  LoadingPhaseEvent({
    required this.phase,
    required this.elapsed,
  });

  String get name => phase.name;
  DateTime get timestamp => phase.timestamp;
  Map<String, dynamic> get parameters => phase.parameters;
  Duration? get duration => phase.duration;
  List<LoadingPhase> get substeps => phase.substeps;
  String? get parentPhase => phase.parentPhase;
}

/// Callback type for phase events
typedef PhaseEventCallback = void Function(LoadingPhaseEvent event);

/// Tracks and records the loading state across the WebFController lifecycle
class LoadingState {
  final LinkedHashMap<String, LoadingPhase> _phases = LinkedHashMap();
  final List<LoadingNetworkRequest> _networkRequests = [];
  final Map<String, LoadingNetworkRequest> _pendingRequests = {};
  final List<LoadingError> _errors = [];
  final List<LoadingScriptElement> _scriptElements = [];
  final Map<String, LoadingScriptElement> _pendingScripts = {};
  DateTime? _startTime;
  DateTime? _lastPhaseTime;

  // Track LCP candidates
  LoadingPhase? _lastLcpCandidate;
  bool _lcpFinalized = false;

  // Event listeners for phase events
  final Map<String, List<PhaseEventCallback>> _phaseListeners = {};

  // Generic phase event listeners (called for any phase)
  final List<PhaseEventCallback> _anyPhaseListeners = [];

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

  // Script phase names
  static const String phaseScriptQueue = 'scriptQueue';
  static const String phaseScriptLoadStart = 'scriptLoadStart';
  static const String phaseScriptLoadComplete = 'scriptLoadComplete';
  static const String phaseScriptExecuteStart = 'scriptExecuteStart';
  static const String phaseScriptExecuteComplete = 'scriptExecuteComplete';
  static const String phaseScriptError = 'scriptError';

  // Network phase names
  static const String phaseNetworkStart = 'networkStart';
  static const String phaseNetworkComplete = 'networkComplete';
  static const String phaseNetworkError = 'networkError';
  static const String phaseNetworkCacheHit = 'networkCacheHit';
  static const String phaseNetworkRedirect = 'networkRedirect';

  // Network stage names
  static const String stageDnsLookupStart = 'dns_lookup_start';
  static const String stageDnsLookupEnd = 'dns_lookup_end';
  static const String stageTcpConnectStart = 'tcp_connect_start';
  static const String stageTcpConnectEnd = 'tcp_connect_end';
  static const String stageTlsHandshakeStart = 'tls_handshake_start';
  static const String stageTlsHandshakeEnd = 'tls_handshake_end';
  static const String stageRequestSent = 'request_sent';
  static const String stageResponseStarted = 'response_started';
  static const String stageResponseReceived = 'response_received';

  LoadingState() {
    _startTime = DateTime.now();
    _lastPhaseTime = _startTime;
  }

  /// Registers a listener for a specific phase
  void addPhaseListener(String phaseName, PhaseEventCallback callback) {
    _phaseListeners.putIfAbsent(phaseName, () => []).add(callback);
  }

  /// Removes a listener for a specific phase
  void removePhaseListener(String phaseName, PhaseEventCallback callback) {
    _phaseListeners[phaseName]?.remove(callback);
  }

  /// Registers a listener for all phases
  void addAnyPhaseListener(PhaseEventCallback callback) {
    _anyPhaseListeners.add(callback);
  }

  /// Removes a listener for all phases
  void removeAnyPhaseListener(PhaseEventCallback callback) {
    _anyPhaseListeners.remove(callback);
  }

  /// Clears all listeners
  void clearAllListeners() {
    _phaseListeners.clear();
    _anyPhaseListeners.clear();
  }

  // Convenience methods for main phase listeners
  void onConstructor(PhaseEventCallback callback) => addPhaseListener(phaseConstructor, callback);
  void onInit(PhaseEventCallback callback) => addPhaseListener(phaseInit, callback);
  void onLoadStart(PhaseEventCallback callback) => addPhaseListener(phaseLoadStart, callback);
  void onPreload(PhaseEventCallback callback) => addPhaseListener(phasePreload, callback);
  void onResolveEntrypoint(PhaseEventCallback callback) => addPhaseListener(phaseResolveEntrypoint, callback);
  void onResolveEntrypointStart(PhaseEventCallback callback) => addPhaseListener('resolveEntrypoint.start', callback);
  void onResolveEntrypointEnd(PhaseEventCallback callback) => addPhaseListener('resolveEntrypoint.end', callback);
  void onEvaluateStart(PhaseEventCallback callback) => addPhaseListener(phaseEvaluateStart, callback);
  void onParseHTML(PhaseEventCallback callback) => addPhaseListener(phaseParseHTML, callback);
  void onParseHTMLStart(PhaseEventCallback callback) => addPhaseListener('parseHTML.start', callback);
  void onParseHTMLEnd(PhaseEventCallback callback) => addPhaseListener('parseHTML.end', callback);
  void onEvaluateScripts(PhaseEventCallback callback) => addPhaseListener(phaseEvaluateScripts, callback);
  void onEvaluateComplete(PhaseEventCallback callback) => addPhaseListener(phaseEvaluateComplete, callback);
  void onDOMContentLoaded(PhaseEventCallback callback) => addPhaseListener(phaseDOMContentLoaded, callback);
  void onWindowLoad(PhaseEventCallback callback) => addPhaseListener(phaseWindowLoad, callback);
  void onBuildRootView(PhaseEventCallback callback) => addPhaseListener(phaseBuildRootView, callback);
  void onFirstPaint(PhaseEventCallback callback) => addPhaseListener(phaseFirstPaint, callback);
  void onFirstContentfulPaint(PhaseEventCallback callback) => addPhaseListener(phaseFirstContentfulPaint, callback);
  void onLargestContentfulPaint(PhaseEventCallback callback) => addPhaseListener(phaseLargestContentfulPaint, callback);
  void onFinalLargestContentfulPaint(PhaseEventCallback callback) => addPhaseListener('finalLargestContentfulPaint', callback);
  void onAttachToFlutter(PhaseEventCallback callback) => addPhaseListener(phaseAttachToFlutter, callback);
  void onDetachFromFlutter(PhaseEventCallback callback) => addPhaseListener(phaseDetachFromFlutter, callback);
  void onDispose(PhaseEventCallback callback) => addPhaseListener(phaseDispose, callback);

  // Script-related phase listeners
  void onScriptQueue(PhaseEventCallback callback) => addPhaseListener(phaseScriptQueue, callback);
  void onScriptLoadStart(PhaseEventCallback callback) => addPhaseListener(phaseScriptLoadStart, callback);
  void onScriptLoadComplete(PhaseEventCallback callback) => addPhaseListener(phaseScriptLoadComplete, callback);
  void onScriptExecuteStart(PhaseEventCallback callback) => addPhaseListener(phaseScriptExecuteStart, callback);
  void onScriptExecuteComplete(PhaseEventCallback callback) => addPhaseListener(phaseScriptExecuteComplete, callback);

  /// Dispatches a phase event to registered listeners
  void _dispatchPhaseEvent(LoadingPhase phase) {
    // Calculate elapsed time from start
    final elapsed = _getAdjustedElapsedTime(phase);

    // Create the event with elapsed time
    final event = LoadingPhaseEvent(
      phase: phase,
      elapsed: elapsed,
    );

    // Dispatch to specific phase listeners
    final specificListeners = _phaseListeners[phase.name];
    if (specificListeners != null) {
      for (final listener in List.from(specificListeners)) {
        try {
          listener(event);
        } catch (e) {
          // Prevent listener errors from affecting the loading process
          print('Error in phase listener for ${phase.name}: $e');
        }
      }
    }

    // Dispatch to generic listeners
    for (final listener in List.from(_anyPhaseListeners)) {
      try {
        listener(event);
      } catch (e) {
        // Prevent listener errors from affecting the loading process
        print('Error in generic phase listener: $e');
      }
    }
  }

  /// Records a loading phase with optional parameters
  void recordPhase(String phaseName, {Map<String, dynamic>? parameters, String? parentPhase}) {
    final now = DateTime.now();
    final duration =
        _lastPhaseTime != null ? now.difference(_lastPhaseTime!) : null;

    final phase = LoadingPhase(
      name: phaseName,
      timestamp: now,
      parameters: parameters,
      duration: duration,
      parentPhase: parentPhase,
    );

    // Special handling for LCP candidates
    if (phaseName == phaseLargestContentfulPaint && !_lcpFinalized) {
      _lastLcpCandidate = phase;
      // Don't add to phases yet, just track as candidate
    } else if (parentPhase != null && _phases.containsKey(parentPhase)) {
      // Add as substep to parent phase
      _phases[parentPhase]!.addSubstep(phase);
    } else {
      // Add as top-level phase
      _phases[phaseName] = phase;
    }

    _lastPhaseTime = now;

    // Dispatch the phase event
    _dispatchPhaseEvent(phase);
  }

  /// Records the start of a phase and returns a function to record its completion
  VoidCallback recordPhaseStart(String phaseName,
      {Map<String, dynamic>? parameters}) {
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
  void recordNetworkRequestStart(
    String url, {
    String method = 'GET',
    Map<String, String>? headers,
    String? protocol,
    String? remoteAddress,
    int? remotePort,
  }) {
    // Check if there's already a pending request for this URL
    final existingRequest = _pendingRequests[url];
    if (existingRequest != null) {
      // Mark the existing request as superseded/cancelled
      existingRequest.error = 'Superseded by new request';
      existingRequest.endTime = DateTime.now();
      _pendingRequests.remove(url);
    }

    final request = LoadingNetworkRequest(
      url: url,
      method: method,
      startTime: DateTime.now(),
      requestHeaders: headers,
      protocol: protocol,
      remoteAddress: remoteAddress,
      remotePort: remotePort,
    );
    _pendingRequests[url] = request;
    _networkRequests.add(request);

    // Create a unique phase name for this network request
    final networkPhaseName = 'networkStart:$url';
    recordPhase(networkPhaseName, parameters: {
      'url': url,
      'method': method,
      'requestCount': _networkRequests.length,
      if (protocol != null) 'protocol': protocol,
    });
  }

  /// Records the completion of a network request
  void recordNetworkRequestComplete(
    String url, {
    int? statusCode,
    int? responseSize,
    String? contentType,
    Map<String, String>? responseHeaders,
    String? finalUrl,
  }) {
    final request = _pendingRequests[url];
    if (request != null) {
      request.endTime = DateTime.now();
      request.responseEnd = request.endTime;
      request.statusCode = statusCode;
      request.responseSize = responseSize;
      request.contentType = contentType;
      request.responseHeaders = responseHeaders;
      request.finalUrl = finalUrl ?? url;
      _pendingRequests.remove(url);

      // Record completion as a substep of the network phase
      final networkPhaseName = 'networkStart:$url';
      recordPhase('$networkPhaseName:complete', parameters: {
        'statusCode': statusCode,
        'responseSize': responseSize,
        'duration': request.duration?.inMilliseconds,
        'contentType': contentType,
        'fromCache': request.isFromCache,
        if (request.hasRedirects) 'redirectCount': request.redirectChain.length,
      }, parentPhase: networkPhaseName);
    }
  }

  /// Records a network request error
  void recordNetworkRequestError(String url, String error) {
    final request = _pendingRequests[url];
    if (request != null) {
      request.endTime = DateTime.now();
      request.error = error;
      _pendingRequests.remove(url);

      // Record error as a substep of the network phase
      final networkPhaseName = 'networkStart:$url';
      recordPhase('$networkPhaseName:error', parameters: {
        'error': error,
        'duration': request.duration?.inMilliseconds,
      }, parentPhase: networkPhaseName);
    }
  }

  /// Records a network request stage
  void recordNetworkRequestStage(String url, String stageName,
      {Map<String, dynamic>? metadata}) {
    final request = _pendingRequests[url];
    if (request != null) {
      request.addStage(stageName, metadata: metadata);

      // Update timing based on stage
      final now = DateTime.now();
      switch (stageName) {
        case stageDnsLookupStart:
          request.dnsStart = now;
          break;
        case stageDnsLookupEnd:
          request.dnsEnd = now;
          break;
        case stageTcpConnectStart:
          request.connectStart = now;
          break;
        case stageTcpConnectEnd:
          request.connectEnd = now;
          break;
        case stageTlsHandshakeStart:
          request.tlsStart = now;
          break;
        case stageTlsHandshakeEnd:
          request.tlsEnd = now;
          break;
        case stageRequestSent:
          request.requestStart = now;
          break;
        case stageResponseStarted:
          request.responseStart = now;
          break;
        case stageResponseReceived:
          request.responseEnd = now;
          break;
      }

      // Record as substep of the network start phase
      final networkPhaseName = 'networkStart:$url';
      recordPhase('$networkPhaseName:$stageName',
        parameters: metadata ?? {},
        parentPhase: networkPhaseName
      );
    }
  }

  /// Records cache information for a network request
  void recordNetworkRequestCacheInfo(
    String url, {
    required bool cacheHit,
    String? cacheType,
    DateTime? cacheEntryTime,
    Duration? cacheAge,
    Map<String, String>? cacheHeaders,
    int? cacheSize,
  }) {
    final request = _pendingRequests[url] ??
        _networkRequests.firstWhere(
          (r) => r.url == url,
          orElse: () => throw StateError('Request not found: $url'),
        );

    request.cacheInfo = NetworkCacheInfo(
      cacheHit: cacheHit,
      cacheType: cacheType,
      cacheEntryTime: cacheEntryTime,
      cacheAge: cacheAge,
      cacheHeaders: cacheHeaders,
      cacheSize: cacheSize,
    );

    if (cacheHit) {
      // Record cache hit as a substep of the network phase
      final networkPhaseName = 'networkStart:$url';
      recordPhase('$networkPhaseName:cache_hit', parameters: {
        'cacheType': cacheType ?? 'unknown',
        'cacheAge': cacheAge?.inSeconds,
        'cacheSize': cacheSize,
      }, parentPhase: networkPhaseName);
    }
  }

  /// Records a redirect for a network request
  void recordNetworkRequestRedirect(String originalUrl, String redirectUrl,
      {int? statusCode}) {
    final request = _pendingRequests[originalUrl];
    if (request != null) {
      request.redirectChain.add(redirectUrl);
      request.addStage('redirect', metadata: {
        'from': originalUrl,
        'to': redirectUrl,
        'statusCode': statusCode,
      });

      recordPhase(phaseNetworkRedirect, parameters: {
        'from': originalUrl,
        'to': redirectUrl,
        'statusCode': statusCode,
        'redirectCount': request.redirectChain.length,
      });
    }
  }

  /// Records an error that occurred during a specific phase
  void recordError(String phase, Object error,
      {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _errors.add(LoadingError(
      phase: phase,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// Records an error with the current phase context
  void recordCurrentPhaseError(Object error,
      {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    final currentPhase =
        _phases.values.isNotEmpty ? _phases.values.last.name : 'unknown';
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

    recordPhase(phaseScriptQueue, parameters: {
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

      recordPhase(phaseScriptLoadStart, parameters: {
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

      recordPhase(phaseScriptLoadComplete, parameters: {
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

      recordPhase(phaseScriptExecuteStart, parameters: {
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

      recordPhase(phaseScriptExecuteComplete, parameters: {
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

      recordPhase(phaseScriptError, parameters: {
        'source': script.isInline ? '<inline>' : source,
        'error': error,
      });
    }
  }

  /// Finalizes the LCP phase, marking the last candidate as final
  void finalizeLCP() {
    if (_lastLcpCandidate != null && !_lcpFinalized) {
      _lcpFinalized = true;
      // Add the last candidate to phases with isFinal flag
      final finalLcpPhase = LoadingPhase(
        name: phaseLargestContentfulPaint,
        timestamp: _lastLcpCandidate!.timestamp, // Use the candidate's timestamp
        parameters: {
          ..._lastLcpCandidate!.parameters,
          'isFinal': true,
        },
        duration: _lastLcpCandidate!.duration,
        parentPhase: _lastLcpCandidate!.parentPhase,
      );
      _phases[phaseLargestContentfulPaint] = finalLcpPhase;

      // Dispatch the final LCP event
      _dispatchPhaseEvent(finalLcpPhase);

      // Also dispatch a specific finalLargestContentfulPaint event
      final finalLcpEvent = LoadingPhase(
        name: 'finalLargestContentfulPaint',
        timestamp: _lastLcpCandidate!.timestamp,
        parameters: finalLcpPhase.parameters,
        duration: finalLcpPhase.duration,
      );
      _dispatchPhaseEvent(finalLcpEvent);
    }
  }

  /// Gets all script elements
  List<LoadingScriptElement> get scriptElements =>
      List.unmodifiable(_scriptElements);

  /// Gets count of successful scripts
  int get successfulScriptsCount =>
      _scriptElements.where((s) => s.isSuccessful).length;

  /// Gets count of failed scripts
  int get failedScriptsCount =>
      _scriptElements.where((s) => s.error != null).length;

  /// Dumps the loading state as a LoadingStateDump object that can be formatted as text or JSON
  LoadingStateDump dump({bool verbose = false}) {
    final totalDuration = this.totalDuration ?? Duration.zero;

    return LoadingStateDump(
      startTime: _startTime ?? DateTime.now(),
      totalDuration: totalDuration,
      phases: phases,
      networkRequests: networkRequests,
      errors: errors,
      scriptElements: scriptElements,
      dumper: this,
    );
  }

  /// Legacy method for backward compatibility - returns formatted string
  String dumpAsString({bool verbose = false}) {
    return dump(verbose: verbose).toString();
  }

  // Helper method to format the dump as string (moved to LoadingStateDump.toString)
  String _formatDump({bool verbose = false}) {
    if (_phases.isEmpty) {
      return 'No loading phases recorded';
    }

    final buffer = StringBuffer();
    final totalDuration = _phases.values.last.timestamp.difference(_startTime!);

    // Calculate network statistics
    final completedRequests =
        _networkRequests.where((r) => r.isComplete).toList();
    final successfulRequests =
        completedRequests.where((r) => r.isSuccessful).toList();
    final failedRequests = completedRequests
        .where((r) => !r.isSuccessful && r.error == null)
        .toList();
    final errorRequests =
        _networkRequests.where((r) => r.error != null).toList();
    final cachedRequests =
        _networkRequests.where((r) => r.isFromCache).toList();
    final redirectedRequests =
        _networkRequests.where((r) => r.hasRedirects).toList();
    final totalResponseSize =
        completedRequests.fold<int>(0, (sum, r) => sum + (r.responseSize ?? 0));
    final totalNetworkTime = completedRequests.fold<int>(
        0, (sum, r) => sum + (r.duration?.inMilliseconds ?? 0));

    // Header
    buffer.writeln(
        '\n╔══════════════════════════════════════════════════════════════════════════════╗');
    buffer.writeln(
        '║                        WebFController Loading State Dump                      ║');
    buffer.writeln(
        '╠══════════════════════════════════════════════════════════════════════════════╣');
    buffer.writeln('║ Total Duration: ${_formatDuration(totalDuration)}');
    buffer.writeln('║ Phases: ${_phases.length}');
    if (_errors.isNotEmpty) {
      buffer.writeln('║ ⚠️  Errors: ${_errors.length}');
    }
    buffer.writeln(
        '║ Network Requests: ${_networkRequests.length} (${successfulRequests.length} successful, ${failedRequests.length} failed, ${errorRequests.length} errors)');
    if (_networkRequests.isNotEmpty) {
      buffer.writeln(
          '║ Total Network Time: ${_formatDuration(Duration(milliseconds: totalNetworkTime))}');
      buffer.writeln('║ Total Downloaded: ${_formatBytes(totalResponseSize)}');
      if (cachedRequests.isNotEmpty) {
        buffer.writeln(
            '║ Cache Hits: ${cachedRequests.length} (${(cachedRequests.length / _networkRequests.length * 100).toStringAsFixed(1)}%)');
      }
      if (redirectedRequests.isNotEmpty) {
        buffer.writeln('║ Redirected Requests: ${redirectedRequests.length}');
      }
    }
    if (_scriptElements.isNotEmpty) {
      buffer.writeln(
          '║ Script Elements: ${_scriptElements.length} ($successfulScriptsCount successful, $failedScriptsCount failed)');
    }
    buffer.writeln(
        '╠══════════════════════════════════════════════════════════════════════════════╣');

    // Main Loading Phases Table
    buffer.writeln('║ Loading Phases:');
    buffer.writeln('║');
    buffer.writeln('║ ┌─────────────────────────────────┬──────────────┬──────────┬────────────┐');
    buffer.writeln('║ │ Phase                           │ Time         │ Elapsed  │ Percentage │');
    buffer.writeln('║ ├─────────────────────────────────┼──────────────┼──────────┼────────────┤');

    // Key phases to display in order
    final keyPhases = <MapEntry<String, String>>[
      MapEntry(phaseInit, 'Initialize'),
      MapEntry(phasePreload, 'Preload'),
      MapEntry(phaseLoadStart, 'Load Start'),
      MapEntry(phaseResolveEntrypoint, 'Resolve Entrypoint'),
      MapEntry(phaseEvaluateStart, 'Evaluate Start'),
      MapEntry(phaseParseHTML, 'Parse HTML'),
      MapEntry(phaseEvaluateScripts, 'Evaluate Scripts'),
      MapEntry(phaseEvaluateComplete, 'Evaluate Complete'),
      MapEntry(phaseDOMContentLoaded, 'DOM Content Loaded'),
      MapEntry(phaseBuildRootView, 'Build Root View'),
      MapEntry(phaseFirstPaint, 'First Paint (FP)'),
      MapEntry(phaseFirstContentfulPaint, 'First Contentful Paint (FCP)'),
      MapEntry(phaseLargestContentfulPaint, 'Largest Contentful Paint (LCP)'),
    ];

    DateTime? previousTime = _startTime;
    for (final phaseEntry in keyPhases) {
      final phaseName = phaseEntry.key;
      final displayName = phaseEntry.value;
      if (_phases.containsKey(phaseName)) {
        final phase = _phases[phaseName]!;
        final elapsed = phase.timestamp.difference(_startTime!);
        final percentage = totalDuration.inMilliseconds > 0
            ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100)
                .toStringAsFixed(1)
            : '0.0';

        // Calculate time since previous phase
        final timeSincePrev = previousTime != null
            ? phase.timestamp.difference(previousTime)
            : Duration.zero;
        previousTime = phase.timestamp;

        final phaseDisplay = displayName.padRight(31);
        final timeDisplay = _formatDuration(timeSincePrev).padLeft(12);
        final elapsedDisplay = _formatDuration(elapsed).padLeft(8);
        final percentDisplay = '$percentage%'.padLeft(10);

        buffer.writeln('║ │ $phaseDisplay │ $timeDisplay │ $elapsedDisplay │ $percentDisplay │');

        // Display substeps if any
        if (phase.substeps.isNotEmpty && verbose) {
          for (final substep in phase.substeps) {
            final substepElapsed = substep.timestamp.difference(_startTime!);
            final substepPercentage = totalDuration.inMilliseconds > 0
                ? (substepElapsed.inMilliseconds / totalDuration.inMilliseconds * 100)
                    .toStringAsFixed(1)
                : '0.0';

            final substepName = substep.name.split(':').last; // Get the last part after colon
            final substepDisplay = '  └─ $substepName'.padRight(31);
            final substepTimeDisplay = _formatDuration(substep.duration ?? Duration.zero).padLeft(12);
            final substepElapsedDisplay = _formatDuration(substepElapsed).padLeft(8);
            final substepPercentDisplay = '$substepPercentage%'.padLeft(10);

            buffer.writeln('║ │ $substepDisplay │ $substepTimeDisplay │ $substepElapsedDisplay │ $substepPercentDisplay │');
          }
        }
      }
    }

    buffer.writeln('║ └─────────────────────────────────┴──────────────┴──────────┴────────────┘');

    // Show additional phases in verbose mode
    if (verbose) {
      final additionalPhases = _phases.entries
          .where((entry) => !keyPhases.any((kp) => kp.key == entry.key))
          .toList();

      if (additionalPhases.isNotEmpty) {
        buffer.writeln('║');
        buffer.writeln('║ Additional Phases:');
        buffer.writeln('║');
        buffer.writeln('║ ┌─────────────────────────────────────────────────┬──────────────┬────────────┐');
        buffer.writeln('║ │ Phase                                           │ Elapsed      │ Percentage │');
        buffer.writeln('║ ├─────────────────────────────────────────────────┼──────────────┼────────────┤');

        for (final entry in additionalPhases) {
          final elapsed = entry.value.timestamp.difference(_startTime!);
          final percentage = totalDuration.inMilliseconds > 0
              ? (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100)
                  .toStringAsFixed(1)
              : '0.0';

          // Special handling for network phases that have substeps
          if (entry.key.startsWith('networkStart:')) {
            final url = entry.key.substring('networkStart:'.length);

            // Find the corresponding network request to get additional info
            final request = _networkRequests.firstWhere(
              (r) => r.url == url,
              orElse: () => LoadingNetworkRequest(
                url: url,
                method: 'GET',
                startTime: entry.value.timestamp,
              ),
            );

            // Build status string
            String statusInfo = '';
            if (request.error != null) {
              statusInfo = request.error == 'Superseded by new request' ? ' [REPLACED]' : ' [ERROR]';
            } else if (request.isFromCache) {
              statusInfo = ' [CACHED]';
            } else if (request.statusCode != null) {
              statusInfo = ' [${request.statusCode}]';
            }

            // Add response size if available
            if (request.responseSize != null) {
              statusInfo += ' ${_formatBytes(request.responseSize!)}';
            }

            final networkLabel = 'Network:$statusInfo';
            final phaseDisplay = networkLabel.padRight(47);
            final elapsedDisplay = _formatDuration(elapsed).padLeft(12);
            final percentDisplay = '$percentage%'.padLeft(10);

            buffer.writeln('║ │ $phaseDisplay │ $elapsedDisplay │ $percentDisplay │');

            // Show full URL as the first substep
            final urlDisplay = '  └─ URL: $url';
            if (urlDisplay.length > 47) {
              // Split long URLs into multiple lines
              final words = url.split('/');
              var currentLine = '  └─ URL: ';
              for (int i = 0; i < words.length; i++) {
                final word = words[i];
                final separator = i < words.length - 1 ? '/' : '';
                if (currentLine.length + word.length + separator.length > 47) {
                  buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
                  currentLine = '       ';
                }
                currentLine += word + separator;
              }
              if (currentLine.trim().isNotEmpty) {
                buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
              }
            } else {
              buffer.writeln('║ │ ${urlDisplay.padRight(47)} │              │            │');
            }

            // Show substeps (network stages)
            if (entry.value.substeps.isNotEmpty) {
              for (final substep in entry.value.substeps) {
                final substepElapsed = substep.timestamp.difference(_startTime!);
                final substepPercentage = totalDuration.inMilliseconds > 0
                    ? (substepElapsed.inMilliseconds / totalDuration.inMilliseconds * 100)
                        .toStringAsFixed(1)
                    : '0.0';

                final substepName = substep.name.split(':').last;
                final substepDisplay = '  └─ ${substepName.replaceAll('_', ' ')}';
                final paddedSubstepDisplay = substepDisplay.padRight(47);
                final substepElapsedDisplay = _formatDuration(substepElapsed).padLeft(12);
                final substepPercentDisplay = '$substepPercentage%'.padLeft(10);

                buffer.writeln('║ │ $paddedSubstepDisplay │ $substepElapsedDisplay │ $substepPercentDisplay │');
              }
            }
          } else {
            // Regular phase
            final phaseName = entry.key;
            final displayName = phaseName.length > 47
                ? '${phaseName.substring(0, 44)}...'
                : phaseName.padRight(47);

            final elapsedDisplay = _formatDuration(elapsed).padLeft(12);
            final percentDisplay = '$percentage%'.padLeft(10);

            buffer.writeln('║ │ $displayName │ $elapsedDisplay │ $percentDisplay │');

            // Show parameters as substeps if any
            if (entry.value.parameters.isNotEmpty) {
              entry.value.parameters.forEach((key, value) {
                final paramDisplay = '  └─ $key: $value';

                // Special handling for URL-like parameters - show full URL
                final valueStr = value.toString();
                final isUrlLike = (key == 'url' || key == 'source' || valueStr.contains('://'));

                if (isUrlLike && valueStr.length > 40) {
                  buffer.writeln('║ │ ${'  └─ $key:'.padRight(47)} │              │            │');

                  // Split long URL into multiple lines
                  final urlParts = valueStr.split('/');
                  var currentLine = '       ';

                  for (int i = 0; i < urlParts.length; i++) {
                    final part = urlParts[i];
                    final separator = i < urlParts.length - 1 ? '/' : '';

                    if (currentLine.length + part.length + separator.length > 47) {
                      if (currentLine.trim().isNotEmpty) {
                        buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
                      }
                      currentLine = '       ';
                    }
                    currentLine += part + separator;
                  }

                  if (currentLine.trim().isNotEmpty) {
                    buffer.writeln('║ │ ${currentLine.padRight(47)} │              │            │');
                  }
                } else {
                  // Regular parameter display
                  final paddedParamDisplay = paramDisplay.length > 47
                      ? '${paramDisplay.substring(0, 44)}...'
                      : paramDisplay.padRight(47);
                  buffer.writeln('║ │ $paddedParamDisplay │              │            │');
                }
              });
            }
          }
        }

        buffer.writeln('║ └─────────────────────────────────────────────────┴──────────────┴────────────┘');
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
                    : script.source)
                .padRight(maxSourceLength);

        final typeStr = script.isModule ? 'module' : 'script';
        final asyncStr =
            script.isAsync ? 'async' : (script.isDefer ? 'defer' : 'sync ');
        final statusStr = script.error != null
            ? 'ERROR'
            : (script.readyState == 'complete'
                ? 'OK'
                : script.readyState.toUpperCase());

        String durationStr = '-';
        if (script.totalDuration != null) {
          durationStr = _formatDuration(script.totalDuration!);
        }

        String sizeStr = '-';
        if (script.dataSize != null) {
          sizeStr = _formatBytes(script.dataSize!);
        }

        buffer.writeln(
            '║ $displaySource │ $typeStr │ $asyncStr │ $statusStr │ ${sizeStr.padLeft(10)} │ ${durationStr.padLeft(8)}');

        // Show error details if any
        if (script.error != null && verbose) {
          buffer.writeln('║   └─ Error: ${script.error}');
        }
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

        buffer.writeln(
            '║ ERROR at +${_formatDuration(errorOffset)} during ${error.phase}:');
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
    buffer.writeln(
        '╚══════════════════════════════════════════════════════════════════════════════╝');

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
    _lastLcpCandidate = null;
    _lcpFinalized = false;
    _startTime = DateTime.now();
    _lastPhaseTime = _startTime;
  }

  /// Gets all recorded phases
  List<LoadingPhase> get phases => _phases.values.toList();

  /// Gets all network requests
  List<LoadingNetworkRequest> get networkRequests =>
      List.unmodifiable(_networkRequests);

  /// Gets all recorded errors
  List<LoadingError> get errors => List.unmodifiable(_errors);

  /// Checks if there are any errors
  bool get hasErrors => _errors.isNotEmpty;

  /// Calculates the total duration according to the formula:
  /// Part 1: Time between 'init' and 'scriptLoadComplete'
  /// Part 2: Time between 'attachToFlutter' and 'largestContentfulPaint'
  /// Total Duration = Part 1 + Part 2
  Duration? _calculateTotalDuration() {
    if (_phases.isEmpty || _startTime == null) return null;

    Duration totalDuration = Duration.zero;

    // Part 1: Time from init to scriptLoadComplete
    // Find init phase
    LoadingPhase? initPhase;
    for (final phase in _phases.values) {
      if (phase.name == phaseInit) {
        initPhase = phase;
        break;
      }
    }

    // Find scriptLoadComplete phase
    LoadingPhase? scriptLoadCompletePhase;
    for (final phase in _phases.values) {
      if (phase.name == phaseScriptLoadComplete) {
        scriptLoadCompletePhase = phase;
      }
    }

    // Calculate Part 1
    if (initPhase != null && scriptLoadCompletePhase != null) {
      totalDuration += scriptLoadCompletePhase.timestamp.difference(initPhase.timestamp);
    }

    // Part 2: Time from attachToFlutter to LCP
    // Find attachToFlutter phase
    LoadingPhase? attachToFlutterPhase;
    for (final phase in _phases.values) {
      if (phase.name == phaseAttachToFlutter) {
        attachToFlutterPhase = phase;
        break;
      }
    }

    // Find LCP phase
    LoadingPhase? lcpPhase;
    for (final phase in _phases.values) {
      if (phase.name == phaseLargestContentfulPaint) {
        lcpPhase = phase;
      }
    }

    // Calculate Part 2
    if (attachToFlutterPhase != null && lcpPhase != null) {
      totalDuration += lcpPhase.timestamp.difference(attachToFlutterPhase.timestamp);
    }

    // If we couldn't calculate using the new method, fall back to the old calculation
    if (totalDuration == Duration.zero) {
      return _phases.values.last.timestamp.difference(_startTime!);
    }

    return totalDuration;
  }

  /// Calculates the pause duration between scriptLoadComplete and attachToFlutter
  /// This is used to adjust elapsed times for phases after the pause
  Duration _getPauseDuration() {
    LoadingPhase? scriptLoadCompletePhase;
    LoadingPhase? attachToFlutterPhase;

    for (final phase in _phases.values) {
      if (phase.name == phaseScriptLoadComplete) {
        scriptLoadCompletePhase = phase;
      }
      if (phase.name == phaseAttachToFlutter) {
        attachToFlutterPhase = phase;
      }
    }

    if (scriptLoadCompletePhase != null && attachToFlutterPhase != null &&
        attachToFlutterPhase.timestamp.isAfter(scriptLoadCompletePhase.timestamp)) {
      return attachToFlutterPhase.timestamp.difference(scriptLoadCompletePhase.timestamp);
    }

    return Duration.zero;
  }

  /// Calculates the adjusted elapsed time for a phase, accounting for the pause
  /// and reset between scriptLoadComplete and attachToFlutter in preload mode
  Duration _getAdjustedElapsedTime(LoadingPhase phase) {
    if (_startTime == null) return Duration.zero;

    // Find key phases
    LoadingPhase? initPhase;
    LoadingPhase? scriptLoadCompletePhase;
    LoadingPhase? attachToFlutterPhase;

    for (final p in _phases.values) {
      if (p.name == phaseInit) {
        initPhase = p;
      }
      if (p.name == phaseScriptLoadComplete) {
        scriptLoadCompletePhase = p;
      }
      if (p.name == phaseAttachToFlutter) {
        attachToFlutterPhase = p;
      }
    }

    // If we don't have the required phases for preload mode, use raw elapsed time
    if (scriptLoadCompletePhase == null || attachToFlutterPhase == null ||
        !attachToFlutterPhase.timestamp.isAfter(scriptLoadCompletePhase.timestamp)) {
      return phase.timestamp.difference(_startTime!);
    }

    // Special handling for constructor phase - always show elapsed from start
    if (phase.name == phaseConstructor) {
      return phase.timestamp.difference(_startTime!);
    }

    // For phases before or at scriptLoadComplete, calculate elapsed from init
    if (!phase.timestamp.isAfter(scriptLoadCompletePhase.timestamp)) {
      if (initPhase != null && phase.name != phaseInit) {
        return phase.timestamp.difference(initPhase.timestamp);
      }
      // For init phase itself, show 0
      if (phase.name == phaseInit) {
        return Duration.zero;
      }
      return phase.timestamp.difference(_startTime!);
    }

    // For attachToFlutter phase, the elapsed time is 0 (timer resets here)
    if (phase.name == phaseAttachToFlutter) {
      return Duration.zero;
    }

    // For phases after attachToFlutter, calculate elapsed from attachToFlutter
    // This gives us the time since the timer was reset
    return phase.timestamp.difference(attachToFlutterPhase.timestamp);
  }

  /// Gets the total duration from start to the last recorded phase
  Duration? get totalDuration {
    return _calculateTotalDuration();
  }
}
