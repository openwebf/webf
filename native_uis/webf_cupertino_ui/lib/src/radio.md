# FlutterCupertinoRadio

## React.js

Use the generated React component to render a macOS-style radio button powered by WebF and Flutter.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoRadio } from 'your-react-bindings';
```

### Quick Start

```tsx
type Option = 'one' | 'two';

export function RadioExample() {
  const [value, setValue] = useState<Option | ''>('one');

  return (
    <>
      <FlutterCupertinoRadio
        val="one"
        groupValue={value}
        onChange={(event) => {
          setValue(event.detail as Option | '');
        }}
      />
      <FlutterCupertinoRadio
        val="two"
        groupValue={value}
        onChange={(event) => {
          setValue(event.detail as Option | '');
        }}
      />
    </>
  );
}
```

### Props

```tsx
<FlutterCupertinoRadio
  val="one"
  groupValue={current}
  disabled={false}
  toggleable={false}
  useCheckmarkStyle={false}
  activeColor="#0A84FF"
  inactiveColor="#FFFFFF"
  fillColor="#FFFFFF"
  focusColor="rgba(10,132,255,0.3)"
  autofocus={false}
/>
```

- `val?: string` – value represented by this radio; when it equals `groupValue`, the radio is selected.
- `groupValue?: string` – current group value; controls which radio is selected.
- `disabled?: boolean` – when true, the radio is non-interactive and dimmed.
- `toggleable?: boolean` – when true, tapping an already selected radio can clear the selection.
- `useCheckmarkStyle?: boolean` – when true, renders in a checkmark style instead of the default radio UI.
- `activeColor?: string` – color when selected.
- `inactiveColor?: string` – color when not selected.
- `fillColor?: string` – inner fill color when selected.
- `focusColor?: string` – focus highlight color.
- `autofocus?: boolean` – when true, this radio requests focus automatically.

All color props accept any CSS color supported by WebF (hex, `rgb`, `rgba`, named colors, etc.).

### Events

```tsx
<FlutterCupertinoRadio
  val="one"
  groupValue={value}
  toggleable
  onChange={(event) => {
    // When toggleable is true and the radio is deselected,
    // event.detail will be the empty string ''.
    const next = event.detail;
    setValue(next || '');
  }}
/>
```

- `onChange`: fired whenever the selection for this radio changes; `event.detail` is the new group value (string), or `''` (empty string) when `toggleable` is true and the selection is cleared.

### Styling

The radio itself is layout-neutral. Use `className`/`style` on the wrapper for spacing and layout:

```tsx
<FlutterCupertinoRadio
  className="mr-2"
  style={{ marginTop: 4 }}
  val="one"
  groupValue={value}
  onChange={(e) => setValue(e.detail)}
/>
```

### Notes

- Radios work in groups by sharing the same `groupValue`. Only the radio whose `val` matches `groupValue` will appear selected.
- When `toggleable` is `true`, tapping a selected radio can clear the selection; use `event.detail === ''` in `onChange` to detect this case.
