# Profile Hotspot Targets

## 2026-03-24 User Case A

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

- `flex_inline_layout` should target this user-case stack with wrapped non-flex cards inside a flex container, rich inline content, and atomic inline controls.

## 2026-03-24 User Case B

Source profile: `/tmp/dart_devtools_2026-03-24_22_57_35.368.json`

Target stack to reproduce:

- `RenderFlexLayout._layoutFlexItems` -> `RenderFlexLayout._doPerformLayout`
- `RenderFlexLayout._adjustChildrenSize`
- `RenderFlexLayout._tryBuildEarlyNoFlexNoStretchNoBaselineRunMetrics`
- `RenderFlexLayout._tryNoFlexNoStretchNoBaselineFastPath`
- `RenderFlexLayout._computeRunMetrics`
- `RenderFlowLayout._layoutChildren` -> `InlineFormattingContext.layout`
- `InlineFormattingContext._buildAndLayoutParagraph`

Supporting costs visible in the same capture:

- paragraph follow-on work: `_layoutParagraphForConstraints`, `_layoutAtomicInlineItemsForParagraph`
- baseline/widget work: `RenderEventListener.calculateBaseline`, `RenderWidget.performLayout`, `RenderWidget.calculateBaseline`
- render-style scans: `getAttachedRenderParentRenderStyle`, `getRenderBoxValueByType`, `everyAttachedWidgetRenderBox`
- value resolution: `CSSLengthValue.computedValue`
- secondary animation load: `AnimationTimeline._onTick`

Profiler caveat:

- This Android trace is heavily polluted by timeline markers: `_reportTaskEvent` is about half of all leaf samples and `InlineFormattingContext._profileSection` appears in more than half of stacks.
- `flex_inline_layout` should therefore be profiled with sampled CPU stacks, inline profile sections disabled by default, and horizontal `nowrap` no-flex cards so the `NoFlexNoStretchNoBaseline` path is exercised.
