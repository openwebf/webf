# CSS Cascade Layers (`@layer`) — Dev Plan (Milestone M1)

This plan targets the **Blink/bridge CSS pipeline** (C++ in `bridge/`) used by `enableBlink: true` in integration tests.

## Goal (M1)
Implement CSS Cascade Layers so WebF matches the CSS Cascade spec for:
- `@layer` **statement**: `@layer base, components, utilities;`
- `@layer` **block**: `@layer utilities { ... }` and anonymous blocks `@layer { ... }`
- **Nested layers** and dotted names (e.g. `@layer a { @layer b { ... } }` and `@layer a.b { ... }`)
- Correct cascade sorting: **origin → importance → layer order → specificity → source order**
- `!important` **reverses layer order** (expected to fall out of `CascadePriority` once layer order is wired)
- CSSOM mutations that affect layer order (e.g. `insertRule('@layer ...', ...)`) trigger style invalidation and produce updated computed styles.

## Non-goals (defer unless required by tests)
- `revert-layer`
- Full layered `@import ... layer(...)` behavior (can be added after base ordering is correct)
- Layering semantics for non-style rules (`@keyframes`, `@font-face`, `@counter-style`) unless a test requires them.

## Current State (Bridge)
- Parsing exists for `@layer` block/statement:
  - `bridge/core/css/parser/css_parser_impl.cc` (`ConsumeLayerRule`)
  - `bridge/core/css/style_rule.h` (`StyleRuleLayerBlock`, `StyleRuleLayerStatement`)
- Cascade infrastructure already has a **layer order slot**:
  - `bridge/core/css/resolver/cascade_priority.h` encodes `layer_order` and flips it for important origins.
  - `bridge/core/css/resolver/style_cascade.cc` uses `MatchedProperties.layer_level` as `layer_order`.

### Status (this branch)
- ✅ `RuleSet` builds a per-stylesheet layer tree and tags each style rule with its layer (`bridge/core/css/rule_set.cc`).
- ✅ `CascadeLayerMap` merges active author RuleSets and computes canonical layer order (`bridge/core/css/cascade_layer_map.cc`).
- ✅ `ElementRuleCollector` assigns `MatchedProperties.layer_level` from the active `CascadeLayerMap` (`bridge/core/css/element_rule_collector.cc`).
- ✅ `StyleResolver::MatchAuthorRules` builds a `CascadeLayerMap` per match and wires it into the collector (`bridge/core/css/resolver/style_resolver.cc`).
- ✅ Debug logging is available under `WEBF_LOG_CASCADE` for RuleSet discovery, canonical order, and matched-rule layer order.

Remaining gaps for follow-up milestones:
- Layer ordering for non-style rules (`@keyframes`, `@font-face`, `@property`, `@counter-style`) when multiple definitions exist across layers.
- `@import ... layer(...)` and related ordering semantics (WPT coverage exists).
- `revert-layer`.

## Implementation Plan (Step-by-step)

### Step 1 — Track each rule’s layer in `RuleSet`
Files:
- `bridge/core/css/rule_set.h`, `bridge/core/css/rule_set.cc`
- `bridge/core/css/cascade_layer.h/.cc`

Work:
- Add a per-RuleSet **layer tree root** (a `CascadeLayer` instance).
- While walking stylesheet rules:
  - On `StyleRuleLayerStatement`: ensure listed layers exist under the current layer context (root by default).
  - On `StyleRuleLayerBlock`: create/get the target layer node and recurse into its children with that layer as the new context.
  - On plain `StyleRule`: store a pointer/reference to the **current layer node** (or “implicit outer layer” for unlayered rules).
- Extend `RuleData` to carry `const CascadeLayer*` (or equivalent) so the collector can read it per matched rule.

Acceptance:
- A RuleSet built from `@layer first { ... } @layer second { ... }` exposes that declarations in the `second` rules have a different layer pointer than `first`.

### Step 2 — Build a document-wide canonical layer order map
Files:
- `bridge/core/css/cascade_layer_map.h/.cc`

Work:
- Build a **canonical layer tree** by merging the layer trees from all active author RuleSets in stylesheet order.
- Compute numeric layer orders by traversing canonical layers in a deterministic depth-first post-order:
  - Siblings follow first-occurrence order.
  - Sublayers come before their parent so the parent layer wins (matches WPT expectations).
- Assign **implicit outer (unlayered)** order to `kImplicitOuterLayerOrder` (`uint16_t::max()`).
- Produce a lookup `GetLayerOrder(const CascadeLayer*) -> uint16_t` for all layers referenced by rules.

Acceptance:
- With two sheets where the earlier sheet declares `@layer second {}` and a later sheet declares `@layer first { ... } @layer second { ... }`, the computed order makes `first` higher precedence than `second`.

### Step 3 — Wire layer order into matching + cascade
Files:
- `bridge/core/css/element_rule_collector.cc/.h`
- (potentially) `bridge/core/css/resolver/style_resolver.cc` to provide the active layer map for author matching

Work:
- Provide `ElementRuleCollector` access to a `CascadeLayerMap` built from the active author RuleSets.
- When a rule matches, compute `CascadeLayerLevel` as:
  - `kImplicitOuterLayerOrder` for unlayered rules
  - otherwise `cascade_layer_map.GetLayerOrder(rule_data->CascadeLayer())`
- Keep existing sort order in `ElementRuleCollector::SortMatchedRules()` so that:
  - lower layer order is earlier, higher wins
  - unlayered (max) wins over layered for normal declarations

Acceptance:
- Simple layer precedence works:
  - `@layer first { #t { color: green } } @layer second { #t { color: red } }` → `#t` is red
  - after inserting an earlier `@layer second {}` into a prior sheet, `#t` becomes green

### Step 4 — CSSOM mutation + style invalidation coverage
Files:
- No new invalidation API expected; `CSSStyleSheet::RuleMutationScope` already triggers `StyleEngine::SetNeedsActiveStyleUpdate()`.

Work:
- Ensure the layer map is rebuilt on the next style recomputation after `insertRule/deleteRule`.
- Add integration specs mirroring WPT `layer-cssom-order-reverse.html` reordering cases for style rules.

Acceptance:
- CSSOM layer insert/delete toggles computed style as expected.

### Step 5 — Tracking logs (debug only)
Files:
- `bridge/core/css/rule_set.cc`
- `bridge/core/css/cascade_layer_map.cc`
- `bridge/core/css/element_rule_collector.cc`

Work:
- Add `WEBF_LOG(VERBOSE)` logs guarded by `WEBF_LOG_CASCADE` (compile-time) to dump:
  - discovered layer names while building RuleSet
  - final canonical order list
  - per matched rule: selector + computed layer order

Usage:
- Build with `-DWEBF_LOG_CASCADE=1 -DWEBF_MIN_LOG_LEVEL=0` to enable.

## Test Plan (Integration)
Add/extend specs under `integration_tests/specs/css/css-cascade/` based on WPT:
- `layer-basic` (reduced subset: named layers + statement order)
- `layer-important`
- `layer-media-query` (media inside layer)
- `layer-vs-inline-style`
- `layer-cssom-order-reverse` (insert/delete reorders layers across sheets)

Snapshots:
- Each `it()` captures `await snapshot()` and should have a committed baseline under `integration_tests/snapshots/css/css-cascade/`.

## Estimate (M1)
- RuleSet layer tracking + map wiring: **3–5 days**
- CSSOM ordering + invalidation cases + logs: **2–4 days**
- Integration specs + snapshot generation + stabilization: **2–4 days**

Total: **~7–13 person-days** (depends on WPT edge cases and snapshot stabilization).
