/*
 * Minimal CSS performance instrumentation (debug-only, gated by DebugFlags.enableCssPerf).
 */

import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/src/foundation/logger.dart';

class CSSPerf {
  // Parser metrics
  static int _parserParseCalls = 0;
  static int _parserRulesParsedTotal = 0;
  static int _parserStyleRulesTotal = 0;
  static int _parserMediaRulesTotal = 0;
  static int _parserKeyframesTotal = 0;
  static int _parserFontFaceTotal = 0;
  static int _parserParseMsTotal = 0; // milliseconds

  static int _parserInlineCalls = 0;
  static int _parserInlinePropsTotal = 0;
  static int _parserInlineMsTotal = 0;

  // Indexing (RuleSet) metrics
  static int _indexAddRulesCalls = 0;
  static int _indexRulesAddedTotal = 0;
  static int _indexAddMsTotal = 0;

  // Document.handleStyleSheets indexing pass
  static int _handleSheetsCalls = 0;
  static int _handleSheetsRulesTotal = 0;
  static int _handleSheetsMsTotal = 0;

  // Selector matching metrics
  static int _matchCalls = 0;
  static int _matchCandidatesTotal = 0;
  static int _matchMatchedTotal = 0;
  static int _matchMsTotal = 0;

  static int _pseudoMatchCalls = 0;
  static int _pseudoMatchedTotal = 0;
  static int _pseudoMatchMsTotal = 0;

  // Memoization metrics
  static int _memoHits = 0;
  static int _memoMisses = 0;
  static int _memoEvictions = 0;
  static int _memoCacheSamples = 0;
  static int _memoCacheSizeTotal = 0;

  // Recalc and flush metrics
  static int _recalcCalls = 0;
  static int _recalcMsTotal = 0;
  static int _recalcDeferredMarks = 0;

  static int _flushCalls = 0;
  static int _flushDirtyTotal = 0;
  static int _flushRootRecalcCount = 0;
  static int _flushMsTotal = 0;

  // Stylesheet activities
  static int _styleAdds = 0; // pending stylesheets appended
  static int _styleFlushesBatched = 0; // flushes triggered by scheduled batch
  static int _styleFlushesImmediate = 0; // flushes without batch scheduling

  static bool get enabled => DebugFlags.enableCssPerf;

  // Recorders
  static void recordParseRules({
    required int durationMs,
    required int totalRules,
    required int styleRules,
    required int mediaRules,
    required int keyframes,
    required int fontFace,
  }) {
    if (!enabled) return;
    _parserParseCalls++;
    _parserParseMsTotal += durationMs;
    _parserRulesParsedTotal += totalRules;
    _parserStyleRulesTotal += styleRules;
    _parserMediaRulesTotal += mediaRules;
    _parserKeyframesTotal += keyframes;
    _parserFontFaceTotal += fontFace;
  }

  static void recordParseInlineStyle(
      {required int durationMs, required int propertyCount}) {
    if (!enabled) return;
    _parserInlineCalls++;
    _parserInlineMsTotal += durationMs;
    _parserInlinePropsTotal += propertyCount;
  }

  static void recordIndexAddRules(
      {required int durationMs, required int addedRules}) {
    if (!enabled) return;
    _indexAddRulesCalls++;
    _indexAddMsTotal += durationMs;
    _indexRulesAddedTotal += addedRules;
  }

  static void recordHandleStyleSheets(
      {required int durationMs,
      required int sheetCount,
      required int ruleCount}) {
    if (!enabled) return;
    _handleSheetsCalls++;
    _handleSheetsMsTotal += durationMs;
    _handleSheetsRulesTotal += ruleCount;
  }

  static void recordStyleAdded() {
    if (!enabled) return;
    _styleAdds++;
  }

  static void recordStyleFlush({required bool batched}) {
    if (!enabled) return;
    if (batched) {
      _styleFlushesBatched++;
    } else {
      _styleFlushesImmediate++;
    }
  }

  static void recordMatch(
      {required int durationMs,
      required int candidateCount,
      required int matchedCount}) {
    if (!enabled) return;
    _matchCalls++;
    _matchMsTotal += durationMs;
    _matchCandidatesTotal += candidateCount;
    _matchMatchedTotal += matchedCount;
  }

  static void recordPseudoMatch(
      {required int durationMs, required int matchedCount}) {
    if (!enabled) return;
    _pseudoMatchCalls++;
    _pseudoMatchMsTotal += durationMs;
    _pseudoMatchedTotal += matchedCount;
  }

  static void recordRecalc({required int durationMs}) {
    if (!enabled) return;
    _recalcCalls++;
    _recalcMsTotal += durationMs;
  }

  static void recordRecalcDeferredMark() {
    if (!enabled) return;
    _recalcDeferredMarks++;
  }

  static void recordMemo({required bool hit}) {
    if (!enabled) return;
    if (hit) {
      _memoHits++;
    } else {
      _memoMisses++;
    }
  }

  // Records an LRU eviction for matched-rules memoization.
  static void recordMemoEviction() {
    if (!enabled) return;
    _memoEvictions++;
  }

  // Records a sample of current per-element memo cache size to build a rough
  // average across calls. Keep this lightweight.
  static void recordMemoCacheSample({required int size}) {
    if (!enabled) return;
    _memoCacheSamples++;
    _memoCacheSizeTotal += size;
  }

  static int get memoEvictions => _memoEvictions;
  static double get memoAvgCacheSize =>
      _memoCacheSamples == 0 ? 0.0 : _memoCacheSizeTotal / _memoCacheSamples;

  static int get memoHits => _memoHits;
  static int get memoMisses => _memoMisses;

  static void recordFlush(
      {required int durationMs,
      required int dirtyCount,
      required bool recalcFromRoot}) {
    if (!enabled) return;
    _flushCalls++;
    _flushMsTotal += durationMs;
    _flushDirtyTotal += dirtyCount;
    if (recalcFromRoot) _flushRootRecalcCount++;

    // Emit a concise one-line summary per flush while perf is enabled
    // to observe live behavior without overwhelming logs.
    if (DebugFlags.enableCssLogs) {
      cssLogger.fine(
          '[perf] flush dt=${durationMs}ms dirty=$dirtyCount root=$recalcFromRoot' +
              ' (recalc calls total=$_recalcCalls, match calls total=$_matchCalls)');
    }
  }

  static void reset() {
    _parserParseCalls = 0;
    _parserRulesParsedTotal = 0;
    _parserStyleRulesTotal = 0;
    _parserMediaRulesTotal = 0;
    _parserKeyframesTotal = 0;
    _parserFontFaceTotal = 0;
    _parserParseMsTotal = 0;

    _parserInlineCalls = 0;
    _parserInlinePropsTotal = 0;
    _parserInlineMsTotal = 0;

    _indexAddRulesCalls = 0;
    _indexRulesAddedTotal = 0;
    _indexAddMsTotal = 0;

    _handleSheetsCalls = 0;
    _handleSheetsRulesTotal = 0;
    _handleSheetsMsTotal = 0;

    _matchCalls = 0;
    _matchCandidatesTotal = 0;
    _matchMatchedTotal = 0;
    _matchMsTotal = 0;

    _pseudoMatchCalls = 0;
    _pseudoMatchedTotal = 0;
    _pseudoMatchMsTotal = 0;

    _recalcCalls = 0;
    _recalcMsTotal = 0;
    _recalcDeferredMarks = 0;

    _memoHits = 0;
    _memoMisses = 0;
    _memoEvictions = 0;
    _memoCacheSamples = 0;
    _memoCacheSizeTotal = 0;

    _flushCalls = 0;
    _flushDirtyTotal = 0;
    _flushRootRecalcCount = 0;
    _flushMsTotal = 0;

    _styleAdds = 0;
    _styleFlushesBatched = 0;
    _styleFlushesImmediate = 0;
  }

  static void dumpSummary() {
    if (!enabled) return;
    cssLogger.fine('[perf] CSS summary:'
        ' parseCalls=$_parserParseCalls rules=$_parserRulesParsedTotal style=$_parserStyleRulesTotal'
        ' media=$_parserMediaRulesTotal keyframes=$_parserKeyframesTotal fontFace=$_parserFontFaceTotal'
        ' parseMs=$_parserParseMsTotal inlineCalls=$_parserInlineCalls inlineProps=$_parserInlinePropsTotal'
        ' inlineMs=$_parserInlineMsTotal');
    cssLogger.fine(
        '[perf] index addCalls=$_indexAddRulesCalls addRules=$_indexRulesAddedTotal addMs=$_indexAddMsTotal'
        ' handleCalls=$_handleSheetsCalls handleRules=$_handleSheetsRulesTotal handleMs=$_handleSheetsMsTotal');
    cssLogger.fine(
        '[perf] match calls=$_matchCalls candidates=$_matchCandidatesTotal matched=$_matchMatchedTotal ms=$_matchMsTotal'
        ' pseudoCalls=$_pseudoMatchCalls pseudoMatched=$_pseudoMatchedTotal pseudoMs=$_pseudoMatchMsTotal'
        ' memoHits=$_memoHits memoMisses=$_memoMisses memoEvict=$_memoEvictions memoAvgSize=' +
            memoAvgCacheSize.toStringAsFixed(2));
    cssLogger.fine('[perf] recalc calls=$_recalcCalls recalcMs=$_recalcMsTotal'
        ' deferredMarks=$_recalcDeferredMarks'
        ' flush calls=$_flushCalls dirtyTotal=$_flushDirtyTotal rootCount=$_flushRootRecalcCount flushMs=$_flushMsTotal'
        ' styleAdds=$_styleAdds styleFlushes(batched=$_styleFlushesBatched immediate=$_styleFlushesImmediate)');
  }
}
