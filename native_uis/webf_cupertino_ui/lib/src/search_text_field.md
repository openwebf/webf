# FlutterCupertinoSearchTextField

## React.js

Use the generated React component to render an iOS-style search field backed by
`CupertinoSearchTextField`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoSearchTextField } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
import { useState } from 'react';

export function SearchExample() {
  const [query, setQuery] = useState('');

  return (
    <FlutterCupertinoSearchTextField
      val={query}
      placeholder="Search"
      onInput={(event) => setQuery(event.detail)}
    />
  );
}
```

### Props

```tsx
<FlutterCupertinoSearchTextField
  val={value}
  placeholder="Search"
  disabled={false}
  autofocus={false}
/>
```

- `val?: string` – current search text.
- `placeholder?: string` – placeholder text when empty. Defaults to the localized “Search” if omitted.
- `disabled?: boolean` – disables editing and interactions.
- `autofocus?: boolean` – focuses the field when mounted.

### Events

```tsx
<FlutterCupertinoSearchTextField
  onInput={(event) => {
    console.log('input', event.detail);
  }}
  onSubmit={(event) => {
    console.log('submit', event.detail);
  }}
  onFocus={() => console.log('focus')}
  onBlur={() => console.log('blur')}
  onClear={() => console.log('cleared')}
/>
```

- `onInput`: fired whenever the text changes; `event.detail` is the new value.
- `onSubmit`: fired when the user submits (presses the search / enter button); `event.detail` is the final value.
- `onFocus`: fired when the field gains focus.
- `onBlur`: fired when the field loses focus.
- `onClear`: fired when the text is cleared via the suffix icon or `clear()` method.

### Imperative API

```tsx
const searchRef = useRef<any>(null);

// Focus the search field
searchRef.current?.focus();

// Blur the search field
searchRef.current?.blur();

// Clear the search field
searchRef.current?.clear();
```

Attach the ref:

```tsx
<FlutterCupertinoSearchTextField ref={searchRef} placeholder="Search..." />
```

### Styling

The search field respects common CSS properties via the host element:

- `padding` – overrides internal padding around the text and icons.
- `border-radius` – customizes the pill shape; defaults to 9px.
- `background-color` – sets the background fill; defaults to iOS-style tertiary fill.
- `text-align` – text alignment inside the field.

Example:

```tsx
<FlutterCupertinoSearchTextField
  placeholder="Search settings"
  style={{
    margin: 12,
    backgroundColor: '#f2f3f5',
    borderRadius: 16,
  }}
/>
```

### Notes

- This component migrates Flutter’s `CupertinoSearchTextField` into a WebF custom element.
- For advanced behaviors (e.g., custom suffix actions), you can combine this element with surrounding UI logic and clear the value via the imperative API.

