# Debug Logging for Flex Layout

WebF provides grouped, filterable logs for Flex layout. There is no global switch; enable logs by selecting implementations and features.

## Selective Logging

```dart
// Only show container and resolve phases
FlexLog.enableImpls({ FlexImpl.flex });
FlexLog.enableFeatures({ FlexFeature.container, FlexFeature.resolve });

// Allow all Flex logs
FlexLog.enableAll();

// Temporarily silence Flex logs
FlexLog.disableAll();
```

Implementations:
- Flex: Flex layout engine

Features:
- Container, Intrinsic, Basis, BaseSize, Runs, Resolve, ChildConstraints, Alignment

## Example Output

```
[Flex/Flex/Container] container start dir=row jc=space-between ai=stretch ac=stretch wm=CSSWritingMode.horizontalTb isHorizontalMain=true constraints=C[...] contentConstraints=C[...] logical=(w:null, h:null)
[Flex/Flex/Resolve] resolve start initialFreeSpace=24.0 totalGrow=1.0 totalShrink=0.0
[Flex/Flex/ChildConstraints] -> childConstraints div#item C[minW=0.0, maxW=120.0, minH=18.0, maxH=∞]
```

## DevTools UI

Inspector → Options:
- Open “Flex Log Filters...” and select implementations/features to include
