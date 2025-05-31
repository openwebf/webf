# @openwebf/webf-enterprise-typings

TypeScript type definitions for WebF, with all types namespaced under `webf.*` to avoid global namespace pollution.

## Installation

```bash
npm install @openwebf/webf-enterprise-typings
```

## Basic Usage

```typescript
import '@openwebf/webf-enterprise-typings';

// All WebF types are under the webf namespace
const div: webf.HTMLDivElement = document.createElement('div');
const blob: webf.Blob = await div.toBlob();
const base64: string = await blob.base64();
```

## React Support

This package includes React utilities for seamless integration with WebF types.

### Installation

```typescript
// Import React utilities
import { toWebF, useWebFRef } from '@openwebf/webf-enterprise-typings/react';
```

### Usage Pattern

Since React expects standard DOM types in JSX, but WebF provides enhanced functionality, use this pattern:

```typescript
import React, { useRef, useEffect } from 'react';
import { toWebF } from '@openwebf/webf-enterprise-typings/react';

function MyComponent() {
  // 1. Use standard DOM types for refs (React requirement)
  const divRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    if (divRef.current) {
      // 2. Cast to WebF type when you need WebF features
      const webfDiv = toWebF(divRef.current);
      
      // 3. Now use WebF-specific methods
      webfDiv.toBlob().then(async (blob) => {
        const base64 = await blob.base64();
        console.log('Base64:', base64);
      });
    }
  }, []);
  
  // 4. In JSX, use standard elements
  return <div ref={divRef}>Content</div>;
}
```

### React Hook

For convenience, use the `useWebFRef` hook:

```typescript
import { useWebFRef } from '@openwebf/webf-enterprise-typings/react';

function MyComponent() {
  const { ref, webf } = useWebFRef<HTMLDivElement>();
  
  useEffect(() => {
    // Direct access to WebF element
    webf?.toBlob().then(blob => {
      // ...
    });
  }, [webf]);
  
  return <div ref={ref}>Content</div>;
}
```

### Available Utilities

#### `toWebF(element)`
Casts a standard DOM element to its WebF equivalent:
- Supports all HTML elements (div, canvas, img, form, input, etc.)
- Supports SVG elements (svg, path, circle, rect, etc.)
- Type-safe with proper TypeScript overloads

#### `isWebFElement(element)`
Type guard to check if an element supports WebF features:
```typescript
if (isWebFElement(element)) {
  // element is now typed as webf.Element
  element.toBlob();
}
```

#### `webfEventHandler(handler)`
Creates WebF-aware event handlers:
```typescript
const handleClick = webfEventHandler((event: webf.MouseEvent) => {
  console.log(event.clientX, event.clientY);
});

<div onClick={handleClick}>Click me</div>
```

#### `useWebFRef<T>()`
React hook that provides both standard ref and WebF-typed element:
```typescript
const { ref, webf } = useWebFRef<HTMLCanvasElement>();
// ref: React.RefObject<HTMLCanvasElement>
// webf: webf.HTMLCanvasElement | null
```

## Type Safety

All WebF types are properly namespaced to avoid conflicts with standard DOM types:

```typescript
// Standard DOM types (from lib.dom.d.ts)
const domDiv: HTMLDivElement = document.createElement('div');

// WebF types (namespaced)
const webfDiv: webf.HTMLDivElement = toWebF(domDiv);

// WebF-specific methods
webfDiv.toBlob(); // ✅ Available on WebF type
domDiv.toBlob();  // ❌ Error: Property 'toBlob' does not exist
```

## Examples

See the `webf/example/tailwind_react` project for comprehensive examples of all features.