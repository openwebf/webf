# FlutterCupertinoContextMenu

## React.js

Use the generated React component to wrap content with a Cupertino-style context menu.
Actions are configured via the `setActions(actions)` method, and the first child becomes the preview/trigger.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoContextMenu } from 'your-react-bindings';
```

### Quick Start

```tsx
import { useEffect, useRef } from 'react';

export function ContextMenuExample() {
  const menuRef = useRef<any>(null);

  useEffect(() => {
    menuRef.current?.setActions([
      { text: 'Share', icon: 'share', event: 'share' },
      { text: 'Favorite', icon: 'heart', event: 'favorite' },
      { text: 'Delete', icon: 'delete', event: 'delete', destructive: true },
    ]);
  }, []);

  return (
    <FlutterCupertinoContextMenu
      ref={menuRef}
      enableHapticFeedback
      onSelect={(event) => {
        const detail = event.detail;
        console.log('context menu select', detail.event, detail);
      }}
    >
      <div style={{ width: 120, height: 120, background: '#eee', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        Long press me
      </div>
    </FlutterCupertinoContextMenu>
  );
}
```

### Props

```tsx
<FlutterCupertinoContextMenu enableHapticFeedback>
  {/* preview content */}
</FlutterCupertinoContextMenu>
```

- `enableHapticFeedback?: boolean` – enables haptic feedback when the menu opens (iOS only).

### Methods

```tsx
menuRef.current?.setActions([
  { text: 'Share', icon: 'share', event: 'share' },
  { text: 'Favorite', icon: 'heart', event: 'favorite' },
]);
```

Each action has:

- `text: string` – visible label.
- `icon?: string` – Cupertino icon key (resolved via the shared icon map).
- `destructive?: boolean` – marks the action as destructive.
- `default?: boolean` – marks the action as the default/highlighted action.
- `event?: string` – event name used in `event.detail.event`.

### Events

```tsx
<FlutterCupertinoContextMenu
  ref={menuRef}
  onSelect={(event) => {
    const { index, text, event: name, destructive, default: isDefault } = event.detail;
    console.log({ index, text, name, destructive, isDefault });
  }}
>
  {/* preview content */}
</FlutterCupertinoContextMenu>
```

- `onSelect`: fired when an action is tapped.
- `event.detail` contains:
  - `index`: index of the action in the configured `actions` array.
  - `text`: action label.
  - `event`: event name.
  - `destructive`: whether the action was destructive.
  - `default`: whether it was the default action.

### Styling

The preview area is your children. Use standard `className`/`style` to shape the preview content.
The context menu wraps that child and handles long-press behavior.

```tsx
<FlutterCupertinoContextMenu ref={menuRef}>
  <img src="..." className="rounded-xl shadow" />
</FlutterCupertinoContextMenu>
```

### Notes

- Only the first element child is used as the preview widget.
- If no actions are configured, the menu behaves like a plain container and does not show a context menu.
- Icons are resolved via the same `kCupertinoIconMap` used by `<FlutterCupertinoIcon>`, so you can reuse icon keys consistently.

