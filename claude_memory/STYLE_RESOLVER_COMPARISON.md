# Style Resolver Comparison: WebF vs Blink

## Overview

This document provides a detailed comparison between WebF's style resolver implementation and Blink's, identifying core components that need migration, missing features, and architectural adaptations required.

## File Structure Comparison

### WebF Style Resolver Files (bridge/core/css/resolver/)
1. **css_to_style_map.cc/h** - Maps CSS values to style properties
2. **font_builder.cc/h** - Font property handling
3. **match_request.h** - Style matching request structure
4. **matched_properties_cache.cc/h** - Caching for matched properties
5. **media_query_result.h** - Media query results
6. **style_builder.cc/h** - Applies CSS properties to ComputedStyle
7. **style_cascade.cc/h** - Manages CSS cascade
8. **style_resolver.cc/h** - Main style resolution class
9. **style_resolver_state.cc/h** - State during style resolution
10. Test files: style_resolver_simple_test.cc, style_resolver_test.cc

### Blink Style Resolver Files (Additional/Missing in WebF)
1. **cascade_expansion[-inl].h/.cc** - Cascade expansion for custom properties
2. **cascade_filter.h** - Filtering cascade entries
3. **cascade_interpolations.h** - Animation interpolations in cascade
4. **cascade_map.cc/h** - Optimized map for cascade priorities
5. **cascade_origin.h** - Origin tracking for cascade
6. **cascade_priority.h** - Priority system for cascade
7. **cascade_resolver.cc/h** - Resolves cascade conflicts and cycles
8. **element_resolve_context.cc/h** - Element context for resolution
9. **element_style_resources.cc/h** - Resource handling for styles
10. **filter_operation_resolver.cc/h** - Filter operations
11. **font_style_resolver.cc/h** - Advanced font resolution
12. **match_flags.h** - Flags for matching operations
13. **match_result.cc/h** - Detailed match results
14. **scoped_style_resolver.cc/h** - Per-TreeScope style resolution
15. **selector_filter_parent_scope.cc/h** - Parent scope filtering
16. **style_adjuster.cc/h** - Post-resolution style adjustments
17. **style_builder_converter.cc/h** - Value conversion utilities
18. **style_resolver_stats.cc/h** - Performance statistics
19. **style_resolver_utils.h** - Utility functions
20. **style_rule_usage_tracker.cc/h** - DevTools rule tracking
21. **transform_builder.cc/h** - Transform property handling
22. **viewport_style_resolver.cc/h** - Viewport-specific styles

## Architecture Comparison

### WebF Current Architecture

```
StyleResolver
    ├── ElementRuleCollector (collects matching rules)
    ├── StyleResolverState (maintains resolution state)
    ├── StyleCascade (applies cascade - simplified)
    └── StyleBuilder (applies properties)
```

**Key Characteristics:**
- Simplified cascade implementation (basic priority handling)
- Direct property application without extensive conversion layer
- Limited scoping support (no ScopedStyleResolver)
- Basic caching (MatchedPropertiesCache)
- No advanced features like cascade layers, @scope, or container queries

### Blink Architecture

```
StyleResolver
    ├── ElementResolveContext (element information)
    ├── ScopedStyleResolver (per-TreeScope resolution)
    │   ├── RuleSet (organized rules)
    │   └── CascadeLayerMap (layer management)
    ├── ElementRuleCollector (collects matching rules)
    ├── StyleResolverState (resolution state)
    ├── StyleCascade (advanced cascade)
    │   ├── CascadeMap (optimized property storage)
    │   ├── CascadeResolver (cycle detection)
    │   └── CascadeExpansion (custom properties)
    ├── StyleBuilder (property application)
    │   └── StyleBuilderConverter (value conversion)
    └── StyleAdjuster (post-processing)
```

## Core Components Needing Migration

### 1. Advanced Cascade System
**Priority: High**
- **CascadeMap**: Optimized property storage with native array for standard properties
- **CascadePriority**: Sophisticated priority system including layers, tree scopes
- **CascadeResolver**: Cycle detection for custom properties and attributes
- **CascadeFilter**: Filtering mechanism for cascade entries

### 2. Scoped Style Resolution
**Priority: High**
- **ScopedStyleResolver**: Per-TreeScope style management
- **ElementResolveContext**: Efficient element context caching
- Support for shadow DOM styling, @scope rules

### 3. Style Building Infrastructure
**Priority: Medium**
- **StyleBuilderConverter**: Comprehensive value conversion utilities
- **StyleAdjuster**: Post-resolution adjustments for platform quirks
- **TransformBuilder**: Dedicated transform handling
- **FilterOperationResolver**: Filter effect resolution

### 4. Performance Optimizations
**Priority: Medium**
- **CascadeMap**: Optimized property storage
- **SelectorFilterParentScope**: Efficient parent filtering
- **StyleResolverStats**: Performance tracking
- Incremental style calculation support

### 5. Modern CSS Features
**Priority: High**
- **Cascade Layers** (@layer support)
- **Container Queries** (size/style containers)
- **@scope** rules
- **CSS Custom Properties** (full cycle detection)
- **Logical Properties** (full support)

## Missing Features in WebF

### Critical Missing Components
1. **Cascade Layers** - No @layer support
2. **Container Queries** - No size/style container support
3. **Scoped Styles** - No @scope or TreeScope isolation
4. **Custom Property Cycles** - Basic implementation, no cycle detection
5. **Style Adjustments** - No post-resolution adjustments
6. **Viewport Units** - Limited viewport style resolution
7. **Page Styles** - Basic @page support

### Architecture Gaps
1. **No TreeScope-based resolution** - Everything is document-scoped
2. **Simplified cascade** - No layer ordering or complex priority handling
3. **No style statistics** - No performance tracking
4. **Limited caching** - Only MatchedPropertiesCache, no cascade caching
5. **No resource handling** - ElementStyleResources missing

## Migration Strategy

### Phase 1: Foundation (Weeks 1-2)
1. Implement CascadeMap and CascadePriority system
2. Add ElementResolveContext for efficient element handling
3. Upgrade StyleCascade to use new cascade infrastructure

### Phase 2: Scoped Resolution (Weeks 3-4)
1. Implement ScopedStyleResolver
2. Add TreeScope support to style resolution
3. Implement basic @scope rule support

### Phase 3: Modern Features (Weeks 5-6)
1. Add cascade layers (@layer) support
2. Implement container query infrastructure
3. Add custom property cycle detection

### Phase 4: Optimizations (Weeks 7-8)
1. Implement StyleAdjuster for platform adjustments
2. Add StyleBuilderConverter for value conversions
3. Implement performance tracking and statistics

## Key Architectural Adaptations Needed

### 1. Memory Management
- WebF uses std::shared_ptr for ComputedStyle
- Blink uses garbage collection (GarbageCollected)
- Need adapter layer or consistent approach

### 2. Threading Model
- WebF has different thread architecture
- Cascade resolution must be thread-safe
- Consider synchronization for shared caches

### 3. Property System
- WebF uses generated property IDs
- Need to ensure compatibility with Blink's property system
- May need property ID mapping layer

### 4. Value Types
- WebF and Blink have different CSSValue hierarchies
- Need conversion utilities or unified value system
- Special handling for custom properties

### 5. API Surface
- WebF exposes different APIs to JavaScript
- Need to maintain backward compatibility
- Consider gradual migration approach

## Implementation Priority

1. **Cascade System** (Critical)
   - Required for modern CSS features
   - Foundation for other improvements

2. **Scoped Styles** (High)
   - Needed for shadow DOM and components
   - Enables proper style isolation

3. **Container Queries** (High)
   - Increasingly important for responsive design
   - Requires cascade system upgrade

4. **Performance Features** (Medium)
   - Can be added incrementally
   - Important for large applications

5. **DevTools Integration** (Low)
   - Nice to have but not critical
   - Can be added after core features

## Conclusion

The migration from WebF's current style resolver to a Blink-compatible implementation requires significant architectural changes. The most critical components are the advanced cascade system and scoped style resolution, which form the foundation for modern CSS features. A phased approach focusing on core infrastructure first, followed by feature implementation and optimizations, would minimize risk while enabling gradual adoption of new capabilities.