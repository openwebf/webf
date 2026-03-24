# Profile Hotspot Targets

## 2026-03-24 User Case

Source profile: `/tmp/dart_devtools_2026-03-24_14_46_17.876.json`

Target stack to reproduce:

- `RenderFlexLayout._layoutFlexItems` -> `RenderFlexLayout._doPerformLayout`
- `RenderFlowLayout._layoutChildren` -> `InlineFormattingContext.layout`
- `InlineFormattingContext._buildAndLayoutParagraph`
- `InlineFormattingContext._layoutParagraphForConstraints`
- `InlineFormattingContext._layoutAtomicInlineItemsForParagraph`
- `RenderEventListener.calculateBaseline` / `RenderWidget.calculateBaseline`

Supporting costs visible in the same capture:

- inherited text/style getters: `fontStyle`, `fontFamily`, `wordBreak`, `textIndent`
- render-style parent/render-box scans: `getAttachedRenderParentRenderStyle`, `getRenderBoxValueByType`
- repeated flex run metrics and relayout work: `_tryBuildEarlyNoFlexNoStretchNoBaselineRunMetrics`, `_computeRunMetrics`, `_adjustChildrenSize`

Profiler caveat:

- `InlineFormattingContext._profileSection` and `Timeline.startSync` / `finishSync` currently add substantial profiler noise, so sampled CPU stacks are more reliable than leaf-only timing totals.

Profiler example mapping:

- `flex_inline_layout` should target this user-case stack with wrapped flex cards containing rich inline content and atomic inline controls.
