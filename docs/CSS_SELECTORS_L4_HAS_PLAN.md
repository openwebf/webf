# CSS Selectors Level 4 — :has() Support Plan (C++ Blink/bridge)

Goal: implement correct `:has(<relative-selector-list>)` matching + invalidation in the Blink/bridge C++ selector engine.

Status (Jan 28, 2026):
- Parsing + selector wiring exists (`CSSSelector::kPseudoHas`, `SelectorChecker::CheckPseudoHas`).
- Traversal, argument context, cache, and fast‑reject are **stubbed**:
  - `bridge/core/css/check_pseudo_has_argument_context.h`
  - `bridge/core/css/check_pseudo_has_traversal_iterator.h`
  - `bridge/core/css/check_pseudo_has_cache_scope.h`
- Element invalidation flags are declared but **no-op** in `bridge/core/dom/element.h`.
- Style invalidation hooks for `:has()` are **not implemented** in `StyleEngine`.

---

## Phase 1 — Argument context (correctness baseline)
Implement `CheckPseudoHasArgumentContext` to compute:
- Leftmost relation (`kRelativeDescendant`, `kRelativeChild`, `kRelativeDirectAdjacent`, `kRelativeIndirectAdjacent`).
- Fixed vs unbounded depth and adjacency limits.
- Whether siblings may be affected and which flags apply:
  - `AllowSiblingsAffectedByHas()`
  - `GetSiblingsAffectedByHasFlags()`
- Hashes for fast‑reject: class/id/tag/attr/pseudo in the argument list.

Files:
- `bridge/core/css/check_pseudo_has_argument_context.h` (and a new .cc if needed)
- `bridge/core/css/css_selector.h/.cc` (if new helper APIs are required)

---

## Phase 2 — Argument traversal iterator
Replace stub traversal with real iteration:
- Descendant/child traversal with depth tracking.
- Sibling / adjacent traversal (`+`, `~`) with optional subtree descent.
- Ensure traversal respects “relative selector” semantics (leftmost combinator).
- Avoid duplicated traversal when multiple anchors exist (use the “reversed DOM order” guidance in `has_invalidation_flags.h`).

Files:
- `bridge/core/css/check_pseudo_has_traversal_iterator.h` (consider splitting into .cc)
- `bridge/core/dom/element_traversal.h` or existing traversal helpers if needed

---

## Phase 3 — Cache + fast reject (perf‑safe)
Implement `CheckPseudoHasCacheScope` to avoid repeated checks:
- Per‑document cache keyed by (anchor element, selector hash).
- Track checked/matched to short‑circuit repeated argument checks.
Implement `CheckPseudoHasFastRejectFilter`:
- Conservative bloom filter (or “always false” for FastReject as a correctness fallback).

Files:
- `bridge/core/css/check_pseudo_has_cache_scope.h`
- `bridge/core/css/check_pseudo_has_traversal_iterator.h`

---

## Phase 4 — Element invalidation flags
Wire `HasInvalidationFlags` storage into `Element`:
- Add a struct field in `ElementRareDataVector` or `NodeRareData`.
- Implement non‑no‑op setters/getters in `bridge/core/dom/element.h/.cc`:
  - `SetAffectedBySubjectHas()`
  - `SetAffectedByNonSubjectHas()`
  - `SetAffectedByPseudoInHas()`
  - `SetAffectedByLogicalCombinationsInHas()`
  - `SetAncestorsOrAncestorSiblingsAffectedByHas()`
  - `SetSiblingsAffectedByHasFlags()`
  - `AffectedByMultipleHas()` / `SetAffectedByMultipleHas()`

Files:
- `bridge/core/dom/element.h/.cc`
- `bridge/core/dom/element_rare_data_vector.h` or `bridge/core/dom/node_rare_data.h`

---

## Phase 5 — Style invalidation wiring
Add `:has()` invalidation entry points to `StyleEngine` and DOM mutation paths.

New `StyleEngine` APIs:
- `InvalidateElementAffectedByHas(Element& changed)`
- `InvalidateAncestorsOrSiblingsAffectedByHas(Element& changed)`

Call sites:
- `StyleEngine::IdChangedForElement`
- `StyleEngine::ClassAttributeChangedForElement`
- `StyleEngine::AttributeChangedForElement`
- Insert/remove paths in `bridge/core/dom/container_node.cc`

Rules:
- Use `RuleFeatureSet::NeedsHasInvalidationFor*` to short‑circuit.
- For subject `:has()`: mark anchor element `SetNeedsStyleRecalc(kLocalStyleChange, kAffectedByHas)`.
- For non‑subject `:has()`: schedule descendant/sibling invalidation sets on the anchor element.

Files:
- `bridge/core/css/style_engine.h/.cc`
- `bridge/core/dom/container_node.cc`

---

## Phase 6 — Tests
Unit tests:
- Selector parsing & matching in `bridge/core/css/css_selector_test.cc`:
  - Descendant/child/sibling forms (`:has(.b)`, `:has(> .b)`, `:has(+ .b)`, `:has(~ .b)`).
  - Nested logical combos: `:has(:is(.a .b))`, `:has(:where(.a .b))`.

Integration tests:
- Mutation invalidation scenarios:
  - class add/remove on descendants/siblings
  - sibling insertion/removal
  - multiple anchors with overlapping scopes

---

## Build/Test checklist (C++)
- Build: `npm run build:bridge:macos:arm64`
- Unit: `node scripts/run_bridge_unit_test.js`
- Integration: `cd integration_tests && npm run integration -- specs/css/css-selectors/has-*.ts`

