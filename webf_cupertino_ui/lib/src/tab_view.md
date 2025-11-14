# FlutterCupertinoTabView

## React.js

Provides an iOS‑style per‑tab Navigator. Use inside `FlutterCupertinoTabScaffoldTab` to give each tab its own navigation stack.

### Import

```tsx
import { FlutterCupertinoTabView } from 'your-react-bindings';
```

### Quick Start

```tsx
export function TabViewInScaffold() {
  return (
    <FlutterCupertinoTabScaffold currentIndex={0}>
      <FlutterCupertinoTabScaffoldTab title="Home">
        <FlutterCupertinoTabView defaultTitle="Home">
          <div style={{ padding: 16 }}>
            Home root content
          </div>
        </FlutterCupertinoTabView>
      </FlutterCupertinoTabScaffoldTab>

      <FlutterCupertinoTabScaffoldTab title="Settings">
        <FlutterCupertinoTabView defaultTitle="Settings">
          <div style={{ padding: 16 }}>
            Settings root content
          </div>
        </FlutterCupertinoTabView>
      </FlutterCupertinoTabScaffoldTab>
    </FlutterCupertinoTabScaffold>
  );
}
```

### Props

- defaultTitle?: string — default Navigator title for top route.
- restorationScopeId?: string — enables state restoration in this tab view.

### Notes

- When present inside a TabScaffold tab, it is used as the content for that tab, enabling an independent Navigator per tab.
- Without a TabView, the tab content is rendered directly without a dedicated Navigator.
