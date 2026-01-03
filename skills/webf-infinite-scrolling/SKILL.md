---
name: webf-infinite-scrolling
description: Create high-performance infinite scrolling lists with pull-to-refresh and load-more capabilities using WebFListView. Use when building feed-style UIs, product catalogs, chat messages, or any scrollable list that needs optimal performance with large datasets.
---

# WebF Infinite Scrolling

> **Note**: WebF development is nearly identical to web development - you use the same tools (Vite, npm, Vitest), same frameworks (React, Vue, Svelte), and same deployment services (Vercel, Netlify). This skill covers **performance optimization for scrolling lists** - a WebF-specific pattern that provides native-level performance automatically.

Build high-performance infinite scrolling lists with Flutter-optimized rendering. WebF's `WebFListView` component automatically handles performance optimizations at the Flutter level, providing smooth 60fps scrolling even with thousands of items.

## Why Use WebFListView?

In browsers, long scrolling lists can cause performance issues:
- DOM nodes accumulate (memory consumption)
- Re-renders affect all items (slow updates)
- Intersection observers needed for virtualization
- Complex state management for infinite loading

**WebF's solution**: `WebFListView` delegates rendering to Flutter's optimized ListView widget, which:
- ✅ Automatically virtualizes (recycles) views
- ✅ Maintains 60fps scrolling with thousands of items
- ✅ Provides native pull-to-refresh and load-more
- ✅ Zero configuration - optimization happens automatically

## Critical Structure Requirement

**⚠️ IMPORTANT**: For Flutter optimization to work, each list item must be a **direct child** of `WebFListView`:

### ✅ CORRECT: Direct Children

```jsx
<WebFListView>
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
  {/* Each item is a direct child */}
</WebFListView>
```

### ❌ WRONG: Wrapped in Container

```jsx
<WebFListView>
  <div>
    {/* DON'T wrap items in a container div */}
    <div>Item 1</div>
    <div>Item 2</div>
    <div>Item 3</div>
  </div>
</WebFListView>
```

**Why this matters**: Flutter's ListView requires direct children to perform view recycling. If items are wrapped in a container, Flutter sees only one child (the container) and cannot optimize individual items.

## React Setup

### Installation

```bash
npm install @openwebf/react-core-ui
```

### Basic Scrolling List

```tsx
import { WebFListView } from '@openwebf/react-core-ui';

function ProductList() {
  const products = [
    { id: 1, name: 'Product 1', price: 19.99 },
    { id: 2, name: 'Product 2', price: 29.99 },
    { id: 3, name: 'Product 3', price: 39.99 },
    // ... hundreds or thousands of items
  ];

  return (
    <WebFListView scrollDirection="vertical" shrinkWrap={true}>
      {products.map(product => (
        // ✅ Each item is a direct child
        <div key={product.id} className="product-card">
          <h3>{product.name}</h3>
          <p>${product.price}</p>
        </div>
      ))}
    </WebFListView>
  );
}
```

### Infinite Scrolling with Load More

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState } from 'react';

function InfiniteList() {
  const listRef = useRef<WebFListViewElement>(null);
  const [items, setItems] = useState([1, 2, 3, 4, 5]);
  const [page, setPage] = useState(1);

  const handleLoadMore = async () => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Fetch next page
      const newItems = Array.from(
        { length: 5 },
        (_, i) => items.length + i + 1
      );

      setItems(prev => [...prev, ...newItems]);
      setPage(prev => prev + 1);

      // Check if there's more data
      const hasMore = page < 10; // Example: 10 pages max

      // Notify WebFListView that loading finished
      listRef.current?.finishLoad(hasMore ? 'success' : 'noMore');
    } catch (error) {
      // Notify failure
      listRef.current?.finishLoad('fail');
    }
  };

  return (
    <WebFListView
      ref={listRef}
      onLoadMore={handleLoadMore}
      scrollDirection="vertical"
      shrinkWrap={true}
    >
      {items.map(item => (
        <div key={item} className="item">
          Item {item}
        </div>
      ))}
    </WebFListView>
  );
}
```

### Pull-to-Refresh

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState } from 'react';

function RefreshableList() {
  const listRef = useRef<WebFListViewElement>(null);
  const [items, setItems] = useState([1, 2, 3, 4, 5]);

  const handleRefresh = async () => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Fetch fresh data
      const freshItems = [1, 2, 3, 4, 5];
      setItems(freshItems);

      // Notify WebFListView that refresh finished
      listRef.current?.finishRefresh('success');
    } catch (error) {
      // Notify failure
      listRef.current?.finishRefresh('fail');
    }
  };

  return (
    <WebFListView
      ref={listRef}
      onRefresh={handleRefresh}
      scrollDirection="vertical"
      shrinkWrap={true}
    >
      {items.map(item => (
        <div key={item} className="item">
          Item {item}
        </div>
      ))}
    </WebFListView>
  );
}
```

### Combined: Pull-to-Refresh + Infinite Scrolling

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState } from 'react';

function FeedList() {
  const listRef = useRef<WebFListViewElement>(null);
  const [posts, setPosts] = useState([
    { id: 1, title: 'Post 1', content: 'Content 1' },
    { id: 2, title: 'Post 2', content: 'Content 2' },
    { id: 3, title: 'Post 3', content: 'Content 3' },
  ]);
  const [page, setPage] = useState(1);

  const handleRefresh = async () => {
    try {
      // Fetch latest posts
      const response = await fetch('/api/posts?page=1');
      const freshPosts = await response.json();

      setPosts(freshPosts);
      setPage(1);

      listRef.current?.finishRefresh('success');
    } catch (error) {
      listRef.current?.finishRefresh('fail');
    }
  };

  const handleLoadMore = async () => {
    try {
      const nextPage = page + 1;

      // Fetch next page
      const response = await fetch(`/api/posts?page=${nextPage}`);
      const newPosts = await response.json();

      setPosts(prev => [...prev, ...newPosts]);
      setPage(nextPage);

      // Check if more data exists
      const hasMore = newPosts.length > 0;
      listRef.current?.finishLoad(hasMore ? 'success' : 'noMore');
    } catch (error) {
      listRef.current?.finishLoad('fail');
    }
  };

  return (
    <WebFListView
      ref={listRef}
      onRefresh={handleRefresh}
      onLoadMore={handleLoadMore}
      scrollDirection="vertical"
      shrinkWrap={true}
      style={{ height: '100vh' }}
    >
      {posts.map(post => (
        <article key={post.id} className="post-card">
          <h2>{post.title}</h2>
          <p>{post.content}</p>
        </article>
      ))}
    </WebFListView>
  );
}
```

## Vue Setup

### Installation

```bash
npm install @openwebf/vue-core-ui
```

### Setup Global Types

In your `src/env.d.ts` or `src/main.ts`:

```typescript
import '@openwebf/vue-core-ui';
```

### Basic Scrolling List

```vue
<template>
  <webf-list-view scroll-direction="vertical" :shrink-wrap="true">
    <div v-for="product in products" :key="product.id" class="product-card">
      <h3>{{ product.name }}</h3>
      <p>${{ product.price }}</p>
    </div>
  </webf-list-view>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const products = ref([
  { id: 1, name: 'Product 1', price: 19.99 },
  { id: 2, name: 'Product 2', price: 29.99 },
  { id: 3, name: 'Product 3', price: 39.99 },
]);
</script>
```

### Infinite Scrolling with Load More

```vue
<template>
  <webf-list-view
    ref="listRef"
    @loadmore="handleLoadMore"
    scroll-direction="vertical"
    :shrink-wrap="true"
  >
    <div v-for="item in items" :key="item" class="item">
      Item {{ item }}
    </div>
  </webf-list-view>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const listRef = ref<HTMLElement>();
const items = ref([1, 2, 3, 4, 5]);
const page = ref(1);

async function handleLoadMore() {
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Fetch next page
    const newItems = Array.from(
      { length: 5 },
      (_, i) => items.value.length + i + 1
    );

    items.value.push(...newItems);
    page.value++;

    // Check if there's more data
    const hasMore = page.value < 10;

    // Notify WebFListView
    (listRef.value as any)?.finishLoad(hasMore ? 'success' : 'noMore');
  } catch (error) {
    (listRef.value as any)?.finishLoad('fail');
  }
}
</script>
```

### Pull-to-Refresh

```vue
<template>
  <webf-list-view
    ref="listRef"
    @refresh="handleRefresh"
    scroll-direction="vertical"
    :shrink-wrap="true"
  >
    <div v-for="item in items" :key="item" class="item">
      Item {{ item }}
    </div>
  </webf-list-view>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const listRef = ref<HTMLElement>();
const items = ref([1, 2, 3, 4, 5]);

async function handleRefresh() {
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Fetch fresh data
    items.value = [1, 2, 3, 4, 5];

    // Notify WebFListView
    (listRef.value as any)?.finishRefresh('success');
  } catch (error) {
    (listRef.value as any)?.finishRefresh('fail');
  }
}
</script>
```

## Props and Configuration

### WebFListView Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `scrollDirection` | `'vertical' \| 'horizontal'` | `'vertical'` | Scroll direction for the list |
| `shrinkWrap` | `boolean` | `true` | Whether list should shrink-wrap its contents |
| `onRefresh` / `@refresh` | `() => void \| Promise<void>` | - | Pull-to-refresh callback |
| `onLoadMore` / `@loadmore` | `() => void \| Promise<void>` | - | Infinite scroll callback (triggered near end) |
| `className` / `class` | `string` | - | CSS class names |
| `style` | `object` | - | Inline styles |

### Ref Methods (React) / Element Methods (Vue)

| Method | Signature | Description |
|--------|-----------|-------------|
| `finishRefresh` | `(result?: 'success' \| 'fail' \| 'noMore') => void` | Call after refresh completes |
| `finishLoad` | `(result?: 'success' \| 'fail' \| 'noMore') => void` | Call after load-more completes |
| `resetHeader` | `() => void` | Reset refresh header to initial state |
| `resetFooter` | `() => void` | Reset load-more footer to initial state |

### Result Values

- `'success'` - Operation succeeded, more data available
- `'fail'` - Operation failed (shows error state)
- `'noMore'` - No more data to load (hides footer/shows "no more" message)

## Common Patterns

### Pattern 1: Search with Results List

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState } from 'react';

function SearchResults() {
  const listRef = useRef<WebFListViewElement>(null);
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  const handleSearch = async (searchQuery: string) => {
    setQuery(searchQuery);

    // Fetch search results
    const response = await fetch(`/api/search?q=${searchQuery}`);
    const data = await response.json();

    setResults(data.results);
  };

  const handleLoadMore = async () => {
    try {
      const response = await fetch(
        `/api/search?q=${query}&offset=${results.length}`
      );
      const data = await response.json();

      setResults(prev => [...prev, ...data.results]);

      listRef.current?.finishLoad(
        data.results.length > 0 ? 'success' : 'noMore'
      );
    } catch (error) {
      listRef.current?.finishLoad('fail');
    }
  };

  return (
    <div>
      <input
        type="text"
        placeholder="Search..."
        onChange={(e) => handleSearch(e.target.value)}
      />

      <WebFListView
        ref={listRef}
        onLoadMore={handleLoadMore}
        scrollDirection="vertical"
        shrinkWrap={true}
      >
        {results.map(result => (
          <div key={result.id} className="search-result">
            {result.title}
          </div>
        ))}
      </WebFListView>
    </div>
  );
}
```

### Pattern 2: Chat Messages (Reverse List)

For chat-style UIs where new messages appear at the bottom:

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState, useEffect } from 'react';

function ChatMessages() {
  const listRef = useRef<WebFListViewElement>(null);
  const [messages, setMessages] = useState([
    { id: 1, text: 'Hello', timestamp: Date.now() },
    { id: 2, text: 'Hi there!', timestamp: Date.now() },
  ]);

  // Load older messages when scrolling to top
  const handleLoadMore = async () => {
    try {
      // In real app, fetch older messages before first message
      const oldestId = messages[0]?.id;
      const response = await fetch(`/api/messages?before=${oldestId}`);
      const olderMessages = await response.json();

      // Prepend older messages
      setMessages(prev => [...olderMessages, ...prev]);

      listRef.current?.finishLoad(
        olderMessages.length > 0 ? 'success' : 'noMore'
      );
    } catch (error) {
      listRef.current?.finishLoad('fail');
    }
  };

  return (
    <WebFListView
      ref={listRef}
      onLoadMore={handleLoadMore}
      scrollDirection="vertical"
      shrinkWrap={true}
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column-reverse' // Reverse order
      }}
    >
      {messages.map(message => (
        <div key={message.id} className="message">
          {message.text}
        </div>
      ))}
    </WebFListView>
  );
}
```

### Pattern 3: Horizontal Scrolling Gallery

```tsx
import { WebFListView } from '@openwebf/react-core-ui';

function ImageGallery({ images }) {
  return (
    <WebFListView
      scrollDirection="horizontal"
      shrinkWrap={true}
      style={{
        display: 'flex',
        height: '200px',
        gap: '10px'
      }}
    >
      {images.map(image => (
        <img
          key={image.id}
          src={image.url}
          alt={image.title}
          style={{
            width: '150px',
            height: '150px',
            objectFit: 'cover',
            flexShrink: 0  // Prevent shrinking
          }}
        />
      ))}
    </WebFListView>
  );
}
```

## Common Mistakes

### Mistake 1: Wrapping Items in Container

```jsx
// ❌ WRONG - Items wrapped in container div
<WebFListView>
  <div className="items-container">
    {items.map(item => <div key={item}>{item}</div>)}
  </div>
</WebFListView>

// ✅ CORRECT - Items are direct children
<WebFListView>
  {items.map(item => <div key={item}>{item}</div>)}
</WebFListView>
```

**Why**: Flutter's ListView needs direct children for view recycling to work.

### Mistake 2: Forgetting to Call finishLoad/finishRefresh

```tsx
// ❌ WRONG - Never calls finishLoad
const handleLoadMore = async () => {
  const data = await fetchData();
  setItems(prev => [...prev, ...data]);
  // finishLoad never called - loading indicator stuck!
};

// ✅ CORRECT - Always call finishLoad
const handleLoadMore = async () => {
  try {
    const data = await fetchData();
    setItems(prev => [...prev, ...data]);
    listRef.current?.finishLoad('success');
  } catch (error) {
    listRef.current?.finishLoad('fail');
  }
};
```

### Mistake 3: Not Handling "No More Data" State

```tsx
// ❌ WRONG - Always calls 'success', even when no data
const handleLoadMore = async () => {
  const data = await fetchData();
  setItems(prev => [...prev, ...data]);
  listRef.current?.finishLoad('success'); // Wrong if data is empty!
};

// ✅ CORRECT - Check if more data exists
const handleLoadMore = async () => {
  const data = await fetchData();
  setItems(prev => [...prev, ...data]);

  // Tell WebFListView there's no more data
  listRef.current?.finishLoad(data.length > 0 ? 'success' : 'noMore');
};
```

### Mistake 4: Timeout Issues (Taking Too Long)

WebFListView has a 4-second timeout for refresh/load operations. If your operation takes longer, it will auto-fail.

```tsx
// ❌ WRONG - Operation takes 10 seconds (will timeout)
const handleRefresh = async () => {
  await new Promise(resolve => setTimeout(resolve, 10000)); // 10s
  listRef.current?.finishRefresh('success'); // Too late!
};

// ✅ CORRECT - Complete within 4 seconds
const handleRefresh = async () => {
  try {
    // Use Promise.race to enforce timeout
    await Promise.race([
      fetchData(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('Timeout')), 3500)
      )
    ]);
    listRef.current?.finishRefresh('success');
  } catch (error) {
    listRef.current?.finishRefresh('fail');
  }
};
```

## Performance Tips

### 1. Use Keys Correctly

Always provide unique, stable keys for list items:

```tsx
// ✅ GOOD - Stable ID from data
{items.map(item => <div key={item.id}>{item.name}</div>)}

// ❌ BAD - Index as key (can cause bugs with dynamic lists)
{items.map((item, index) => <div key={index}>{item.name}</div>)}
```

### 2. Avoid Heavy Computations in Render

```tsx
// ❌ BAD - Heavy computation on every render
<WebFListView>
  {items.map(item => (
    <div key={item.id}>
      {expensiveCalculation(item)} {/* Calculated on every render! */}
    </div>
  ))}
</WebFListView>

// ✅ GOOD - Memoize or pre-calculate
const processedItems = useMemo(
  () => items.map(item => ({ ...item, computed: expensiveCalculation(item) })),
  [items]
);

<WebFListView>
  {processedItems.map(item => (
    <div key={item.id}>{item.computed}</div>
  ))}
</WebFListView>
```

### 3. Optimize Item Components

```tsx
// ✅ GOOD - Memoized item component
const ListItem = memo(({ item }) => (
  <div className="item">
    <h3>{item.title}</h3>
    <p>{item.description}</p>
  </div>
));

function MyList({ items }) {
  return (
    <WebFListView>
      {items.map(item => (
        <ListItem key={item.id} item={item} />
      ))}
    </WebFListView>
  );
}
```

### 4. Set Explicit Height for Scrolling

For full-screen lists, set explicit height:

```tsx
<WebFListView
  style={{
    height: '100vh', // or specific pixel value
    overflow: 'auto'
  }}
>
  {/* items */}
</WebFListView>
```

## Debugging

### Check if finishLoad/finishRefresh is Called

Add logging to verify callbacks execute:

```tsx
const handleLoadMore = async () => {
  console.log('🔄 Load more started');

  try {
    const data = await fetchData();
    setItems(prev => [...prev, ...data]);

    console.log('✅ Load more finished:', data.length, 'items');
    listRef.current?.finishLoad(data.length > 0 ? 'success' : 'noMore');
  } catch (error) {
    console.error('❌ Load more failed:', error);
    listRef.current?.finishLoad('fail');
  }
};
```

### Verify Direct Children Structure

Use React DevTools or Vue DevTools to inspect the rendered structure. Ensure items are direct children of `<webf-listview>`:

```html
<!-- ✅ CORRECT structure in DevTools -->
<webf-listview>
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</webf-listview>

<!-- ❌ WRONG structure in DevTools -->
<webf-listview>
  <div class="wrapper">
    <div>Item 1</div>
    <div>Item 2</div>
  </div>
</webf-listview>
```

## Resources

- **React Core UI Package**: `/Users/andycall/workspace/webf/packages/react-core-ui/README.md`
- **Vue Core UI Package**: `/Users/andycall/workspace/webf/packages/vue-core-ui/README.md`
- **Complete Examples**: See `examples.md` in this skill
- **npm Packages**:
  - https://www.npmjs.com/package/@openwebf/react-core-ui
  - https://www.npmjs.com/package/@openwebf/vue-core-ui

## Key Takeaways

✅ **DO**:
- Use `WebFListView` for long scrolling lists
- Make each item a direct child (not wrapped in container)
- Always call `finishLoad` / `finishRefresh` after operations
- Use `'noMore'` result when no more data exists
- Provide unique, stable keys for list items
- Set explicit height for full-screen lists

❌ **DON'T**:
- Wrap items in a container div
- Forget to call finish methods (loading indicator gets stuck)
- Use index as key for dynamic lists
- Let operations exceed 4-second timeout
- Use heavy computations in render without memoization
- Expect browser-style virtualization libraries (not needed!)

## Quick Reference

```bash
# Install packages
npm install @openwebf/react-core-ui  # React
npm install @openwebf/vue-core-ui    # Vue
```

```tsx
// React - Basic pattern
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';

const listRef = useRef<WebFListViewElement>(null);

<WebFListView
  ref={listRef}
  onRefresh={async () => {
    await refreshData();
    listRef.current?.finishRefresh('success');
  }}
  onLoadMore={async () => {
    const hasMore = await loadMore();
    listRef.current?.finishLoad(hasMore ? 'success' : 'noMore');
  }}
>
  {items.map(item => <div key={item.id}>{item.name}</div>)}
</WebFListView>
```

```vue
<!-- Vue - Basic pattern -->
<webf-list-view
  ref="listRef"
  @refresh="handleRefresh"
  @loadmore="handleLoadMore"
>
  <div v-for="item in items" :key="item.id">{{ item.name }}</div>
</webf-list-view>
```