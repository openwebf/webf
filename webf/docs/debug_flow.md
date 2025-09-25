# Debug Logging for Flow Layout

WebF provides grouped debugging logs for flow layout that can be filtered by implementation and feature.

There is no global toggle. Enable logs by selecting implementations and features.

## Selective Logging

Enable only specific implementations and features:

```dart
// Only log constraints and sizing from IFC integration
FlowLog.enableImpls({ FlowImpl.ifc });
FlowLog.enableFeatures({ FlowFeature.constraints, FlowFeature.sizing });

// Allow all flow logs
FlowLog.enableAll();

// Temporarily silence flow logs
// FlowLog.disableAll();
```

Implementations:
- Flow: Normal flow layout
- IFC: Integration with Inline Formatting Context
- Overflow: Scroll/overflow setup and sizing

Features:
- Constraints, Sizing, Layout, Painting, Child, Runs, MarginCollapse, Scrollable, ShrinkToFit, WidthBreakdown, Setup

## Example Output

```
[Flow/IFC/Constraints] <div> establishIFC=true constraints=C[...] contentConstraints=C[...]
[Flow/IFC/Layout] IFC layout with constraints=C[...] -> Size(300.0, 46.0)
[Flow/IFC/WidthBreakdown] <div> IFC width breakdown: paraW=278.40 usedW=260.00 contentW=260.00 padH=20.00 borderH=2.00 boxW=282.00
[Flow/Overflow/Setup] <div> viewport=280.00×120.00 scrollable=540.00×120.00 overflowX=scroll overflowY=hidden
```

## DevTools UI

Use the Inspector panel → Options (tune icon):
- Toggle “Log Flow” (master switch)
- Open “Flow Log Filters...” to choose implementations and features
