# FlutterCupertinoListSection

## React.js

Use the generated React components to build grouped iOS-style lists powered by WebF and Flutter.

- `<FlutterCupertinoListSection>` – wraps a group of list rows.
- `<FlutterCupertinoListSectionHeader>` – optional header slot.
- `<FlutterCupertinoListSectionFooter>` – optional footer slot.

### Import

```tsx
// Replace the import path with where your generated components are exported from
import {
  FlutterCupertinoListSection,
  FlutterCupertinoListSectionHeader,
  FlutterCupertinoListSectionFooter,
} from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
export function ListSectionExample() {
  return (
    <FlutterCupertinoListSection insetGrouped>
      <FlutterCupertinoListSectionHeader>
        Settings
      </FlutterCupertinoListSectionHeader>

      {/* List rows go here (e.g., FlutterCupertinoListTile wrappers) */}
      {/* <FlutterCupertinoListTile>...</FlutterCupertinoListTile> */}

      <FlutterCupertinoListSectionFooter>
        Additional information
      </FlutterCupertinoListSectionFooter>
    </FlutterCupertinoListSection>
  );
}
```

### Props

```tsx
<FlutterCupertinoListSection insetGrouped>
  {/* header / rows / footer */}
</FlutterCupertinoListSection>
```

- `insetGrouped?: boolean` – when `true`, uses the inset grouped appearance (similar to iOS Settings).
  When `false`, uses the standard grouped style.

### Header & Footer Slots

```tsx
<FlutterCupertinoListSection insetGrouped>
  <FlutterCupertinoListSectionHeader>
    Profile
  </FlutterCupertinoListSectionHeader>

  {/* rows */}

  <FlutterCupertinoListSectionFooter>
    Last updated 5 minutes ago
  </FlutterCupertinoListSectionFooter>
</FlutterCupertinoListSection>
```

The header and footer components render their children into a `DIV` inside the section and are
treated specially by the section; they are not part of the main children list.

### Styling

The underlying `CupertinoListSection` reads some styles from the host element:

- `margin` – section margin; when `insetGrouped` is `true`, the default Flutter margin is used
  unless you provide a non-zero margin via CSS.
- `background-color` – background color for the list section.
- `border-radius`, `box-shadow`, etc. – may be taken from the `decoration` on the host element.

```tsx
<FlutterCupertinoListSection
  insetGrouped
  className="my-4"
  style={{ margin: '16px', backgroundColor: '#f9f9fb' }}
>
  {/* header / rows / footer */}
</FlutterCupertinoListSection>
```

### Notes

- Only the first `FlutterCupertinoListSectionHeader` and first
  `FlutterCupertinoListSectionFooter` child are used as header/footer; other instances are ignored.
- Non-header/footer element children become the section body (for example, list tiles).
- When no header or footer is provided, the section renders just the rows.***
