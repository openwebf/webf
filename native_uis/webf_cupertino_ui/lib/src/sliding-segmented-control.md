# FlutterCupertinoSlidingSegmentedControl

## React.js

Use the generated React component to render an iOS-style sliding segmented control powered by WebF and Flutter.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import {
  FlutterCupertinoSlidingSegmentedControl,
  FlutterCupertinoSlidingSegmentedControlItem,
} from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
export function SlidingSegmentedControlExample() {
  const [index, setIndex] = useState(0);

  return (
    <FlutterCupertinoSlidingSegmentedControl
      currentIndex={index}
      onChange={(event) => {
        setIndex(event.detail);
      }}
    >
      <FlutterCupertinoSlidingSegmentedControlItem title="First" />
      <FlutterCupertinoSlidingSegmentedControlItem title="Second" />
      <FlutterCupertinoSlidingSegmentedControlItem title="Third" />
    </FlutterCupertinoSlidingSegmentedControl>
  );
}
```

### Props

```tsx
<FlutterCupertinoSlidingSegmentedControl
  currentIndex={0}
  backgroundColor="#F2F2F2"
  thumbColor="#FFFFFF"
>
  <FlutterCupertinoSlidingSegmentedControlItem title="One" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Two" />
</FlutterCupertinoSlidingSegmentedControl>
```

- `currentIndex?: number` – zero-based index of the selected segment (default `0`).
- `backgroundColor?: string` – track background color (`#RRGGBB` or `#AARRGGBB`).
- `thumbColor?: string` – sliding thumb color (`#RRGGBB` or `#AARRGGBB`).

Item props:
- `title?: string` – label shown for this segment.

### Events

```tsx
<FlutterCupertinoSlidingSegmentedControl
  onChange={(event) => {
    console.log('selected index', event.detail);
  }}
>
  {/* items */}
</FlutterCupertinoSlidingSegmentedControl>
```

- `onChange`: fired whenever the selected segment changes; `event.detail` is the selected index.

### Styling

The control itself is layout-neutral. Use `className`/`style` on the wrapper to control width and placement:

```tsx
<FlutterCupertinoSlidingSegmentedControl
  className="w-full max-w-xs"
  style={{ margin: '16px auto' }}
>
  <FlutterCupertinoSlidingSegmentedControlItem title="Left" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Right" />
</FlutterCupertinoSlidingSegmentedControl>
```

### Notes

- Only the control is rendered; it does not manage or display tab content. Use the selected index to swap your own views.
- When `currentIndex` is outside the valid range, it is clamped to the available items.
- If no items are provided, the control renders in an inert state with no selection.

