# CSS Variable Update Issue with Display:None Elements

## Problem Description
CSS variables defined within `@media (prefers-color-scheme)` queries were not updating for elements with `display: none` when switching between dark and light modes. When these elements became visible later, they retained the old CSS variable values instead of reflecting the current theme.

### Example Scenario
```css
:root {
  --bg-fill-table-accent: red;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg-fill-table-accent: blue;
  }
}

@media (prefers-color-scheme: light) {
  :root {
    --bg-fill-table-accent: green;
  }
}

.bg-fill-table-accent {
  background-color: var(--bg-fill-table-accent);
}
```

When an element with class `bg-fill-table-accent` had `display: none` and the theme changed from light to dark, the element would still show green (light mode color) instead of blue (dark mode color) when made visible.

## Root Cause Analysis
WebF implements a performance optimization in `element.dart` where style recalculation is skipped for elements with `display: none`:

```dart
void recalculateStyle({bool rebuildNested = false, bool forceRecalculate = false}) {
  if (forceRecalculate || renderStyle.display != CSSDisplay.none) {
    // Style recalculation happens here
  }
  // Elements with display:none are skipped
}
```

This optimization prevents CSS variables from being updated when media queries change, violating CSS specifications that require CSS variables to be inherited and updated regardless of display state.

## Solution
Modified the `recalculateStyle` method to ensure CSS variables are updated even for `display: none` elements when styles are being rebuilt due to media query changes:

```dart
void recalculateStyle({bool rebuildNested = false, bool forceRecalculate = false}) {
  // Always update CSS variables even for display:none elements when rebuilding nested
  bool shouldUpdateCSSVariables = rebuildNested && renderStyle.display == CSSDisplay.none;
  
  if (forceRecalculate || renderStyle.display != CSSDisplay.none || shouldUpdateCSSVariables) {
    // Diff style.
    CSSStyleDeclaration newStyle = CSSStyleDeclaration();
    applyStyle(newStyle);
    var hasInheritedPendingProperty = false;
    if (style.merge(newStyle)) {
      hasInheritedPendingProperty = style.hasInheritedPendingProperty;
      style.flushPendingProperties();
    }

    if (rebuildNested || hasInheritedPendingProperty) {
      // Update children style.
      children.forEach((Element child) {
        child.recalculateStyle(rebuildNested: rebuildNested, forceRecalculate: forceRecalculate);
      });
    }
  }
}
```

## Key Files Modified
- `/webf/lib/src/dom/element.dart` - Modified `recalculateStyle` method

## Testing Approach

### Integration Test
Created a comprehensive integration test in `/integration_tests/specs/css/css-mediaqueries/prefers-color-scheme.ts`:

```typescript
it('should update CSS variables for elements with display:none', async () => {
  const cssText = `
  :root {
    --bg-fill-table-accent: red;
  }

  @media (prefers-color-scheme: dark) {
    :root {
      --bg-fill-table-accent: blue;
    }
  }

  @media (prefers-color-scheme: light) {
    :root {
      --bg-fill-table-accent: green;
    }
  }

  .bg-fill-table-accent {
    background-color: var(--bg-fill-table-accent);
    width: 100px;
    height: 100px;
  }
  `;
  const style = document.createElement('style');
  style.innerHTML = cssText;
  document.head.append(style);

  const container = createElement('div', {
    className: 'bg-fill-table-accent',
    style: {
      display: 'none'
    }
  });

  BODY.appendChild(container);

  // Start with light mode
  simulateChangeDarkMode(false);
  
  // Log initial computed style while display:none
  const computedStyle1 = getComputedStyle(container);
  console.log('Light mode background (display:none):', computedStyle1.backgroundColor);

  // Switch to dark mode
  simulateChangeDarkMode(true);

  // Log updated computed style while still display:none
  const computedStyle2 = getComputedStyle(container);
  console.log('Dark mode background (display:none):', computedStyle2.backgroundColor);
  
  // Now show the element
  container.style.display = 'block';
  
  await snapshot();
  
  // Check the computed style after showing
  const computedStyle3 = getComputedStyle(container);
  console.log('Dark mode background (display:block):', computedStyle3.backgroundColor);
  
  // The background should be blue (dark mode color)
  expect(computedStyle3.backgroundColor).toBe('rgb(0, 0, 255)');
});
```

### Running Integration Tests

1. **Run all integration tests:**
   ```bash
   cd integration_tests
   npm run integration
   ```

2. **Run only specific tests (faster):**
   - Change `describe()` to `fdescribe()` in the test file to focus only on that test suite
   - Example: `fdescribe('MediaQuery prefers-color-scheme', () => { ... })`
   - Then run: `npm run integration`

3. **Test file location:**
   - Integration tests are located in `/integration_tests/specs/`
   - CSS-related tests are in `/integration_tests/specs/css/`
   - Media query tests specifically in `/integration_tests/specs/css/css-mediaqueries/`

### Key Testing Functions
- `simulateChangeDarkMode(isDarkMode: boolean)` - Simulates platform dark mode changes
- `getComputedStyle(element)` - Gets the computed styles including resolved CSS variables
- `await snapshot()` - Takes a visual snapshot for comparison

## Lessons Learned

1. **Performance optimizations can break CSS specifications** - While skipping style calculations for `display: none` elements improves performance, it can violate CSS inheritance rules.

2. **CSS variables require special handling** - Unlike regular CSS properties, CSS variables must be inherited and available even for hidden elements.

3. **Integration tests are crucial** - The issue was only apparent when toggling visibility after theme changes, making integration tests essential for catching such edge cases.

4. **Targeted fixes are better than brute force** - Instead of using `forceRecalculate: true` for all elements (performance impact), we specifically handle CSS variable updates for hidden elements only when needed.

## References
- CSS Variables specification: https://www.w3.org/TR/css-variables-1/
- CSS Display specification: https://www.w3.org/TR/css-display-3/
- WebF style recalculation logic: `/webf/lib/src/dom/element.dart`