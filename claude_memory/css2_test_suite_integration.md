# CSS2.1 Test Suite Integration Plan for WebF

## Overview
WebF currently lacks systematic CSS2.1 compliance testing. This document outlines how to integrate the W3C CSS2.1 test suite.

## W3C CSS2.1 Test Suite
- Official repository: https://github.com/w3c/csswg-test
- CSS2.1 tests: `/css21/` directory
- Contains ~10,000 tests covering all CSS2.1 features
- Test format: HTML files with reference files

## Integration Approach

### 1. Add Test Suite as Submodule
```bash
git submodule add https://github.com/w3c/csswg-test.git integration_tests/specs/css21-conformance
```

### 2. Create Test Runner
```typescript
// integration_tests/specs/css21-conformance/runner.ts
import { describe, it, expect } from '@webf/integration-tests';

const CSS21_TESTS = [
  // List of test files from css21 directory
];

describe('CSS2.1 Conformance', () => {
  CSS21_TESTS.forEach(test => {
    it(test.name, async () => {
      // Load test file
      // Compare with reference
      // Check pass/fail
    });
  });
});
```

### 3. Categories to Test
- Selectors (attribute, pseudo-class, pseudo-element)
- Box model (margin, padding, border)
- Visual formatting (positioning, floats, display)
- Tables
- Colors and backgrounds
- Fonts and text
- Generated content
- Paged media
- User interface

### 4. Implementation Challenges
- WebF uses Flutter rendering, not browser rendering
- Some tests rely on specific browser behaviors
- Need to adapt visual tests to snapshot testing
- May need to exclude platform-specific tests

### 5. Benefits
- Objective compliance measurement
- Identify missing features
- Regression prevention
- Industry-standard validation

## Alternative: CSS Test Harness
Consider using the CSS WG's test harness:
- https://test.csswg.org/harness/
- Can run tests automatically
- Generates compliance reports
- May need adaptation for WebF's architecture