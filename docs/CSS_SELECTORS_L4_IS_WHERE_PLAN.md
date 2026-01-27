# CSS Selectors L4 `:is()` / `:where()` — Dev Plan (Milestone M2)

This plan targets **TailwindCSS v3.4.x compatibility** for selector features that Tailwind emits in preflight and variants.

WebF has two selector engines:
- **Blink/bridge (C++)**: used when `enableBlink: true` (integration tests default).
- **Legacy Dart engine**: used when `enableBlink: false`.

## Goal (M2)
Support Selectors Level 4 functional pseudos:
- `:where(<selector-list>)` — matches like `:is()`, but contributes **zero** specificity.
- `:is(<selector-list>)` — matches any argument, with specificity equal to the **max specificity** of its arguments.

For Tailwind, this unblocks (at minimum):
- Preflight selectors like `abbr:where([title])`, `[hidden]:where(:not(...))`
- Direction variants like `&:where([dir="rtl"], [dir="rtl"] *)`

## Current State

### Blink/bridge (C++)
Already supported:
- Parsing: `bridge/core/css/parser/css_selector_parser*`
- Pseudo types: `bridge/core/css/css_selector.h` (`CSSSelector::kPseudoIs`, `CSSSelector::kPseudoWhere`)
- Specificity rules: `bridge/core/css/css_selector.cc` (`kPseudoWhere` returns 0; `kPseudoIs` uses max specificity)
- Unit tests: `bridge/core/css/css_selector_test.cc`, `bridge/core/css/resolver/selector_specificity_test.cc`
- Integration coverage: `integration_tests/specs/css/css-selectors/is-where-*.ts`

### Legacy Dart engine
Missing/blocked:
- Selector-list parsing for functional pseudos in `webf/lib/src/css/parser/parser.dart`
- Matching + specificity for `:is()` / `:where()` in `webf/lib/src/css/query_selector.dart`

## Spec Notes (what must be correct)
- `:where(<selector-list>)` has specificity **(0,0,0)** regardless of its arguments.
- `:is(<selector-list>)` has specificity equal to the **maximum** specificity among its arguments (even if a lower-specificity argument is the one that matches).
- Nested behavior: only the `:where(...)` portion is zero; any selectors outside `:where(...)` still contribute normally.

## Implementation Plan (Legacy Dart engine)

### Step 1 — Parse `:is()` / `:where()` selector lists
Files:
- `webf/lib/src/css/parser/parser.dart`
- Selector AST types under `webf/lib/src/css/`

Work:
- Extend selector parsing to recognize functional pseudos `:is(` and `:where(`.
- Parse the argument as a **selector-list** (comma-separated complex selectors), not a raw token list.
- Represent it in the selector AST as a node that contains `List<SelectorGroup>` (or equivalent).

Acceptance:
- `processSelectorGroup()` can parse selectors like `:is(.a, .b > .c)` and `:where(#id, .x :not(.y))`.

### Step 2 — Match `:is()` / `:where()` in the selector evaluator
Files:
- `webf/lib/src/css/query_selector.dart`

Work:
- Add evaluator support so `:is(list)` matches if any selector in `list` matches at the current element position.
- Add evaluator support so `:where(list)` matches the same way as `:is(list)`.

Acceptance:
- `querySelector(All)` and `matches()` behave consistently with Blink for the added integration fixtures.

### Step 3 — Implement correct specificity
Files:
- Selector AST types (specificity computation)

Work:
- `:where(...)` contributes **0** specificity.
- `:is(...)` contributes **max(argument specificities)**.
- Ensure specificity is computed from the parsed selector list (parse-time), not from what happened to match at runtime.

Acceptance:
- Specificity comparisons match Selectors L4 rules for nested cases (e.g. `:is(.box :where(#target))`).

### Step 4 — Tests (Dart engine)
Work:
- Add Dart unit tests for parsing, matching, and specificity for `:is()` / `:where()`.
- Add a way to run integration specs with `enableBlink: false` (or add a small dedicated harness) to prevent regressions.

## Progress Log (this branch)
- ✅ Confirmed Blink/bridge already implements `:where()` and its 0-specificity rule.
- ✅ Fixed selector integration fixtures that were failing due to spec misunderstandings (not engine bugs).
- ✅ Added Blink/bridge matching for `:enabled` / `:disabled` (required by `integration_tests/specs/css/css-selectors/is-where-pseudo-classes.ts`).
- ⏳ Dart engine implementation deferred (needs parsing + matching + specificity + tests).
