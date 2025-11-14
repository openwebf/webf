# FlutterCupertinoActionSheet

## React.js

Use the generated React component to show an iOS-style action sheet from WebF and Flutter.
The component is controlled imperatively via a `ref` and a `show(options)` call.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoActionSheet } from 'your-react-bindings';
```

### Quick Start

```tsx
import { useRef } from 'react';

export function ActionSheetExample() {
  const sheetRef = useRef<any>(null);

  const openSheet = () => {
    sheetRef.current?.show({
      title: 'Choose an action',
      message: 'Select what you want to do',
      actions: [
        { text: 'Share', event: 'share' },
        { text: 'Edit', event: 'edit' },
        { text: 'Delete', event: 'delete', isDestructive: true },
      ],
      cancelButton: { text: 'Cancel', event: 'cancel', isDefault: true },
    });
  };

  return (
    <>
      <button onClick={openSheet}>Show Action Sheet</button>
      <FlutterCupertinoActionSheet
        ref={sheetRef}
        onSelect={(event) => {
          const detail = event.detail;
          console.log('selected action', detail.event, detail);
        }}
      />
    </>
  );
}
```

### Options

`show(options)` accepts:

- `title?: string` – optional title at the top.
- `message?: string` – optional message below the title.
- `actions?: { text: string; isDefault?: boolean; isDestructive?: boolean; event?: string }[]` –
  array of main actions.
- `cancelButton?: { text: string; isDefault?: boolean; isDestructive?: boolean; event?: string }` –
  optional cancel button shown separately at the bottom.

If `event` is omitted, a name is derived from the action text.

### Imperative API

```tsx
sheetRef.current?.show({
  title: 'More options',
  actions: [
    { text: 'Duplicate', event: 'duplicate' },
    { text: 'Delete', event: 'delete', isDestructive: true },
  ],
});
```

### Events

```tsx
<FlutterCupertinoActionSheet
  ref={sheetRef}
  onSelect={(event) => {
    const { text, event: name, isDefault, isDestructive, index } = event.detail;
    console.log({ text, name, isDefault, isDestructive, index });
  }}
/>
```

- `onSelect`: fired when any action (including the cancel button) is pressed.
- `event.detail` has:
  - `text`: action label.
  - `event`: event name.
  - `isDefault`: whether this action was marked default.
  - `isDestructive`: whether it was destructive.
  - `index?`: index in the `actions` array (if applicable).

### Styling

The sheet itself is rendered as a modal popup; the host element participates minimally in layout.
You can still attach `className`/`style` to the component to integrate with your layout or theming.

```tsx
<FlutterCupertinoActionSheet ref={sheetRef} className="hidden" />
```

### Notes

- The action sheet is shown via `CupertinoActionSheet` and dismissed automatically after a selection.
- If no `actions` and no `cancelButton` are provided, the sheet logs a warning and shows an empty sheet.
- Prefer stable `event` names in your configuration so you can switch on `event.detail.event` in handlers.

