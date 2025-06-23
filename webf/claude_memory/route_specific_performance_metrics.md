# Route-Specific Performance Metrics Implementation

## Overview
Implemented route-specific tracking for FP/FCP/LCP performance metrics to handle WebF's hybrid routing feature where renderObjects can be attached to standalone router roots.

## Problem
When navigating to a new hybrid route page, FP/FCP/LCP metrics were being recalculated using the current time compared to the original page's initialization time, resulting in much larger values than expected.

## Solution
Created a route-aware performance tracking system that maintains separate metrics for each route page, identified by their path in the buildContextStack.

## Key Components

### RoutePerformanceMetrics Class
```dart
class RoutePerformanceMetrics {
  final String routePath;
  DateTime? navigationStartTime;
  bool lcpReported = false;
  double largestContentfulPaintSize = 0;
  double lastReportedLCPTime = 0;
  WeakReference<Element>? currentLCPElement;
  Timer? lcpAutoFinalizeTimer;
  
  // FCP tracking
  bool fcpReported = false;
  double fcpTime = 0;
  
  // FP tracking
  bool fpReported = false;
  double fpTime = 0;
  
  RoutePerformanceMetrics(this.routePath);
  
  void dispose() {
    lcpAutoFinalizeTimer?.cancel();
  }
}
```

### WebFController Changes
- Added `Map<String, RoutePerformanceMetrics> _routeMetrics` to store metrics per route
- Converted all metric fields to getters/setters that delegate to current route metrics
- Updated `pushNewBuildContext` to initialize metrics for new routes
- Updated `popBuildContext` to clean up metrics for removed routes
- Added methods to access route-specific metrics:
  - `RoutePerformanceMetrics? getRouteMetrics(String routePath)`
  - `Map<String, RoutePerformanceMetrics> get allRouteMetrics`

### Route-Aware Callbacks
Added new typedefs for route-aware performance callbacks:
```dart
typedef RouteLCPHandler = void Function(double lcpTime, String routePath);
typedef RouteFCPHandler = void Function(double fcpTime, String routePath);
typedef RouteFPHandler = void Function(double fpTime, String routePath);
```

Added corresponding callback properties to WebFController:
- `RouteLCPHandler? onRouteLCP`
- `RouteLCPHandler? onRouteLCPFinal`
- `RouteFCPHandler? onRouteFCP`
- `RouteFPHandler? onRouteFP`

### DevTools Integration
Updated `WebFInspectorFloatingPanel` to display route-specific metrics:
- Shows metrics grouped by route path
- Highlights the currently active route
- Displays route path with icon and active badge
- Each route shows its own FP/FCP/LCP metrics

## Usage Example
```dart
controller.onRouteLCP = (double time, String routePath) {
  print('LCP for route $routePath: $time ms');
};

controller.onRouteFCP = (double time, String routePath) {
  print('FCP for route $routePath: $time ms');
};

// Access metrics for a specific route
final routeMetrics = controller.getRouteMetrics('/home');
if (routeMetrics != null) {
  print('Home route LCP: ${routeMetrics.lastReportedLCPTime} ms');
}

// Access all route metrics
final allMetrics = controller.allRouteMetrics;
for (final entry in allMetrics.entries) {
  print('Route ${entry.key}: LCP=${entry.value.lastReportedLCPTime}ms');
}
```

## Benefits
1. Accurate performance metrics for each route page
2. Metrics are not affected by navigation between routes
3. DevTools can show performance breakdown by route
4. Backward compatible with existing single-route callbacks
5. Automatic cleanup when routes are removed