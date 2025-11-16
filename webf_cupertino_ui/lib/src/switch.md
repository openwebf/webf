# FlutterCupertinoSwitch

## React.js

Use the generated React component to render an iOS-style toggle switch powered by WebF and Flutter.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoSwitch } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
export function SwitchExample() {
  const [checked, setChecked] = useState(false);

  return (
    <FlutterCupertinoSwitch
      checked={checked}
      onChange={(event) => {
        const next = event.detail;
        setChecked(next);
      }}
    />
  );
}
```

### Props

```tsx
<FlutterCupertinoSwitch
  checked
  disabled={false}
  activeColor="#34C759"   // iOS green
  inactiveColor="#D1D1D6" // iOS gray
/>
```

- `checked?: boolean` – whether the switch is on.
- `disabled?: boolean` – disables user interaction.
- `activeColor?: string` – track color when `checked` is true (hex `#RRGGBB` / `#AARRGGBB`).
- `inactiveColor?: string` – track color when `checked` is false.

### Events

```tsx
<FlutterCupertinoSwitch
  checked={checked}
  onChange={(event) => {
    const isOn = event.detail; // boolean
    console.log('switch changed:', isOn);
  }}
/>
```

- `onChange`: fired whenever the user toggles the switch; `event.detail` is the new boolean value.

### Styling

Use `className` and `style` to position the switch in your layout.
Visual styling is mostly controlled by the Cupertino widget and the `activeColor`/`inactiveColor` props.

```tsx
<FlutterCupertinoSwitch
  checked
  style={{ transform: 'scale(0.9)' }}
/>
```

### Notes

- `checked` is mirrored into the underlying custom element and back into Flutter, so you can control it from React or let user interactions drive it and listen to `onChange`.
- When `disabled` is true, the switch becomes non-interactive and rendered with reduced opacity.

