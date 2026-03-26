# WebF Async Rendering - Complete Examples

## Example 1: Basic Vanilla JavaScript

### ❌ Incorrect Pattern

```javascript
// This will NOT work - returns zeros
function createAndMeasureDiv() {
  const div = document.createElement('div');
  div.textContent = 'Hello World';
  div.style.padding = '20px';
  div.style.border = '1px solid black';

  document.body.appendChild(div);

  // ❌ Element not laid out yet!
  const rect = div.getBoundingClientRect();
  console.log(`Width: ${rect.width}`); // 0
  console.log(`Height: ${rect.height}`); // 0

  return div;
}
```

### ✅ Correct Pattern

```javascript
// This WORKS - waits for layout
function createAndMeasureDiv() {
  const div = document.createElement('div');
  div.textContent = 'Hello World';
  div.style.padding = '20px';
  div.style.border = '1px solid black';

  // Listen for onscreen event
  div.addEventListener('onscreen', () => {
    // ✅ Now we can safely measure!
    const rect = div.getBoundingClientRect();
    console.log(`Width: ${rect.width}`); // Real value
    console.log(`Height: ${rect.height}`); // Real value
  }, { once: true }); // Remove listener after first call

  document.body.appendChild(div);

  return div;
}
```

## Example 2: Dynamic Content with Measurements

```javascript
async function fetchAndDisplayUserCard(userId) {
  // Fetch user data
  const response = await fetch(`/api/users/${userId}`);
  const user = await response.json();

  // Create card element
  const card = document.createElement('div');
  card.className = 'user-card';
  card.innerHTML = `
    <img src="${user.avatar}" alt="${user.name}">
    <h2>${user.name}</h2>
    <p>${user.bio}</p>
  `;

  // Wait for layout before positioning
  card.addEventListener('onscreen', () => {
    const rect = card.getBoundingClientRect();

    // Position a badge in the top-right corner
    const badge = document.createElement('div');
    badge.className = 'badge';
    badge.textContent = user.status;
    badge.style.position = 'absolute';
    badge.style.top = '10px';
    badge.style.right = '10px';

    card.appendChild(badge);
  }, { once: true });

  document.body.appendChild(card);
}
```

## Example 3: React Component with useFlutterAttached

### ❌ Incorrect Pattern (Using useEffect)

```jsx
import { useEffect, useRef, useState } from 'react';

function ImageGallery({ images }) {
  const containerRef = useRef(null);
  const [layout, setLayout] = useState([]);

  useEffect(() => {
    // ❌ This will fail - elements not laid out yet!
    const children = containerRef.current.children;
    const positions = Array.from(children).map(child =>
      child.getBoundingClientRect() // Returns zeros!
    );
    setLayout(positions);
  }, [images]);

  return (
    <div ref={containerRef} className="gallery">
      {images.map(img => (
        <img key={img.id} src={img.url} alt={img.title} />
      ))}
    </div>
  );
}
```

### ✅ Correct Pattern (Using useFlutterAttached)

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useState } from 'react';

function ImageGallery({ images }) {
  const [layout, setLayout] = useState([]);

  const containerRef = useFlutterAttached(() => {
    // ✅ This works - elements are laid out!
    const children = containerRef.current.children;
    const positions = Array.from(children).map(child => {
      const rect = child.getBoundingClientRect();
      return {
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height
      };
    });
    setLayout(positions);
  });

  return (
    <div ref={containerRef} className="gallery">
      {images.map(img => (
        <img key={img.id} src={img.url} alt={img.title} />
      ))}
    </div>
  );
}
```

## Example 4: Tooltip Positioning

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useState, useRef } from 'react';

function TooltipButton({ text, tooltipText }) {
  const [showTooltip, setShowTooltip] = useState(false);
  const buttonRef = useRef(null);
  const [tooltipStyle, setTooltipStyle] = useState({});

  const tooltipRef = useFlutterAttached(() => {
    if (!showTooltip) return;

    // ✅ Calculate tooltip position after layout
    const buttonRect = buttonRef.current.getBoundingClientRect();
    const tooltipRect = tooltipRef.current.getBoundingClientRect();

    setTooltipStyle({
      position: 'fixed',
      left: buttonRect.left + (buttonRect.width / 2) - (tooltipRect.width / 2),
      top: buttonRect.bottom + 5
    });
  });

  return (
    <>
      <button
        ref={buttonRef}
        onMouseEnter={() => setShowTooltip(true)}
        onMouseLeave={() => setShowTooltip(false)}
      >
        {text}
      </button>

      {showTooltip && (
        <div ref={tooltipRef} className="tooltip" style={tooltipStyle}>
          {tooltipText}
        </div>
      )}
    </>
  );
}
```

## Example 5: Masonry Layout

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useState } from 'react';

function MasonryGrid({ items }) {
  const [columnHeights, setColumnHeights] = useState([0, 0, 0]);
  const COLUMN_COUNT = 3;

  const containerRef = useFlutterAttached(() => {
    // ✅ Calculate masonry layout after all items are laid out
    const children = Array.from(containerRef.current.children);
    const newHeights = [0, 0, 0];

    children.forEach((child, index) => {
      const columnIndex = index % COLUMN_COUNT;
      const rect = child.getBoundingClientRect();

      // Position item in shortest column
      child.style.position = 'absolute';
      child.style.left = `${columnIndex * 33.33}%`;
      child.style.top = `${newHeights[columnIndex]}px`;

      newHeights[columnIndex] += rect.height + 10; // 10px gap
    });

    setColumnHeights(newHeights);
  });

  return (
    <div
      ref={containerRef}
      style={{
        position: 'relative',
        height: Math.max(...columnHeights)
      }}
    >
      {items.map(item => (
        <div key={item.id} className="masonry-item">
          <img src={item.image} alt={item.title} />
          <p>{item.title}</p>
        </div>
      ))}
    </div>
  );
}
```

## Example 6: Scroll to Element

```javascript
function scrollToSection(sectionId) {
  const section = document.getElementById(sectionId);

  if (!section) {
    console.error(`Section ${sectionId} not found`);
    return;
  }

  // ❌ WRONG - Position might be 0 if not laid out
  // window.scrollTo({ top: section.offsetTop, behavior: 'smooth' });

  // ✅ CORRECT - Wait for layout
  section.addEventListener('onscreen', () => {
    window.scrollTo({
      top: section.offsetTop,
      behavior: 'smooth'
    });
  }, { once: true });
}
```

## Example 7: Responsive Layout Adjustments

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useState } from 'react';

function ResponsiveCard({ title, content }) {
  const [isNarrow, setIsNarrow] = useState(false);

  const cardRef = useFlutterAttached(() => {
    // ✅ Check card width after layout
    const rect = cardRef.current.getBoundingClientRect();
    setIsNarrow(rect.width < 300);
  });

  return (
    <div
      ref={cardRef}
      className={`card ${isNarrow ? 'narrow' : 'wide'}`}
    >
      <h2>{title}</h2>
      <p>{content}</p>
    </div>
  );
}
```

## Example 8: Animation Based on Element Position

```javascript
function animateOnScreen() {
  const elements = document.querySelectorAll('.animate-me');

  elements.forEach(element => {
    element.addEventListener('onscreen', () => {
      // ✅ Element is laid out, we can get its position
      const rect = element.getBoundingClientRect();
      const viewportHeight = window.innerHeight;

      // Calculate animation delay based on position
      const delay = (rect.top / viewportHeight) * 500; // Max 500ms delay

      element.style.animationDelay = `${delay}ms`;
      element.classList.add('fade-in');
    }, { once: true });
  });
}
```

## Example 9: Dynamic Font Sizing

```jsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useState } from 'react';

function AutoSizeText({ text, maxWidth }) {
  const [fontSize, setFontSize] = useState(16);

  const textRef = useFlutterAttached(() => {
    // ✅ Measure text and adjust font size
    let currentSize = 16;
    textRef.current.style.fontSize = `${currentSize}px`;

    // Wait for style to apply
    textRef.current.addEventListener('onscreen', () => {
      const rect = textRef.current.getBoundingClientRect();

      // Reduce font size if text is too wide
      while (rect.width > maxWidth && currentSize > 10) {
        currentSize -= 1;
        textRef.current.style.fontSize = `${currentSize}px`;
      }

      setFontSize(currentSize);
    }, { once: true });
  });

  return (
    <div ref={textRef} style={{ fontSize }}>
      {text}
    </div>
  );
}
```

## Example 10: Cleanup with offscreen Event

```javascript
class InteractiveWidget {
  constructor(element) {
    this.element = element;
    this.animationFrame = null;

    // Start animation when element is laid out
    this.element.addEventListener('onscreen', () => {
      this.startAnimation();
    }, { once: true });

    // Cleanup when element is removed
    this.element.addEventListener('offscreen', () => {
      this.stopAnimation();
      this.cleanup();
    }, { once: true });
  }

  startAnimation() {
    const animate = () => {
      // Animation logic using element dimensions
      const rect = this.element.getBoundingClientRect();
      // ... update animation based on rect

      this.animationFrame = requestAnimationFrame(animate);
    };

    animate();
  }

  stopAnimation() {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
      this.animationFrame = null;
    }
  }

  cleanup() {
    // Clean up resources
    console.log('Widget cleaned up');
  }
}
```

## Key Patterns Summary

### Pattern 1: One-Time Measurement
```javascript
element.addEventListener('onscreen', callback, { once: true });
```

### Pattern 2: React Hook
```jsx
const ref = useFlutterAttached(onAttached, onDetached);
```

### Pattern 3: Style Then Measure
```javascript
element.style.width = '500px';
element.addEventListener('onscreen', () => {
  const rect = element.getBoundingClientRect();
}, { once: true });
```

### Pattern 4: Cleanup on Remove
```javascript
element.addEventListener('offscreen', cleanup, { once: true });
```

## Testing Your Code

To verify your code handles async rendering correctly:

1. Add console.logs in onscreen callbacks
2. Check if dimensions are non-zero
3. Test with dynamic content
4. Verify cleanup happens (check for memory leaks)

```javascript
element.addEventListener('onscreen', () => {
  const rect = element.getBoundingClientRect();
  console.log('✅ onscreen fired');
  console.log(`Width: ${rect.width}, Height: ${rect.height}`);

  if (rect.width === 0) {
    console.error('❌ Width is still 0 - something is wrong!');
  }
}, { once: true });
```