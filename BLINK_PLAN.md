**Overview**
- **Purpose:** Integrate a Blink-like C++ CSS pipeline (parser → rules → limited cascade) when `ExecutingContext::isBlinkEnabled == true`, while deferring value evaluation (fonts, animations, device/viewport info, calc, etc.) to Dart.
- **Scope:** Parse `<style>` and inline styles into `CSSStyleSheet`/`CSSPropertyValueSet`, select winning declarations where possible, and drive UI updates by sending original CSS value strings (no C++ evaluation). Legacy paths remain for non‑Blink mode.

**Goals**
- **Blink Switch:** Respect `<meta name="webf-feature" content="blink-css-enabled">` to call `ExecutingContext::EnableBlinkEngine()`.
- **Inline CSSOM:** Use `InlineCssStyleDeclaration` with `MutableCSSPropertyValueSet` for inline styles (Blink mode).
- **Author Styles:** Parse `<style>` blocks into `CSSStyleSheet` via `StyleEngine::CreateSheet()` and include in matching where conditions are device‑independent.
- **No C++ Evaluation:** Do not evaluate values that require runtime/device information: fonts/metrics, animations/timelines, viewport/device units, container/media queries, `calc()`/math, env/var resolution. Preserve original serialized CSS text.
- **UI Updates:** Diff declared values (strings) and emit batched `UICommand` updates per frame (send raw CSS strings).
- **Computed API:** Keep `getComputedStyle` resolved on Dart; C++ does not provide computed values.

**Non‑Goals**
- **Evaluation on C++:** No C++ evaluation for font metrics, animation timing, viewport/media/container queries, math functions, env/var, or unit conversions.
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
- **Selection (No Evaluation):**
  - `StyleResolver` performs selector matching and cascade to choose winning declarations when possible.
  - Defer device‑dependent conditions (@media/@container) and any value evaluation to Dart.
- **Invalidation:**
  - `RuleFeatureSet` provides invalidation sets. `StyleEngine::UpdateStyleInvalidationRoot/UpdateStyleRecalcRoot` manage roots.
- **Bridge:**
  - Emit diffs as `UICommand` items with the original CSS value strings and flush via `FlushUICommandReason`.

**Integration Tasks**
- **Inline Style Path Switch**
  - Update `Element::style()` to return `InlineCssStyleDeclaration` when Blink is enabled.
  - Use `InlineCssStyleDeclaration::DidMutate()` to mark dirty (no per‑mutation UICommand emission in Blink mode).

- **Inline Attribute Parsing**
  - Ensure `Element::SetInlineStyleFromString()`’s Blink branch parses into `MutableCSSPropertyValueSet` and reuses cache when immutable.
  - Keep legacy path for non‑Blink via `legacy::LegacyInlineCssStyleDeclaration`.

- **Stylesheet Processing**
  - `<style>`: `HTMLStyleElement` → `StyleElement::ProcessStyleSheet()` → `StyleEngine::CreateSheet()` (already in place).
  - `<link rel="stylesheet">`: optional; if implemented, only include rules outside device‑dependent at‑rules. Defer @media/@container blocks to Dart.

- **Invalidation & Recalc**
  - Implement `Node::SetNeedsStyleRecalc()` and `Node::MarkAncestorsWithChildNeedsStyleRecalc()` (currently commented out stubs).
  - Implement `StyleEngine::UpdateStyleRecalcRoot(...)` and `UpdateStyleInvalidationRoot(...)` to track efficient roots.
  - Add `StyleEngine::RecalcStyle(Document&)` to walk recalc roots and select winning declarations (no value evaluation).

- **Declared Style Diff (No Evaluation)**
  - Compare previous vs. new declared values (serialized CSS strings) for each property.
  - Do not convert units, resolve `calc()`, apply var/env, or compute font/animation results in C++.

- **UICommand Emission**
  - Frame batching: wrap in `kStartRecordingCommand`/`kFinishRecordingCommand`.
  - For each changed declaration, emit `kSetStyle`/`kClearStyle` with the original CSS value string.
  - Call `requestBatchUpdate` and/or `FlushUICommand(...)` with `kDependentsOnElement | kDependentsOnLayout`.

- **Computed CSS API**
  - Keep `ComputedCssStyleDeclaration` as a Dart‑backed read path; C++ should not claim to compute.
  - If needed, expose only declared values from C++ helpers (not as computed style).

- **Testing**
  - Bridge unit tests: inline parse, `<style>` parse, precedence, invalidation on class/attr changes.
  - Verify UI updates reflect exact CSS strings (including `calc()`/vw/vh) passed through to Dart.

**Milestones**
- **Phase 1: Parse + Pass‑Through Values**
  - Enable Blink via meta; parse `<style>`/inline; maintain declared values only; keep `getComputedStyle` on Dart.
  - Keep legacy UICommand emission for inline style setters until diff path is ready.

- **Phase 2: Declared Diff → UI**
  - Implement invalidation/recalc roots; add `RecalcStyle()`; emit diffs using original CSS strings.
  - Switch inline style setters to not emit UICommands; rely on declared‑diff batching.

- **Phase 3: Coverage & Hardening**
  - Expand selector coverage; defer at‑rules to Dart; improve invalidation performance; keep computed reads on Dart.

**Acceptance Criteria**
- **Correctness:** Inline and `<style>` CSS apply with exact value strings preserved (e.g., `calc()`, `vh/vw`, `var()` unchanged) and evaluated on Dart.
- **Batching:** Exactly one UICommand batch per frame; no redundant commands for repeated setter calls within a frame.
- **Isolation:** Non‑Blink mode behavior unchanged.
- **Performance:** No regressions vs. legacy path on typical pages; reduced FFI calls per DOM change.

**Risks & Mitigations**
- **Selector/At‑Rule Gaps:** Defer @media/@container and device‑dependent rules to Dart; document limitations.
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
  - Selection (no evaluation): `core/css/resolver/style_resolver.{h,cc}`.
  - Invalidation: `core/css/rule_feature_set.*`, `core/css/invalidation/*`, `StyleEngine::*Root`.
  - Bridge: `foundation/ui_command_buffer.h`, `foundation/shared_ui_command.*`.
  - Meta hook: `core/html/html_meta_element.*`.

**Next Steps**
- Update `Element::style()` to return `InlineCssStyleDeclaration` in Blink mode; keep legacy otherwise.
- Implement `StyleEngine::RecalcStyle(Document&)`, wire `Node::SetNeedsStyleRecalc()` and root updates.
- Add declared‑value diff → UICommand mapping (send original CSS strings); flush once per frame.
- Keep computed reads on Dart; add tests to validate pass‑through values (calc/viewport units/var/env).
**TODOs**
- [x] Draft integration plan document
- [x] Define pass‑through evaluation (no C++ evaluation for fonts/animations/device/calc)
- [ ] Switch `Element::style()` to `InlineCssStyleDeclaration` when Blink is enabled
- [x] Implement `Node::SetNeedsStyleRecalc()` and ancestor marking; hook `StyleEngine::*Root`
- [x] Add `StyleEngine::RecalcStyle(Document&)` (skeleton; declared-value selection TBD)
- [ ] Emit declared-value diffs via `UICommand` batching (send original CSS strings)
- [ ] Keep computed style reads on Dart; ensure hybrid fallback only where needed
- [ ] Defer @media/@container/viewport-dependent rules to Dart selection
- [ ] (Optional) Handle `<link rel="stylesheet">` with device-independent rules
- [ ] Tests: inline and `<style>` parsing, precedence, invalidation, pass-through values
- [ ] Integration tests verifying UI updates reflect declared values
- [ ] Document limitations, rollout, and feature flag behavior
 - [x] Inline style attribute parsing to `MutableCSSPropertyValueSet` for Blink path
