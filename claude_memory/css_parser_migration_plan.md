# CSS Parser Migration Plan: WebF → Blink Alignment

## Overview
This document outlines the plan to migrate WebF's CSS parser to align with Chromium Blink's latest implementation while maintaining WebF's architectural requirements.

## Key Differences

### 1. Missing Parser Components
- **CSS @if Parser** (`css_if_parser.h/cc`) - Conditional rules parsing
- **Sizes Parsers** (`sizes_attribute_parser.h/cc`, `sizes_math_function_parser.h/cc`) - Responsive image support
- **Rule Validation** (`allowed_rules.h`) - Enhanced rule type checking
- **Testing Infrastructure** - Fuzzer support and performance benchmarks

### 2. Type System Differences
| WebF | Blink |
|------|-------|
| `std::string` | `WTF::String` |
| `std::vector<T>` | `WTF::Vector<T>` |
| `std::shared_ptr<T>` | `Member<T>` (Oilpan GC) |
| `tcb::span` | `base::span` |
| `WEBF_STACK_ALLOCATED` | `STACK_ALLOCATED()` |

### 3. Architectural Differences
- WebF uses standard C++ memory management
- Blink uses Oilpan garbage collection
- Different include paths and build systems
- WebF has simplified error handling

## Migration Phases

### Phase 1: Infrastructure (Weeks 1-2)
1. **Type Abstraction Layer**
   - Create type aliases for easy switching
   - Build compatibility headers
   - Add conversion utilities

2. **Build System Updates**
   - Add conditional compilation flags
   - Update CMakeLists.txt
   - Create feature toggles

### Phase 2: Core Features (Weeks 3-4)
1. **Port CSS @if Parser**
   - Essential for modern CSS conditional rules
   - Adapt memory management
   - Include comprehensive tests

2. **Port Sizes Attribute Parsers**
   - Required for responsive images
   - Math function support
   - HTML integration updates

3. **Rule Validation System**
   - Port `allowed_rules.h`
   - Update parser to use AllowedRules
   - Maintain backward compatibility

### Phase 3: Testing (Week 5)
1. **Test Migration**
   - Port relevant Blink tests
   - Create WebF-specific test cases
   - Add regression tests

2. **Performance Framework**
   - Establish benchmarking system
   - Port critical performance tests
   - Set performance baselines

### Phase 4: Advanced Features (Weeks 6-7)
1. **Enhanced Capabilities**
   - Improved error recovery
   - Better diagnostic messages
   - Observer pattern updates

2. **Optimization**
   - Memory usage analysis
   - Performance tuning
   - Code size optimization

## Implementation Details

### Type Compatibility Layer
```cpp
// core/css/parser/type_aliases.h
namespace webf {
namespace css_parser {

// String types
#ifdef WEBF_USE_BLINK_TYPES
  using String = WTF::String;
  using StringView = WTF::StringView;
#else
  using String = std::string;
  using StringView = std::string_view;
#endif

// Container types
template<typename T>
using Vector = std::conditional_t<WEBF_USE_BLINK_TYPES,
                                  WTF::Vector<T>,
                                  std::vector<T>>;

// Smart pointers
template<typename T>
using RefPtr = std::conditional_t<WEBF_USE_BLINK_TYPES,
                                  Member<T>,
                                  std::shared_ptr<T>>;

} // namespace css_parser
} // namespace webf
```

### Migration Strategy
1. **Incremental Approach**
   - Keep existing code functional
   - Use feature flags for new code
   - Gradual rollout with testing

2. **Compatibility First**
   - No breaking changes
   - Maintain API surface
   - Preserve performance

3. **Testing Coverage**
   - Unit tests for each component
   - Integration tests
   - Performance regression tests
   - Fuzzing for security

## Success Criteria
- [ ] All Blink parser tests passing
- [ ] No performance degradation (< 5% impact)
- [ ] CSS spec compliance maintained
- [ ] Memory usage within bounds
- [ ] Build size increase < 10%
- [ ] Zero breaking changes for existing code

## Risk Management

### Technical Risks
1. **Type System Conflicts**
   - Mitigation: Abstract type layer
   - Fallback: Partial migration

2. **Performance Impact**
   - Mitigation: Continuous benchmarking
   - Fallback: Selective feature adoption

3. **Build Complexity**
   - Mitigation: Incremental integration
   - Fallback: Modular approach

### Schedule Risks
1. **Unexpected Dependencies**
   - Buffer time in each phase
   - Parallel work streams

2. **Testing Delays**
   - Automated test migration
   - Early testing integration

## Maintenance Plan
1. **Regular Sync with Blink**
   - Quarterly review of changes
   - Selective feature adoption
   - Security update priority

2. **Documentation**
   - Migration guide
   - API documentation
   - Performance benchmarks

3. **Long-term Strategy**
   - Evaluate full Blink alignment
   - Consider upstreaming changes
   - Maintain WebF-specific optimizations

## Conclusion
This migration plan provides a structured approach to align WebF's CSS parser with Blink while maintaining WebF's unique requirements. The phased approach minimizes risk and ensures continuous functionality throughout the migration process.