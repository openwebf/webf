# FlutterCupertinoTabScaffold

## React.js

Use the generated React components to render an iOS‑style tab scaffold with a bottom tab bar and tabbed content. Props are React‑friendly (camelCase) and mapped to the underlying WebF custom elements.

### Import

```tsx
// Replace the import path with where your generated components are exported from
import {
  FlutterCupertinoTabScaffold,
  FlutterCupertinoTabScaffoldTab,
  FlutterCupertinoIcon,
} from 'your-react-bindings';
```

### Quick Start

```tsx
export function Example() {
  return (
    <FlutterCupertinoTabScaffold currentIndex={0}>
      <FlutterCupertinoTabScaffoldTab title="Home">
        <FlutterCupertinoIcon type="home" />
        <div style={{ padding: 16 }}>Home content</div>
      </FlutterCupertinoTabScaffoldTab>

      <FlutterCupertinoTabScaffoldTab title="Settings">
        <FlutterCupertinoIcon type="settings" />
        <div style={{ padding: 16 }}>Settings content</div>
      </FlutterCupertinoTabScaffoldTab>
    </FlutterCupertinoTabScaffold>
  );
}
```

### With TabBar

You can combine TabScaffold with a nested TabBar to configure bar items and styling (colors, icon size, border). The TabBar acts as configuration; TabScaffold renders the actual bar and keeps selection state.

```tsx
export function WithBar() {
  return (
    <FlutterCupertinoTabScaffold currentIndex={0}>
      {/* TabBar used for items and appearance */}
      <FlutterCupertinoTabBar
        backgroundColor="#FFFFFFFF"
        activeColor="#007AFF"
        inactiveColor="#8E8E93"
        iconSize={28}
      >
        <FlutterCupertinoTabBarItem title="Home">
          <FlutterCupertinoIcon type="home" />
        </FlutterCupertinoTabBarItem>
        <FlutterCupertinoTabBarItem title="Settings">
          <FlutterCupertinoIcon type="settings" />
        </FlutterCupertinoTabBarItem>
      </FlutterCupertinoTabBar>

      {/* Content tabs; must match item order */}
      <FlutterCupertinoTabScaffoldTab title="Home">
        <div style={{ padding: 16 }}>Home content</div>
      </FlutterCupertinoTabScaffoldTab>
      <FlutterCupertinoTabScaffoldTab title="Settings">
        <div style={{ padding: 16 }}>Settings content</div>
      </FlutterCupertinoTabScaffoldTab>
    </FlutterCupertinoTabScaffold>
  );
}
```

### Props

- currentIndex?: number — zero‑based active tab index.
- resizeToAvoidBottomInset?: boolean — reserved for parity; currently not functionally different.

Tab item props:
- title?: string — label rendered in the tab bar.

### Events

```tsx
<FlutterCupertinoTabScaffold
  onChange={(e) => {
    // Active tab index in e.detail
    console.log('tab changed:', e.detail);
  }}
>
  {/* tabs... */}
  <FlutterCupertinoTabScaffoldTab title="Tab">
    <div>Content</div>
  </FlutterCupertinoTabScaffoldTab>
  {/* ... */}
</FlutterCupertinoTabScaffold>
```

### Icons

- Place a `FlutterCupertinoIcon` as a child of a `FlutterCupertinoTabScaffoldTab` to use as the tab icon.
- If no icon is provided, a placeholder is used.

```tsx
<FlutterCupertinoTabScaffoldTab title="Profile">
  <FlutterCupertinoIcon type="person" />
  <div>Profile page</div>
</FlutterCupertinoTabScaffoldTab>
```

### Styling

- Apply `className`/`style` to the scaffold for layout. The content area expands to fill available height, with the tab bar pinned to the bottom.
- Style the inner content using standard CSS.

```tsx
<FlutterCupertinoTabScaffold style={{ height: 500 }}>
  {/* tabs */}
</FlutterCupertinoTabScaffold>
```

### Notes

- Uses an IndexedStack to keep off‑screen tabs alive (stateful content persists).
- Does not create a separate Navigator per tab (unlike a full CupertinoTabView setup). If you need per‑tab navigation stacks, let us know and we can extend the component.
- Event `change` maps to `onChange` in React and carries the active index in `event.detail`.
- When a nested TabBar is present, TabScaffold reads its items and appearance but renders the bar itself. Keep the number/order of `TabScaffoldTab` in sync with `TabBarItem`s.
