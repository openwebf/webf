# FlutterCupertinoFormSection

## React.js

Use the generated React component to build iOS-style grouped form sections and rows using WebF and Flutter.
This component is a WebF counterpart to Flutter's `CupertinoFormSection` and `CupertinoFormRow`.

### Import

```tsx
// Replace the import path with where your generated component is exported from
import {
  FlutterCupertinoFormSection,
  FlutterCupertinoFormRow,
} from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
export function AccountSettingsSection() {
  return (
    <FlutterCupertinoFormSection insetGrouped>
      <span slotName="header">Account Settings</span>

      <FlutterCupertinoFormRow>
        <span slotName="prefix">Username</span>
        <input placeholder="Enter username" />
      </FlutterCupertinoFormRow>

      <FlutterCupertinoFormRow>
        <span slotName="prefix">Email</span>
        <input type="email" placeholder="Enter email" />
        <span slotName="helper">We will send a verification link.</span>
      </FlutterCupertinoFormRow>

      <FlutterCupertinoFormRow>
        <span slotName="prefix">Notifications</span>
        {/* Use any WebF-compatible control, e.g. FlutterCupertinoSwitch */}
        <flutter-cupertino-switch />
      </FlutterCupertinoFormRow>

      <span slotName="footer">These settings apply to your main account.</span>
    </FlutterCupertinoFormSection>
  );
}
```

### Props

```tsx
<FlutterCupertinoFormSection
  insetGrouped
  clipBehavior="hardEdge"  // 'none' | 'hardEdge' | 'antiAlias' | 'antiAliasWithSaveLayer'
>
  {/* header, rows, footer */}
</FlutterCupertinoFormSection>
```

- `insetGrouped?: boolean` – when true, uses the inset grouped style (`CupertinoFormSection.insetGrouped`).
- `clipBehavior?: string` – maps to Flutter `Clip` enum (`'none' | 'hardEdge' | 'antiAlias' | 'antiAliasWithSaveLayer'`).

`FlutterCupertinoFormRow` has no dedicated props; its behavior is driven by its children and slots.

### Slots

`FlutterCupertinoFormSection` recognizes:
- `slotName="header"` – section header content.
- `slotName="footer"` – section footer content.
- default slot – one or more `FlutterCupertinoFormRow` children.

`FlutterCupertinoFormRow` recognizes:
- `slotName="prefix"` – leading label.
- `slotName="helper"` – helper text under the row.
- `slotName="error"` – error text under the row.
- default slot – main control/content (input, switch, etc.).

Example:

```tsx
<FlutterCupertinoFormRow>
  <span slotName="prefix">Language</span>
  <span>English</span>
</FlutterCupertinoFormRow>
```

### Styling

The section and rows follow native Cupertino styling. You can override via `style` / `className` on the React components or on inner elements:

```tsx
<FlutterCupertinoFormSection
  insetGrouped
  style={{
    marginTop: 20,
    marginLeft: 10,
    marginRight: 10,
    backgroundColor: '#e0f7fa',
    borderRadius: 15,
  }}
>
  <span
    slotName="header"
    style={{ color: '#00796b', fontWeight: 'bold', paddingLeft: 16 }}
  >
    Custom Style Section
  </span>

  <FlutterCupertinoFormRow style={{ paddingLeft: 16, paddingRight: 16 }}>
    <span slotName="prefix">Item 1</span>
    <span>Value 1</span>
  </FlutterCupertinoFormRow>
</FlutterCupertinoFormSection>
```

### Notes

- This component replaces direct uses of `CupertinoFormSection` / `CupertinoFormRow` in Flutter UI code by providing WebF custom elements that map to those widgets.
- Layout (margins, background color, radius) is still primarily managed by Flutter; use CSS props to tweak margins and background as needed.
- Rows are simple containers; they are expected to host interactive WebF/Flutter controls inside rather than emit their own events.

