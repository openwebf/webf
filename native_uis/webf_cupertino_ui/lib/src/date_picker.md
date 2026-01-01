# FlutterCupertinoDatePicker

## React.js

Use the generated React component to render an iOS-style date & time picker
backed by `CupertinoDatePicker`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoDatePicker } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
import { useState } from 'react';

export function DatePickerExample() {
  const [value, setValue] = useState<string | null>(null);

  return (
    <div>
      <FlutterCupertinoDatePicker
        mode="dateAndTime"
        value={value ?? new Date().toISOString()}
        onChange={(event) => setValue(event.detail)}
      />
      <div className="mt-2 text-sm text-gray-700">
        Selected: <code>{value ?? '(none)'}</code>
      </div>
    </div>
  );
}
```

### Props

```tsx
<FlutterCupertinoDatePicker
  mode="dateAndTime"  // 'time' | 'date' | 'dateAndTime' | 'monthYear'
  minimumDate="2024-01-01T00:00:00.000Z"
  maximumDate="2025-12-31T23:59:59.000Z"
  minimumYear={2000}
  maximumYear={2030}
  minuteInterval={5}
  use24H
  showDayOfWeek
  value={currentIsoString}
/>
```

- `mode?: string` – picker mode: `'time' | 'date' | 'dateAndTime' | 'monthYear'` (default: `'dateAndTime'`).
- `minimumDate?: string` – earliest selectable date/time (ISO8601 string).
- `maximumDate?: string` – latest selectable date/time (ISO8601 string).
- `minimumYear?: number` – minimum year for `date`/`monthYear` modes (default: `1`).
- `maximumYear?: number` – maximum year for `date`/`monthYear` modes.
- `minuteInterval?: number` – minute step (must divide 60, default: `1`).
- `use24H?: boolean` – use 24‑hour time display.
- `showDayOfWeek?: boolean` – show day of week in `date` mode.
- `value?: string` – current value as ISO8601 string (`Date.toISOString()` is recommended).

### Events

```tsx
<FlutterCupertinoDatePicker
  onChange={(event) => {
    // event.detail is an ISO8601 DateTime string
    console.log('change', event.detail);
  }}
/>
```

- `onChange`: fired whenever the selected date/time changes according to the underlying picker behavior; `event.detail` is the ISO8601 string.

### Imperative API

```tsx
const pickerRef = useRef<any>(null);

// Set the current value programmatically
pickerRef.current?.setValue(new Date(2025, 0, 1).toISOString());
```

Attach the ref:

```tsx
<FlutterCupertinoDatePicker ref={pickerRef} />
```

### Styling

The picker respects standard sizing via the host element:

- `width` / `height` – control the overall picker size; if omitted, it uses its intrinsic Cupertino height.

Example:

```tsx
<FlutterCupertinoDatePicker
  mode="date"
  style={{
    height: 220,
  }}
/>
```

### Notes

- This component migrates Flutter’s `CupertinoDatePicker` into a WebF custom element with ISO8601 string values.
- For time‑only pickers, use `mode="time"` and parse `event.detail` in your app logic. 

