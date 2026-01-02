# FlutterCupertinoListTile

## React.js

Use the generated React components to build iOS-style list rows inside `FlutterCupertinoListSection`.

- `<FlutterCupertinoListTile>` – main row container.
- `<FlutterCupertinoListTileLeading>` – optional leading icon/avatar.
- `<FlutterCupertinoListTileSubtitle>` – secondary text below the title.
- `<FlutterCupertinoListTileAdditionalInfo>` – right-aligned secondary label.
- `<FlutterCupertinoListTileTrailing>` – custom trailing widget (switch, badge, etc.).

### Import

```tsx
// Replace the import path with where your generated components are exported from
import {
  FlutterCupertinoListTile,
  FlutterCupertinoListTileLeading,
  FlutterCupertinoListTileSubtitle,
  FlutterCupertinoListTileAdditionalInfo,
  FlutterCupertinoListTileTrailing,
} from '@openwebf/react-cupertino-ui';
```

### Quick Start

```tsx
<FlutterCupertinoListTile showChevron="true">
  Wi‑Fi
  <FlutterCupertinoListTileAdditionalInfo>
    HomeNetwork
  </FlutterCupertinoListTileAdditionalInfo>
</FlutterCupertinoListTile>
```

### With Slots

```tsx
<FlutterCupertinoListTile showChevron="true">
  <FlutterCupertinoListTileLeading>
    <div className="w-8 h-8 rounded-full bg-blue-500" />
  </FlutterCupertinoListTileLeading>
  Notifications
  <FlutterCupertinoListTileSubtitle>
    Push, email, and SMS notifications
  </FlutterCupertinoListTileSubtitle>
  <FlutterCupertinoListTileAdditionalInfo>
    On
  </FlutterCupertinoListTileAdditionalInfo>
</FlutterCupertinoListTile>
```

### Props

```tsx
<FlutterCupertinoListTile
  showChevron="true"
  // notched // optional "notched" visual style
  onClick={(event) => { /* handle tap */ }}
>
  Title
</FlutterCupertinoListTile>
```

- `showChevron?: boolean` – when `true`, shows an iOS-style chevron on the trailing edge if no custom trailing slot is provided.
- `notched?: boolean` – when `true`, uses the notched visual style similar to iOS Messages and Contacts.
- `onClick?: (event: Event) => void` – fired when the tile is tapped.

### Slot Components

- `FlutterCupertinoListTileLeading` – leading icon/avatar.
- `FlutterCupertinoListTileSubtitle` – text below the main title.
- `FlutterCupertinoListTileAdditionalInfo` – right-aligned secondary label.
- `FlutterCupertinoListTileTrailing` – custom trailing widget, replaces the default chevron.
