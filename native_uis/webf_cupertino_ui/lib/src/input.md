# FlutterCupertinoInput

## React.js

Use the generated React component to render an iOS-style single-line text input backed by `CupertinoTextField`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoInput } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
import { useState } from 'react';

export function InputExample() {
  const [value, setValue] = useState('Initial input content');

  return (
    <FlutterCupertinoInput
      val={value}
      placeholder="Enter content"
      onInput={(event) => setValue(event.detail)}
    />
  );
}
```

### Props

```tsx
<FlutterCupertinoInput
  val={value}
  placeholder="Enter content"
  type="text"           // 'text' | 'password' | 'number' | 'tel' | 'email' | 'url'
  disabled={false}
  autofocus={false}
  clearable
  maxlength={10}
  readonly={false}
/>
```

- `val?: string` – current text value.
- `placeholder?: string` – placeholder text when empty.
- `type?: string` – input type; maps to keyboard/obscure behavior:
  - `'text'` (default)
  - `'password'` (obscured)
  - `'number'`, `'tel'`, `'email'`, `'url'` (set appropriate keyboard type).
- `disabled?: boolean` – disables editing, dims the control.
- `autofocus?: boolean` – focuses the field when mounted.
- `clearable?: boolean` – shows a clear button while editing and text is non-empty.
- `maxlength?: number` – maximum number of characters; enforced via input formatter.
- `readonly?: boolean` – makes the field read-only while still focusable/selectable.

### Slots

`FlutterCupertinoInput` supports prefix and suffix content via slots:

```tsx
<FlutterCupertinoInput placeholder="Amount">
  <span slotName="prefix">$</span>
</FlutterCupertinoInput>

<FlutterCupertinoInput placeholder="Domain" style={{ marginTop: 12 }}>
  <span slotName="suffix">.com</span>
</FlutterCupertinoInput>
```

- `slotName="prefix"` – leading content (e.g. currency symbol).
- `slotName="suffix"` – trailing content (e.g. units, domain).

### Events

```tsx
<FlutterCupertinoInput
  onInput={(event) => {
    // event.detail is the current string value
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
- `onSubmit`: fired when the user submits (e.g. taps the done/enter key); `event.detail` is the final value.
- `onFocus`: fired when the field gains focus.
- `onBlur`: fired when the field loses focus.
- `onClear`: fired when the text is cleared via the clear button or `clear()` method.

### Imperative API

```tsx
const inputRef = useRef<any>(null);

// Focus the field
inputRef.current?.focus();

// Blur the field
inputRef.current?.blur();

// Clear the field
inputRef.current?.clear();
```

Attach the ref:

```tsx
<FlutterCupertinoInput ref={inputRef} placeholder="Imperative control" />
```

### Styling

The input respects common CSS properties applied to the host element:

- `padding` – maps to internal padding of the text field.
- `height` – when set, constrains the overall height.
- `border-radius` – applied via the field's decoration.
- `background-color` – sets the field background.
- `text-align` – maps to the Flutter `textAlign` property.

Example:

```tsx
<FlutterCupertinoInput
  placeholder="Custom styles"
  className="custom-input"
/>
```

```css
.custom-input {
  height: 56px;
  border-radius: 20px;
  padding: 0 20px;
  text-align: right;
}
```

### Notes

- This component migrates Flutter's `CupertinoTextField` into a WebF custom element, maintaining iOS look-and-feel.
- For numeric input, keep `val` as a string and parse in your application code as needed.
- When using inside `FlutterCupertinoFormRow`, place the input as the default child and use row slots for labels/help text.

