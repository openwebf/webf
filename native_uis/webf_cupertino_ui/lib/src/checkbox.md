# FlutterCupertinoCheckbox

## React.js

Use the generated React component to render an iOS-style checkbox powered by WebF and Flutter.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoCheckbox } from 'your-react-bindings';
```

### Quick Start

```tsx
export function CheckboxExample() {
  const [checked, setChecked] = useState(false);

  return (
    <FlutterCupertinoCheckbox
      checked={checked}
      onChange={(event) => {
        setChecked(event.detail);
      }}
    />
  );
}
```

### Props

```tsx
<FlutterCupertinoCheckbox
  checked
  disabled={false}
  tristate={false}
  activeColor="#0A84FF"
  checkColor="#FFFFFF"
  focusColor="rgba(10,132,255,0.3)"
  fillColorSelected="#0A84FF"
  fillColorDisabled="#D1D1D6"
  autofocus={false}
  semanticLabel="Accept terms"
/>
```

- `checked?: boolean` – current checked state (default `false`).
- `disabled?: boolean` – disables interaction when `true`.
- `tristate?: boolean` – enables three-state behavior (`false → true → null → false`).
- `activeColor?: string` – checkbox color when selected.
- `checkColor?: string` – color of the check icon.
- `focusColor?: string` – focus highlight color.
- `fillColorSelected?: string` – fill color when selected.
- `fillColorDisabled?: string` – fill color when disabled.
- `autofocus?: boolean` – when `true`, this checkbox requests focus automatically.
- `semanticLabel?: string` – accessibility label announced by screen readers.

All color props accept any CSS color supported by WebF (hex, `rgb`, `rgba`, named colors, etc.).

### Events

```tsx
<FlutterCupertinoCheckbox
  onChange={(event) => {
    console.log('checked:', event.detail);
  }}
  onStatechange={(event) => {
    // 'checked' | 'unchecked' | 'mixed'
    console.log('state:', event.detail);
  }}
/>
```

- `onChange`: fired whenever the checked state changes; `event.detail` is a `boolean`.
- `onStatechange`: fired on every change, including tristate transitions; `event.detail` is `'checked' | 'unchecked' | 'mixed'`.

### Styling

The checkbox itself is layout-neutral. Use `className`/`style` on the wrapper for spacing and layout:

```tsx
<FlutterCupertinoCheckbox
  className="ml-3"
  style={{ marginTop: 8 }}
  checked={checked}
  onChange={(e) => setChecked(e.detail)}
/>
```

### Notes

- When `disabled` is `true`, the checkbox is non-interactive and rendered with reduced opacity.
- `fillColorDisabled` and `fillColorSelected` provide fine-grained control of the background fill; if omitted, sensible Cupertino defaults are used.
- When `tristate` is `true`, use `onStatechange` and check for `event.detail === 'mixed'` to detect the mixed state reliably instead of relying on `null`.
