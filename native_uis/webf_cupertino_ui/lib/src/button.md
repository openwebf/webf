# FlutterCupertinoButton

## React.js

Use the generated React component to render a Cupertino-style button powered by WebF and Flutter.

Props are React-friendly (camelCase) and internally mapped to the underlying custom element
attributes.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
export function Example() {
  return (
    <FlutterCupertinoButton onClick={() => console.log('clicked')}>
      Tap me
    </FlutterCupertinoButton>
  );
}
```

### Variants & Size

```tsx
<FlutterCupertinoButton variant="plain">Plain</FlutterCupertinoButton>
<FlutterCupertinoButton variant="tinted">Tinted</FlutterCupertinoButton>
<FlutterCupertinoButton variant="filled">Filled</FlutterCupertinoButton>

<FlutterCupertinoButton size="small">Small</FlutterCupertinoButton>
<FlutterCupertinoButton size="large">Large</FlutterCupertinoButton>
```

### Disabled & Disabled Color

```tsx
// Disabled state
<FlutterCupertinoButton disabled>Disabled</FlutterCupertinoButton>

// Optional custom disabled color (hex: #RRGGBB or #AARRGGBB)
<FlutterCupertinoButton disabled disabledColor="#B0B0B0">
  Disabled with color
  </FlutterCupertinoButton>
```

### Pressed Opacity

```tsx
// Pressed state opacity (string between 0.0 and 1.0); default is '0.4'
<FlutterCupertinoButton pressedOpacity="0.2">Softer press</FlutterCupertinoButton>
```

### Styling

Use `className` or `style` for host-level styling. The element respects CSS such as border radius,
padding, min-height, and text alignment. If you set a fixed width, internal padding is removed to
respect width-driven layout.

```tsx
<FlutterCupertinoButton
  className="px-4 py-2 rounded-xl"
  style={{ minHeight: 44, textAlign: 'center' }}
  variant="tinted"
>
  Continue
</FlutterCupertinoButton>

<FlutterCupertinoButton
  className="w-52 rounded-lg"
  variant="tinted"
>
  Fixed width
</FlutterCupertinoButton>
```

### Events

```tsx
<FlutterCupertinoButton onClick={(e) => console.log('clicked', e)}>
  Clickable
</FlutterCupertinoButton>
```

### Children

You can pass text or React nodes. The first child is used as the primary content.

```tsx
<FlutterCupertinoButton>
  Submit
</FlutterCupertinoButton>
```

### Notes

- `filled` variant does not accept custom background color (matches Flutter semantics). For custom
  colors, use `variant="tinted"` or `variant="plain"` with CSS `background-color`.
- When a fixed CSS `width` is set, internal padding becomes zero to avoid layout conflict.
