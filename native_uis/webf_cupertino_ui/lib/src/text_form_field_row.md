# FlutterCupertinoTextFormFieldRow

## React.js

Use the generated React component to render an iOS-style form row that contains
an inline borderless text field. This is the WebF counterpart of Flutter&apos;s
`CupertinoTextFormFieldRow`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoTextFormFieldRow } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
import { useState } from 'react';

export function AccountNameRow() {
  const [name, setName] = useState('');

  return (
    <FlutterCupertinoTextFormFieldRow
      val={name}
      placeholder="Enter account name"
      onInput={(event) => setName(event.detail)}
    >
      <span slotName="prefix">Account</span>
    </FlutterCupertinoTextFormFieldRow>
  );
}
```

### Props

```tsx
<FlutterCupertinoTextFormFieldRow
  val={value}
  placeholder="Enter value"
  type="text"        // 'text' | 'password' | 'number' | 'tel' | 'email' | 'url'
  disabled={false}
  autofocus={false}
  clearable
  maxlength={50}
  readonly={false}
>
  <span slotName="prefix">Label</span>
  <span slotName="helper">Helper text below the field.</span>
  <span slotName="error">Error message when invalid.</span>
</FlutterCupertinoTextFormFieldRow>
```

- `val?: string` – current text value.
- `placeholder?: string` – placeholder text when empty.
- `type?: string` – input type / keyboard type:
  - `'text'` (default)
  - `'password'` (obscured)
  - `'number'`, `'tel'`, `'email'`, `'url'`.
- `disabled?: boolean` – disables editing and interactions.
- `autofocus?: boolean` – focuses the field when mounted.
- `clearable?: boolean` – shows a clear button while editing when text is non-empty.
- `maxlength?: number` – maximum number of characters (enforced via formatter).
- `readonly?: boolean` – makes the field read-only while still focusable.

### Slots

`FlutterCupertinoTextFormFieldRow` supports the same logical slots as a plain
form row:

```tsx
<FlutterCupertinoTextFormFieldRow placeholder="Email">
  <span slotName="prefix">Email</span>
  <span slotName="helper">We will send a confirmation link.</span>
  <span slotName="error">Invalid email address</span>
</FlutterCupertinoTextFormFieldRow>
```

- `slotName="prefix"` – leading label.
- `slotName="helper"` – helper text below the row.
- `slotName="error"` – error text below the row.
- default slot – reserved for the internal text field (no custom child needed).

### Events

```tsx
<FlutterCupertinoTextFormFieldRow
  onInput={(event) => {
    console.log('input', event.detail);
  }}
  onSubmit={(event) => {
    console.log('submit', event.detail);
  }}
  onFocus={() => console.log('focus')}
  onBlur={() => console.log('blur')}
  onClear={() => console.log('cleared')}
>
  <span slotName="prefix">Username</span>
</FlutterCupertinoTextFormFieldRow>
```

- `onInput`: fired whenever the text changes; `event.detail` is the new value.
- `onSubmit`: fired when the user submits (e.g. presses the done/enter key); `event.detail` is the value.
- `onFocus`: fired when the inner field gains focus.
- `onBlur`: fired when the inner field loses focus.
- `onClear`: fired when the value is cleared via `clear()` or programmatic clear.

### Imperative API

```tsx
const rowRef = useRef<any>(null);

// Focus the field in the row
rowRef.current?.focus();

// Blur the field
rowRef.current?.blur();

// Clear the field
rowRef.current?.clear();
```

Attach the ref:

```tsx
<FlutterCupertinoTextFormFieldRow
  ref={rowRef}
  placeholder="Imperative control"
>
  <span slotName="prefix">Name</span>
</FlutterCupertinoTextFormFieldRow>
```

### Usage with Form Sections

`FlutterCupertinoTextFormFieldRow` is designed to be used inside
`FlutterCupertinoFormSection` alongside other rows:

```tsx
<FlutterCupertinoFormSection insetGrouped>
  <span slotName="header">Profile</span>

  <FlutterCupertinoTextFormFieldRow placeholder="Full name">
    <span slotName="prefix">Name</span>
  </FlutterCupertinoTextFormFieldRow>

  <FlutterCupertinoTextFormFieldRow placeholder="Email">
    <span slotName="prefix">Email</span>
  </FlutterCupertinoTextFormFieldRow>
</FlutterCupertinoFormSection>
```

### Notes

- This component migrates Flutter&apos;s `CupertinoTextFormFieldRow` into a
  single WebF custom element, combining form row layout and a borderless
  `CupertinoTextField`.
- For more advanced validation scenarios, you can still use
  `<FlutterCupertinoFormRow>` with a custom input and manage validation in your
  application logic.
