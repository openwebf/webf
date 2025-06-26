# @openwebf/webf-react-core-ui

Core UI components for building React applications with WebF.

## Installation

```bash
npm install @openwebf/webf-react-core-ui
```

## Components

### WebFListView

A scrollable list view component with pull-to-refresh and infinite scrolling capabilities. This component renders as a custom HTML element (`<webf-listview>`) that is handled by the WebF framework.

#### Features
- Vertical or horizontal scrolling
- Pull-to-refresh functionality
- Infinite scrolling with load-more capabilities
- Proper handling of absolute/fixed positioned children
- Automatic timeout handling (4 seconds) for refresh and load operations

#### Usage

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/webf-react-core-ui';
import { useRef } from 'react';

function MyList() {
  const listRef = useRef<WebFListViewElement>(null);
  const [items, setItems] = useState([1, 2, 3, 4, 5]);

  const handleRefresh = async () => {
    // Fetch new data
    await fetchNewData();
    
    // Call finishRefresh when done
    listRef.current?.finishRefresh('success');
  };

  const handleLoadMore = async () => {
    // Load more data
    const hasMore = await loadMoreData();
    
    // Call finishLoad with appropriate result
    listRef.current?.finishLoad(hasMore ? 'success' : 'noMore');
  };

  return (
    <WebFListView
      ref={listRef}
      onRefresh={handleRefresh}
      onLoadMore={handleLoadMore}
      scrollDirection="vertical"
      shrinkWrap={true}
    >
      {items.map(item => (
        <div key={item}>Item {item}</div>
      ))}
    </WebFListView>
  );
}
```

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| scrollDirection | `'vertical' \| 'horizontal'` | `'vertical'` | The scroll direction for the list |
| shrinkWrap | `boolean` | `true` | Whether the list should shrink-wrap its contents |
| onRefresh | `() => void \| Promise<void>` | - | Callback triggered when pull-to-refresh is activated |
| onLoadMore | `() => void \| Promise<void>` | - | Callback triggered when scrolling near the end |
| className | `string` | - | Additional CSS class names |
| style | `React.CSSProperties` | - | Inline styles |

#### Ref Methods

The ref provides access to the WebFListViewElement which extends HTMLElement with these additional methods:

| Method | Signature | Description |
|--------|-----------|-------------|
| finishRefresh | `(result?: 'success' \| 'fail' \| 'noMore') => void` | Completes a refresh operation |
| finishLoad | `(result?: 'success' \| 'fail' \| 'noMore') => void` | Completes a load-more operation |
| resetHeader | `() => void` | Resets the refresh header to initial state |
| resetFooter | `() => void` | Resets the load-more footer to initial state |

### WebFTouchArea

A component that provides enhanced touch handling with support for tap and long press gestures.

#### Usage

```tsx
import { WebFTouchArea } from '@openwebf/webf-react-core-ui';

function MyComponent() {
  return (
    <WebFTouchArea
      onTap={() => console.log('Tapped')}
      onLongPress={() => console.log('Long pressed')}
      longPressDelay={800}
    >
      <div>Touch me!</div>
    </WebFTouchArea>
  );
}
```

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| onTouchStart | `(event: TouchEvent) => void` | - | Called when touch starts |
| onTouchEnd | `(event: TouchEvent) => void` | - | Called when touch ends |
| onTouchCancel | `(event: TouchEvent) => void` | - | Called when touch is cancelled |
| onTouchMove | `(event: TouchEvent) => void` | - | Called when touch moves |
| onTap | `() => void` | - | Called when tapped/clicked |
| onLongPress | `() => void` | - | Called when long pressed |
| longPressDelay | `number` | `500` | Duration in ms to trigger long press |
| className | `string` | - | Additional CSS class names |
| style | `React.CSSProperties` | - | Inline styles |

### WebF Shimmer Components

WebF provides native Flutter shimmer effects through custom elements. These React components wrap the native WebF shimmer elements.

#### Usage

```tsx
import { WebFShimmer, WebFShimmerText, WebFShimmerAvatar, WebFShimmerButton } from '@openwebf/webf-react-core-ui';

function LoadingState() {
  return (
    <WebFShimmer>
      <div>
        <WebFShimmerAvatar width={60} height={60} />
        <WebFShimmerText height={20} />
        <WebFShimmerText height={16} />
        <WebFShimmerButton width={120} height={40} radius={8} />
      </div>
    </WebFShimmer>
  );
}
```

#### Components

| Component | Description | Props |
|-----------|-------------|-------|
| `WebFShimmer` | Container for native Flutter shimmer effect. Maps to `<flutter-shimmer>` | `children`, `className`, `style` |
| `WebFShimmerAvatar` | Circular shimmer placeholder. Maps to `<flutter-shimmer-avatar>` | `width` (default: 40), `height` (default: 40), `className`, `style` |
| `WebFShimmerText` | Text line shimmer placeholder. Maps to `<flutter-shimmer-text>` | `height` (default: 16), `className`, `style` |
| `WebFShimmerButton` | Button shimmer placeholder. Maps to `<flutter-shimmer-button>` | `width` (default: 80), `height` (default: 32), `radius` (default: 4), `className`, `style` |

## Development

```bash
# Install dependencies
npm install

# Build the library
npm run build

# Watch mode for development
npm run dev

# Clean build artifacts
npm run clean
```

## License

Apache-2.0