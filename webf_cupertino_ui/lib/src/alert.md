# FlutterCupertinoAlert

## React.js

Use the generated React component to show a Cupertino-style alert dialog powered by WebF and Flutter.
The component is controlled imperatively via a `ref`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoAlert } from 'your-react-bindings';
```

### Quick Start

```tsx
import { useRef } from 'react';

export function AlertExample() {
  const alertRef = useRef<any>(null);

  const openAlert = () => {
    alertRef.current?.show({
      title: 'Delete item?',
      message: 'This action cannot be undone.',
    });
  };

  return (
    <>
      <button onClick={openAlert}>Show Alert</button>
      <FlutterCupertinoAlert
        ref={alertRef}
        onCancel={() => console.log('cancel')}
        onConfirm={() => console.log('confirm')}
      />
    </>
  );
}
```

### Props

```tsx
<FlutterCupertinoAlert
  title="Title from props"
  message="Message from props"
  cancelText="Cancel"
  cancelDefault
  cancelDestructive
  confirmText="Delete"
  confirmDefault
  confirmDestructive
/>
```

- `title`, `message`: default title and message when `show()` is called without overrides.
- `cancelText`: label for the cancel button; if omitted or empty, no cancel button is rendered.
- `cancelDefault`, `cancelDestructive`: mark the cancel button as default or destructive.
- `confirmText`: label for the confirm button (defaults to a localized "OK").
- `confirmDefault`, `confirmDestructive`: mark the confirm button as default or destructive.

### Imperative API

```tsx
alertRef.current?.show({
  title: 'Override title',
  message: 'Override message for this call only',
});

alertRef.current?.hide();
```

- `show(options?)`: opens the dialog. `options.title` and `options.message` override the props for that call.
- `hide()`: programmatically closes the dialog if visible.

### Events

```tsx
<FlutterCupertinoAlert
  ref={alertRef}
  onCancel={(event) => {
    // event is CustomEvent<void>
    console.log('user cancelled', event);
  }}
  onConfirm={(event) => {
    console.log('user confirmed', event);
  }}
/>
```

- `onCancel`: fired when the cancel button is pressed.
- `onConfirm`: fired when the confirm button is pressed.

### Styling

The alert dialog itself follows native Cupertino styling. Use `className` or `style` on the
`FlutterCupertinoAlert` component to style the underlying custom element if needed (for example,
to participate in layout or theming wrappers).

```tsx
<FlutterCupertinoAlert
  ref={alertRef}
  className="hidden" // keep the host out of visual flow if desired
/>
```

### Notes

- Per-call `show({ title, message })` overrides the default `title`/`message` props only for that invocation.
- If `cancelText` is not provided, only the confirm button is shown.
- `confirmDefault` defaults to `true` to match typical iOS alert behavior.

