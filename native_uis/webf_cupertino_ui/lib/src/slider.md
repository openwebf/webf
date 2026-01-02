# FlutterCupertinoSlider

## React.js

Use the generated React component to render an iOS-style slider powered by WebF and Flutter.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoSlider } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
export function SliderExample() {
  const [value, setValue] = useState(50);

  return (
    <FlutterCupertinoSlider
      val={value}
      min={0}
      max={100}
      onChange={(event) => {
        const next = event.detail;
        setValue(next);
      }}
    />
  );
}
```

### Props

```tsx
<FlutterCupertinoSlider
  val={42}
  min={0}
  max={100}
  step={10}
  disabled={false}
/>
```

- `val?: number` – current slider value.
- `min?: number` – minimum value (default `0`).
- `max?: number` – maximum value (default `100`).
- `step?: number` – number of discrete divisions; omit for a continuous slider.
- `disabled?: boolean` – disables interaction when true.

### Events

```tsx
<FlutterCupertinoSlider
  val={value}
  onChange={(event) => {
    console.log('value changed', event.detail);
  }}
  onChangestart={(event) => {
    console.log('interaction start', event.detail);
  }}
  onChangeend={(event) => {
    console.log('interaction end', event.detail);
  }}
/>
```

- `onChange`: fired whenever the value changes; `event.detail` is the new `number` value.
- `onChangestart`: fired when the user starts dragging.
- `onChangeend`: fired when the user releases the thumb.

### Imperative Methods

If you prefer, you can call the underlying methods via a `ref`:

```tsx
const sliderRef = useRef<any>(null);

sliderRef.current?.setValue(75);
const current = sliderRef.current?.getValue();
```

### Styling

The slider uses native Cupertino styling. Use `className`/`style` on the wrapper for layout:

```tsx
<FlutterCupertinoSlider
  val={value}
  style={{ width: 240 }}
/>
```

### Notes

- `val`, `min`, and `max` are clamped appropriately so `val` always stays within `[min, max]`.
- When `step` is provided, the slider uses discrete divisions between `min` and `max`.
- When `disabled` is true, the slider becomes non-interactive.

