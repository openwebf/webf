# FlutterCupertinoTabBar

## React.js

A bottom navigation bar for iOS‑style apps. Use items as children to define labels and icons.

### Import

```tsx
// Replace with your generated bindings entry
import {
  FlutterCupertinoTabBar,
  FlutterCupertinoTabBarItem,
  FlutterCupertinoIcon,
} from 'your-react-bindings';
```

### Quick Start

```tsx
export function TabBarExample() {
  return (
    <FlutterCupertinoTabBar currentIndex={0}>
      <FlutterCupertinoTabBarItem title="Home">
        <FlutterCupertinoIcon type="home" />
      </FlutterCupertinoTabBarItem>
      <FlutterCupertinoTabBarItem title="Settings">
        <FlutterCupertinoIcon type="settings" />
      </FlutterCupertinoTabBarItem>
    </FlutterCupertinoTabBar>
  );
}
```

### Props

- currentIndex?: number — active tab index.
- backgroundColor?: string — hex `#RRGGBB` or `#AARRGGBB`.
- activeColor?: string — hex color for active item.
- inactiveColor?: string — hex color for inactive items.
- iconSize?: number — icon size in px.
- noTopBorder?: boolean — when true, removes the top border.

Item props:
- title?: string — label below the icon.

### Events

```tsx
<FlutterCupertinoTabBar onChange={(e) => console.log('index:', e.detail)}>
  {/* items */}
</FlutterCupertinoTabBar>
```

### Icons

Provide a `FlutterCupertinoIcon` inside each item for the icon.

```tsx
<FlutterCupertinoTabBarItem title="Chat">
  <FlutterCupertinoIcon type="chat_bubble" />
  {/* Additional content or wrappers are ignored by the TabBar and not rendered */}
</FlutterCupertinoTabBarItem>
```

### Notes

- Emits `change` (→ React `onChange`) with the selected index via `event.detail`.
- Works standalone or embedded in a custom layout; TabScaffold also includes an internal bar if you prefer an all‑in‑one component.
