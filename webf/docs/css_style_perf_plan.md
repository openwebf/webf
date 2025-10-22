# CSS Stylesheet & Style Recalc – Performance Plan

Owner: webf/css
Status: Workstream 1 delivered & validated — Workstream 2 (flagged) in progress
Scope: Dart CSS pipeline (parse → index → match → cascade → recalc)

## Goals
- Reduce total selector matching work per flush/recalc.
- Reduce style recalculation overhead without sacrificing correctness.
- Keep changes incremental, guarded by flags where appropriate.

## Baseline (from CSSPerf counters)
- Parser: fast; not a primary bottleneck.
- Indexing: fast; negligible cost.
- Matching: heavy (many candidates examined, high total ms).
- Recalc: dominant total cost; many element-level recalcs outside flush.

## Workstream 1: Targeted Invalidation (High ROI)
Problem: StyleNodeManager walks the entire tree to find affected elements when stylesheets change.

Plan:
1) Add fast indices on Document:
   - elementsByClass: Map<String, List<Element>>
   - elementsByAttr: Map<String, List<Element>> (keyed by attribute name)
   (elementsByID already exists.)

2) Maintain indices:
   - Update in Element.className setter (add/remove classes).
   - Update in Element.internalSetAttribute/removeAttribute (attribute presence keys).

3) In StyleNodeManager.invalidateElementStyle():
   - From changedRuleSet, collect impacted keys by category (id, class, attribute).
   - Mark only those elements dirty via indices.
   - Fallback: for tag/universal impacts, retain current full-tree scan.

Expected impact:
- Large drop in “match calls” and candidate counts during stylesheet updates.
- Reduce style recalculation work to only impacted elements.

Risk/Notes:
- Index maintenance must respect Node connectivity (only index connected elements).
- Attribute value-dependent selectors (e.g., [attr^=val]) still require evaluator; we only prefilter by presence key.

## Workstream 2: Matched-Rules Memoization (Medium ROI)
Problem: Recalculations re-run matching even when selector-relevant keys for an element didn’t change.

Plan:
1) Add per-element cache entry keyed by:
   - (ruleSetVersion, tagName, id, sorted class list, sorted attribute name list used in selectors)
2) On _applySheetStyle(): reuse cached matched rule list when fingerprint unchanged; otherwise re-match and update cache.

Expected impact:
- Reduce match time for inherited or external changes (e.g., viewport/dark-mode toggles) where element keys are stable.

Risk/Notes:
- Memory footprint; cap cache size (LRU) and/or attach to Element with limited entries.
- Ensure cache invalidated when ruleSetVersion changes (after stylesheet updates).

## Workstream 3: Selector Matching Micro-optimizations (Supportive)
Plan:
- Reuse a single SelectorEvaluator per matchedRules() call.
- Pre-check ancestry keys for descendant combinators before heavy matching (cheap walk to detect required id/class/tag).

Expected impact:
- Lower cost per match, especially in deep trees.

## Workstream 4: Batch Recalc Triggers (Guarded)
Problem: Many immediate recalc calls from attribute/class/id setters.

Plan:
- Introduce an optional code path to mark element dirty and defer to Document.flushStyle(), instead of immediate recalc.
- Gate behind a feature flag; keep current behavior as default for safety.

Expected impact:
- Fewer total recalc calls; more work processed in batches.

Risk/Notes:
- Must ensure synchronous APIs depending on computed style are still correct (Window.getComputedStyle triggers updateStyleIfNeeded()).

## Measurement
Use CSSPerf counters (DebugFlags.enableCssPerf):
- Parser: parseCalls/parseMs (already low; track regressions only).
- Indexing: handleCalls/handleMs.
- Matching: match calls, candidates, matched, ms; pseudo matching stats.
- Recalc: calls, ms.
- Flush: calls, dirty total, rootCount, ms.

Success criteria (qualitative):
- Significant decrease in match candidates and match ms total for stylesheet changes.
- Decrease in recalc calls and recalc ms total over common interactions.

## Progress To Date

Changes landed (W1):
- Added Document indices: elementsByClass, elementsByAttr for targeted invalidation.
- Maintained indices in Element on connect/disconnect and class/attribute changes.
- StyleNodeManager now invalidates by id/class/attr via indices; uses bounded fallback scan for tag/universal/pseudo.
- Flush ordering updates active stylesheets before consulting dirty set (so only impacted nodes are marked).
- Suppressed generic childList dirty marks for <head>/<html> to avoid unintended root-wide recalcs.
- @import rules flattened; sheet marked pending and routed through targeted invalidation (no root mark).
- Tracing flag added for deep diagnostics; optional memoization flag in place (off by default).
- Validation: Full Flutter/webf test suite passes with targeted invalidation enabled.

Workstream 2 progress:
- Element-level matched rule memoization seeded behind `DebugFlags.enableCssMemoization`; fingerprint keyed by ruleSetVersion, tag, id, classes, and targeted attribute/value pairs.
- Per-element LRU cache (capacity=4) for matched rules replaces single-entry cache; version-aware pruning on `ruleSetVersion` changes; guarded by the same flag.
- CSSPerf now tracks memo hits/misses plus evictions and average per-element cache size (`memoEvict`, `memoAvgSize`); flush trace includes totals when tracing is enabled.
- Added widget regression coverage (`test/src/css/memoization_test.dart`) verifying cache hits on stable keys and busts on attribute changes.
- Added defensive invalidation for late-arriving `html/body` tag selectors + expanded trace logging to simplify regression analysis; full test suite now passes.

Current metrics (representative):
- CSS summary: parseCalls=5 rules=51 style=50 media=0 keyframes=1 fontFace=0 parseMs=24
- Index: addCalls=19 addRules=166 handleCalls=5 handleRules=117 handleMs=0
- Match: calls=453 candidates=1555 matched=286 ms=0
- Recalc/Flush: recalc calls=292 recalcMs=32 flush calls=25 dirtyTotal=26 rootCount=2 flushMs=25

Latest telemetry (with css trace + memo instrumentation enabled on Blink CSS1 suite):
- CSS summary: parseCalls=49 rules=1614 style=1571 media=0 keyframes=28 fontFace=15 parseMs=81
- Index: addCalls=1273 addRules=44698 handleCalls=49 handleRules=43086 handleMs=0
- Match: calls=2605 candidates=227919 matched=682 matchMs=3202 (memoHits=1216 memoMisses=1462)
- Recalc/Flush: recalc calls=2386 recalcMs=8202 flush calls=148 dirtyTotal=52 rootCount=36 flushMs=2826
- Notes: numbers reflect heavy debug instrumentation and repeated stylesheet reloads during CSS1 snapshots; keep as sanity baseline for memo hit/miss tracking rather than perf gate.

Previously observed (pre‑W1):
- Match: calls=428 candidates=1700 matched=240 ms=1
- Recalc/Flush: recalc calls=462 recalcMs=209 flush calls=25 dirtyTotal=45 rootCount=5 flushMs=203

Observed impact:
- Recalc calls ↓ ~37% (462 → 292); recalcMs ↓ from 209ms → 32ms.
- FlushMs ↓ from ~203ms → ~25ms; dirtyTotal ↓ (45 → 26); rootCount ↓ (5 → 2).
- Match candidates slightly ↓ (1700 → 1555); overall match cost remains negligible.

## Flags & Instrumentation
- DebugFlags.enableCssTrace: verbose [trace] logs for dirty reasons, invalidation summaries, memo hits, flush decisions.
- DebugFlags.enableCssMemoization: per‑element matched‑rules cache keyed by (ruleSetVersion, tag, id, classes, attr presence).

## Next Steps
- Workstream 2 (Memoization rollout): collect perf samples with `memoHits/memoMisses`, `memoEvict`, and `memoAvgSize`; validate steady-state hit rates in app scenarios (with stable stylesheets). Tune LRU capacity if needed (current = 4) and consider exposing a debug knob.
- Workstream 3 (Matching micro-optimizations): reuse a single `SelectorEvaluator` instance per `matchedRules()` call; add ancestry-key fast-path for descendant combinators; benchmark hot selectors.
- Workstream 4 (Batch recalc – guarded): prototype deferred recalc flag, validate synchronous APIs (getComputedStyle triggers `updateStyleIfNeeded()`), add targeted tests.
- Optional index follow-ups: evaluate elementsByTag or pseudo anchor tracking once W2 data collected.

## Rollout & Safety
- Keep targeted invalidation on by default once validated with tests.
- Memoization behind a runtime flag initially; enable progressively.
- Batch recalc behind a flag; enable in test apps and measure.

## Implementation Notes (touch points)
- Indices: lib/src/dom/document.dart (maps), lib/src/dom/element.dart (maintenance), lib/src/dom/style_node_manager.dart (invalidate).
- Memoization: lib/src/dom/element.dart (_applySheetStyle), lib/src/css/element_rule_collector.dart.
- Micro-optimizations: lib/src/css/element_rule_collector.dart, lib/src/css/query_selector.dart.
- Batch recalc: lib/src/dom/element.dart setters → Document mark dirty.

## Out of Scope (for now)
- Blink/C++ resolver path integration.
- Cascade layers/@scope/container queries.

## Milestones
1) Targeted invalidation + tests → measure.
2) Memoization + guard flag + tests → measure.
3) Micro-optimizations → measure.
4) Batch recalc flag → phased enable.
