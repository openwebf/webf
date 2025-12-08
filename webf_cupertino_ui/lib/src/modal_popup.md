# FlutterCupertinoModalPopup

## React.js

Use the generated React component to show an iOS-style modal popup from WebF and Flutter.
The component is controlled imperatively via a `ref` with `show()` / `hide()`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import { FlutterCupertinoModalPopup } from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
import { useRef } from 'react';

export function ModalPopupExample() {
  const popupRef = useRef<any>(null);

  const openPopup = () => {
    popupRef.current?.show();
  };

  const closePopup = () => {
    popupRef.current?.hide();
  };

  return (
    <>
      <button onClick={openPopup}>Show Popup</button>

      <FlutterCupertinoModalPopup
        ref={popupRef}
        height={250}
        onClose={() => console.log('popup closed')}
      >
        <div className="popup-content">
          <div className="popup-title">Modal Popup</div>
          <div className="popup-text">
            This content is rendered inside a Cupertino-style bottom sheet.
          </div>
          <button onClick={closePopup}>Close</button>
        </div>
      </FlutterCupertinoModalPopup>
    </>
  );
}
```

### Props

```tsx
<FlutterCupertinoModalPopup
  ref={popupRef}
  height={300}
  maskClosable={false}
  surfacePainted
  backgroundOpacity={0.6}
/>
```

- `visible?: boolean` – controls whether the popup is visible (usually via `show()` / `hide()` instead of direct binding).
- `height?: number` – fixed height of the popup content in logical pixels. If omitted, height is driven by content.
- `surfacePainted?: boolean` – whether the popup surface uses Cupertino background styling. Default: `true`.
- `maskClosable?: boolean` – when `true`, tapping the background mask dismisses the popup. Default: `true`.
- `backgroundOpacity?: number` – opacity of the background mask (0.0–1.0). Default: `0.4`.

### Imperative API

```tsx
// Show the popup
popupRef.current?.show();

// Hide the popup
popupRef.current?.hide();
```

This mirrors Flutter's `showCupertinoModalPopup` pattern but exposes it as an imperative method on the WebF custom element.

### Events

```tsx
<FlutterCupertinoModalPopup
  ref={popupRef}
  onClose={(event) => {
    // event is CustomEvent<void>
    console.log('popup closed', event);
  }}
>
  {/* content */}
</FlutterCupertinoModalPopup>
```

- `onClose`: fired whenever the popup is dismissed, whether by:
  - mask tap (when `maskClosable` is `true`),
  - calling `hide()`,
  - or system back gesture.

### Styling

The popup content is rendered from the component's children. Use `className` / `style` on your inner elements to control layout and appearance.
The host `<FlutterCupertinoModalPopup>` itself participates minimally in layout; it only manages the modal route.

```tsx
<FlutterCupertinoModalPopup ref={popupRef} height={250}>
  <div className="popup-content custom-style">
    {/* custom layout */}
  </div>
</FlutterCupertinoModalPopup>
```

### Notes

- This component is the WebF counterpart to Flutter's `showCupertinoModalPopup`, exposing a declarative container plus imperative `show()` / `hide()` API.
- Prefer method-based control (`show()` / `hide()`) instead of directly binding `visible` unless you need a fully controlled React state pattern.
- For picker-style flows (date picker, custom pickers), nest the picker components as children of `FlutterCupertinoModalPopup`.

