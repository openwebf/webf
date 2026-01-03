---
name: webf-async-rendering
description: Understand and work with WebF's async rendering model - handle onscreen/offscreen events and element measurements correctly. Use when getBoundingClientRect returns zeros, computed styles are incorrect, measurements fail, or elements don't layout as expected.
---

# WebF Async Rendering

> **Note**: WebF development is nearly identical to web development - you use the same tools (Vite, npm, Vitest), same frameworks (React, Vue, Svelte), and same deployment services (Vercel, Netlify). This skill covers **one of the 3 key differences**: WebF's async rendering model. The other two differences are API compatibility and routing.

**This is the #1 most important concept to understand when moving from browser development to WebF.**

## The Fundamental Difference

### In Browsers (Synchronous Layout)
When you modify the DOM, the browser **immediately** performs layout calculations:

```javascript
// Browser behavior
const div = document.createElement('div');
document.body.appendChild(div);
console.log(div.getBoundingClientRect()); // ✅ Returns real dimensions
```

Layout happens **synchronously** - you get dimensions right away, but this can cause performance issues (layout thrashing).

### In WebF (Asynchronous Layout)
When you modify the DOM, WebF **batches** the changes and processes them in the next rendering frame:

```javascript
// WebF behavior
const div = document.createElement('div');
document.body.appendChild(div);
console.log(div.getBoundingClientRect()); // ❌ Returns zeros! Not laid out yet.
```

Layout happens **asynchronously** - elements exist in the DOM tree but haven't been measured/positioned yet.

## Why Async Rendering?

**Performance**: WebF's async rendering is **20x cheaper** than browser synchronous layout!

- DOM updates are batched together
- Multiple changes processed in one optimized pass
- Eliminates layout thrashing
- No need for `DocumentFragment` optimizations

**Trade-off**: You must explicitly wait for layout to complete before measuring elements.

## The Solution: onscreen/offscreen Events

WebF provides two non-standard events to handle the async lifecycle:

| Event | When It Fires | Purpose |
|-------|---------------|---------|
| `onscreen` | Element has been laid out and rendered | Safe to measure dimensions, get computed styles |
| `offscreen` | Element removed from render tree | Cleanup and resource management |

**Think of these like `IntersectionObserver` but for layout lifecycle, not viewport visibility.**

## How to Measure Elements Correctly

### ❌ WRONG: Measuring Immediately

```javascript
// DON'T DO THIS - Will return 0 or incorrect values
const div = document.createElement('div');
div.textContent = 'Hello WebF';
document.body.appendChild(div);

const rect = div.getBoundingClientRect();  // ❌ Returns zeros!
console.log(rect.width);  // 0
console.log(rect.height); // 0
```

### ✅ CORRECT: Wait for onscreen Event

```javascript
// DO THIS - Wait for layout to complete
const div = document.createElement('div');
div.textContent = 'Hello WebF';

div.addEventListener('onscreen', () => {
  // Element is now laid out - safe to measure!
  const rect = div.getBoundingClientRect();  // ✅ Real dimensions
  console.log(`Width: ${rect.width}, Height: ${rect.height}`);
});

document.body.appendChild(div);
```

## React: useFlutterAttached Hook

For React developers, WebF provides a convenient hook:

### ❌ WRONG: Using useEffect

```jsx
import { useEffect, useRef } from 'react';

function MyComponent() {
  const ref = useRef(null);

  useEffect(() => {
    // ❌ Element not laid out yet!
    const rect = ref.current.getBoundingClientRect();
    console.log(rect); // Will be zeros
  }, []);

  return <div ref={ref}>Content</div>;
}
```

### ✅ CORRECT: Using useFlutterAttached

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';

function MyComponent() {
  const ref = useFlutterAttached(
    () => {
      // ✅ onAttached callback - element is laid out!
      const rect = ref.current.getBoundingClientRect();
      console.log(`Width: ${rect.width}, Height: ${rect.height}`);
    },
    () => {
      // onDetached callback (optional)
      console.log('Component removed from render tree');
    }
  );

  return <div ref={ref}>Content</div>;
}
```

## Layout-Dependent APIs

**Only call these inside onscreen callback or useFlutterAttached:**

- `element.getBoundingClientRect()`
- `window.getComputedStyle(element)`
- `element.offsetWidth` / `element.offsetHeight`
- `element.clientWidth` / `element.clientHeight`
- `element.scrollWidth` / `element.scrollHeight`
- `element.offsetTop` / `element.offsetLeft`
- Any logic that depends on element position or size

## Common Scenarios

### Scenario 1: Measuring After Style Changes

```javascript
const div = document.getElementById('myDiv');

// ❌ WRONG
div.style.width = '500px';
const rect = div.getBoundingClientRect(); // Old dimensions!

// ✅ CORRECT
div.style.width = '500px';
div.addEventListener('onscreen', () => {
  const rect = div.getBoundingClientRect(); // New dimensions!
}, { once: true }); // Use 'once' to remove listener after first call
```

### Scenario 2: Positioning Tooltips/Popovers

```javascript
function showTooltip(targetElement) {
  const tooltip = document.createElement('div');
  tooltip.className = 'tooltip';
  tooltip.textContent = 'Tooltip text';

  tooltip.addEventListener('onscreen', () => {
    // Now we can safely position the tooltip
    const targetRect = targetElement.getBoundingClientRect();
    const tooltipRect = tooltip.getBoundingClientRect();

    tooltip.style.left = `${targetRect.left}px`;
    tooltip.style.top = `${targetRect.bottom + 5}px`;
  }, { once: true });

  document.body.appendChild(tooltip);
}
```

### Scenario 3: React Component with Measurement

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useState } from 'react';

function MeasuredBox() {
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 });

  const ref = useFlutterAttached(() => {
    const rect = ref.current.getBoundingClientRect();
    setDimensions({
      width: rect.width,
      height: rect.height
    });
  });

  return (
    <div ref={ref} style={{ padding: '20px', border: '1px solid' }}>
      <p>This box is {dimensions.width}px wide</p>
      <p>and {dimensions.height}px tall</p>
    </div>
  );
}
```

## Performance Benefits

WebF's async rendering provides significant advantages:

1. **Batched Updates**: Multiple DOM changes processed together
2. **No Layout Thrashing**: Eliminates read-write-read-write patterns
3. **Optimized Rendering**: Single pass through the render tree
4. **No DocumentFragment Needed**: Batching is automatic

Compare to browsers where you'd need to carefully batch operations:

```javascript
// Browser optimization (not needed in WebF!)
const fragment = document.createDocumentFragment();
for (let i = 0; i < 100; i++) {
  const div = document.createElement('div');
  fragment.appendChild(div);
}
document.body.appendChild(fragment); // Single layout
```

In WebF, just append directly - it's automatically optimized!

## Common Mistakes

### Mistake 1: Forgetting to Wait

```javascript
// ❌ WRONG
const div = document.createElement('div');
document.body.appendChild(div);
initializeWidget(div); // Assumes div is laid out - will fail!
```

```javascript
// ✅ CORRECT
const div = document.createElement('div');
div.addEventListener('onscreen', () => {
  initializeWidget(div); // Now it's safe!
}, { once: true });
document.body.appendChild(div);
```

### Mistake 2: Not Cleaning Up Listeners

```javascript
// ❌ WRONG - Memory leak
element.addEventListener('onscreen', handleLayout);
// Listener never removed!

// ✅ CORRECT
element.addEventListener('onscreen', handleLayout, { once: true });
// OR
element.addEventListener('onscreen', handleLayout);
// Later...
element.removeEventListener('onscreen', handleLayout);
```

### Mistake 3: Using IntersectionObserver for Layout

```javascript
// ❌ WRONG - IntersectionObserver is for viewport visibility, not layout
const observer = new IntersectionObserver((entries) => {
  // This fires based on viewport, not layout completion!
});

// ✅ CORRECT - Use onscreen for layout lifecycle
element.addEventListener('onscreen', () => {
  // Element is laid out
});
```

## Debugging Tips

If you're getting zero or incorrect dimensions:

1. **Check if you're waiting for onscreen**: Most common issue
2. **Verify element is actually added to DOM**: Must be in document tree
3. **Confirm element has display style**: `display: none` elements don't layout
4. **Use console.log in onscreen callback**: Verify callback fires

```javascript
element.addEventListener('onscreen', () => {
  console.log('✅ onscreen fired');
  console.log(element.getBoundingClientRect());
}, { once: true });
```

## Resources

- **Core Concepts - Async Rendering**: https://openwebf.com/en/docs/developer-guide/core-concepts#async-rendering
- **Debugging & Performance**: https://openwebf.com/en/docs/developer-guide/debugging-performance
- **@openwebf/react-core-ui**: Install with `npm install @openwebf/react-core-ui`

## Key Takeaways

✅ **DO**:
- Use `onscreen` event or `useFlutterAttached` hook
- Wait for layout before measuring elements
- Use `{ once: true }` for one-time measurements

❌ **DON'T**:
- Measure immediately after appendChild()
- Rely on synchronous layout like browsers
- Use IntersectionObserver for layout detection
- Forget to clean up event listeners