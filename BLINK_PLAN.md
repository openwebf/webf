**Overview**
- **Purpose:** Integrate the Blink-like C++ CSS pipeline (parser → rules → resolver → computed style) into WebF when `ExecutingContext::isBlinkEnabled == true`.
- **Scope:** Enable parsing `<style>` and inline styles into `CSSStyleSheet`/`CSSPropertyValueSet`, resolve styles via `StyleResolver`, and drive UI updates via batched `UICommand` diffs. Legacy paths remain for non‑Blink mode.

**Goals**
- **Blink Switch:** Respect `<meta name="webf-feature" content="blink-css-enabled">` to call `ExecutingContext::EnableBlinkEngine()`.
- **Inline CSSOM:** Use `InlineCssStyleDeclaration` with `MutableCSSPropertyValueSet` for inline styles (Blink mode).
- **Author Styles:** Parse `<style>` blocks into `CSSStyleSheet` via `StyleEngine::CreateSheet()` and include in matching.
- **Style Resolution:** Use `StyleResolver` to produce `ComputedStyle` for dirty elements.
- **UI Updates:** Diff computed styles and emit batched `UICommand` updates per frame.
- **Computed API:** Serve `getPropertyValue()` from `ComputedStyle` in Blink mode; hybrid fallback where needed.

**Non‑Goals**
- **Layout/Paint:** Full layout/paint in C++ is out of scope; Flutter/Dart continues rendering.
- **All CSS Features:** Not all properties/pseudos need to be supported in the first pass.

**Activation**
- **Switch:** `ExecutingContext::EnableBlinkEngine()` sets `enable_blink_engine_ = true`.
- **Meta Hook:** `HTMLMetaElement::ProcessMetaElement()` already enables Blink CSS on `blink-css-enabled`.
- **Guards:** Branch on `isBlinkEnabled()` in style/DOM paths; legacy remains for non‑Blink.

**Architecture Changes**
- **Parsing:**
  - `StyleEngine::CreateSheet()`/`ParseSheet()` cache and create `CSSStyleSheet` for `<style>`.
  - Inline style attribute parsed into `MutableCSSPropertyValueSet` via `CSSParser`.
- **Storage:**
  - Inline styles kept on `ElementData::inline_style_` (mutable/immutable).
  - Style sheets maintained per Document; global features in `CSSGlobalRuleSet`.
- **Resolution:**
  - `StyleResolver::ResolveStyle()` matches UA → user → author → inline, builds `ComputedStyle`.
- **Invalidation:**
  - `RuleFeatureSet` provides invalidation sets. `StyleEngine::UpdateStyleInvalidationRoot/UpdateStyleRecalcRoot` manage roots.
- **Bridge:**
  - Emit diffs as `UICommand` items and flush via `FlushUICommandReason`.

**Integration Tasks**
- **Inline Style Path Switch**
  - Update `Element::style()` to return `InlineCssStyleDeclaration` when Blink is enabled.
  - Use `InlineCssStyleDeclaration::DidMutate()` to mark dirty (no per‑mutation UICommand emission in Blink mode).

- **Inline Attribute Parsing**
  - Ensure `Element::SetInlineStyleFromString()`’s Blink branch parses into `MutableCSSPropertyValueSet` and reuses cache when immutable.
  - Keep legacy path for non‑Blink via `legacy::LegacyInlineCssStyleDeclaration`.

- **Stylesheet Processing**
  - `<style>`: `HTMLStyleElement` → `StyleElement::ProcessStyleSheet()` → `StyleEngine::CreateSheet()` (already in place).
  - `<link rel="stylesheet">`: implement author CSS loading in `HTMLLinkElement` (parse string/href), create `CSSStyleSheet`, and register with `StyleEngine`.

- **Invalidation & Recalc**
  - Implement `Node::SetNeedsStyleRecalc()` and `Node::MarkAncestorsWithChildNeedsStyleRecalc()` (currently commented out stubs).
  - Implement `StyleEngine::UpdateStyleRecalcRoot(...)` and `UpdateStyleInvalidationRoot(...)` to track efficient roots.
  - Add `StyleEngine::RecalcStyle(Document&)` to walk recalc roots and resolve styles.

- **Style Resolution & Diff**
  - Use `StyleResolver::MatchAllRules()` including UA, author, inline rules.
  - Compute diffs between previous and new `ComputedStyle` for a minimal property subset first (e.g., `color`, `background-color`, `display`, `opacity`).

- **UICommand Emission**
  - Frame batching: wrap in `kStartRecordingCommand`/`kFinishRecordingCommand`.
  - For each changed declaration, emit `kSetStyle`/`kClearStyle` with key/value strings.
  - Call `requestBatchUpdate` and/or `FlushUICommand(...)` with `kDependentsOnElement | kDependentsOnLayout`.

- **Computed CSS API**
  - `ComputedCssStyleDeclaration` should serve from `Element::GetComputedStyle()` in Blink mode.
  - Implement missing getters: `GetPropertyValueInternal(CSSPropertyID)`, `GetPropertyCSSValueInternal(...)`, shorthand/priority behaviors.
  - Hybrid fallback to legacy bridge only for unsupported properties.

- **Testing**
  - Bridge unit tests: inline parse, `<style>` parse, precedence, invalidation on class/attr changes, computed API reads.
  - Integration (Flutter): verify UI updates reflect styles set via CSS and inline.

**Milestones**
- **Phase 1: Parsing + Read Path**
  - Enable Blink via meta; parse `<style>`/inline; `getComputedStyle` returns from C++.
  - Keep legacy UICommand emission for inline style setters.

- **Phase 2: Recalc + Diff → UI**
  - Implement invalidation/recalc roots; add `RecalcStyle()`; emit diffs for core properties.
  - Switch inline style setters to not emit UICommands; rely on diff/flush.

- **Phase 3: Coverage & Hardening**
  - Expand property coverage; hook external styles; improve invalidation performance; remove Dart fallback for computed reads.

**Acceptance Criteria**
- **Correctness:** Inline and `<style>` CSS applies as expected across a representative set of properties.
- **Batching:** Exactly one UICommand batch per frame; no redundant commands for repeated setter calls within a frame.
- **Isolation:** Non‑Blink mode behavior unchanged.
- **Performance:** No regressions vs. legacy path on typical pages; reduced FFI calls per DOM change.

**Risks & Mitigations**
- **Partial Coverage:** Start with a property subset and hybrid fallback for computed reads; add properties iteratively.
- **Invalidation Bugs:** Use conservative invalidation on unknown selectors; add targeted tests for :has(), nth‑child, attributes, class/id.
- **Double Updates:** Ensure legacy emission is disabled in Blink mode (only diff‑driven updates).

**Rollout Strategy**
- **Feature Flag:** Keep Blink CSS behind `blink-css-enabled` meta and `enable_blink_engine_` runtime flag.
- **Per‑Page Opt‑In:** Developers can enable per document; safe fallback to legacy path.

**Implementation Pointers**
- **Switch Guards:**
  - `ExecutingContext::isBlinkEnabled()` checks in `Element::style()`, inline parse paths, attribute change.
- **Core Files:**
  - Parsing: `core/css/style_engine.{h,cc}`, `core/css/style_element.{h,cc}`, `core/css/style_sheet_contents.*`.
  - Inline CSSOM: `core/css/inline_css_style_declaration.*`, `core/css/abstract_property_set_css_style_declaration.*`.
  - Resolution: `core/css/resolver/style_resolver.{h,cc}`.
  - Invalidation: `core/css/rule_feature_set.*`, `core/css/invalidation/*`, `StyleEngine::*Root`.
  - Bridge: `foundation/ui_command_buffer.h`, `foundation/shared_ui_command.*`.
  - Meta hook: `core/html/html_meta_element.*`.

**Next Steps**
- Update `Element::style()` to return `InlineCssStyleDeclaration` in Blink mode; keep legacy otherwise.
- Implement `StyleEngine::RecalcStyle(Document&)`, wire `Node::SetNeedsStyleRecalc()` and root updates.
- Add minimal diff → UICommand mapping for a starter set of properties; flush once per frame.
- Enable computed reads from `ComputedStyle`; fallback as needed.

