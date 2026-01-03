# WebF Infinite Scrolling - Complete Examples

This file contains complete, production-ready examples for building infinite scrolling lists with WebF.

## Example 1: Social Media Feed (React)

A Twitter/Instagram-style feed with pull-to-refresh and infinite scrolling.

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState, memo } from 'react';

interface Post {
  id: number;
  author: string;
  avatar: string;
  content: string;
  likes: number;
  timestamp: number;
}

// Memoized post component for performance
const PostCard = memo(({ post }: { post: Post }) => (
  <article
    style={{
      padding: '16px',
      borderBottom: '1px solid #e0e0e0',
      backgroundColor: '#fff'
    }}
  >
    <div style={{ display: 'flex', alignItems: 'center', marginBottom: '12px' }}>
      <img
        src={post.avatar}
        alt={post.author}
        style={{
          width: '40px',
          height: '40px',
          borderRadius: '50%',
          marginRight: '12px'
        }}
      />
      <div>
        <div style={{ fontWeight: 'bold' }}>{post.author}</div>
        <div style={{ fontSize: '12px', color: '#666' }}>
          {new Date(post.timestamp).toLocaleDateString()}
        </div>
      </div>
    </div>

    <p style={{ marginBottom: '12px' }}>{post.content}</p>

    <div style={{ display: 'flex', gap: '16px', color: '#666' }}>
      <button>❤️ {post.likes}</button>
      <button>💬 Reply</button>
      <button>🔁 Share</button>
    </div>
  </article>
));

function SocialFeed() {
  const listRef = useRef<WebFListViewElement>(null);
  const [posts, setPosts] = useState<Post[]>([
    {
      id: 1,
      author: 'Alice',
      avatar: 'https://i.pravatar.cc/150?u=alice',
      content: 'Just launched my new app! 🚀',
      likes: 42,
      timestamp: Date.now()
    },
    {
      id: 2,
      author: 'Bob',
      avatar: 'https://i.pravatar.cc/150?u=bob',
      content: 'Beautiful sunset today 🌅',
      likes: 128,
      timestamp: Date.now() - 3600000
    }
  ]);
  const [page, setPage] = useState(1);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  // Pull to refresh - fetch latest posts
  const handleRefresh = async () => {
    if (isRefreshing) return;

    setIsRefreshing(true);

    try {
      const response = await fetch('/api/posts?page=1&limit=10');
      const freshPosts: Post[] = await response.json();

      setPosts(freshPosts);
      setPage(1);

      listRef.current?.finishRefresh('success');
    } catch (error) {
      console.error('Refresh failed:', error);
      listRef.current?.finishRefresh('fail');
    } finally {
      setIsRefreshing(false);
    }
  };

  // Load more - fetch older posts
  const handleLoadMore = async () => {
    if (isLoadingMore) return;

    setIsLoadingMore(true);

    try {
      const nextPage = page + 1;
      const response = await fetch(`/api/posts?page=${nextPage}&limit=10`);
      const newPosts: Post[] = await response.json();

      if (newPosts.length > 0) {
        setPosts(prev => [...prev, ...newPosts]);
        setPage(nextPage);
        listRef.current?.finishLoad('success');
      } else {
        // No more posts
        listRef.current?.finishLoad('noMore');
      }
    } catch (error) {
      console.error('Load more failed:', error);
      listRef.current?.finishLoad('fail');
    } finally {
      setIsLoadingMore(false);
    }
  };

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <header
        style={{
          padding: '16px',
          backgroundColor: '#1DA1F2',
          color: 'white',
          fontWeight: 'bold',
          fontSize: '20px'
        }}
      >
        Social Feed
      </header>

      {/* Scrollable Feed */}
      <WebFListView
        ref={listRef}
        onRefresh={handleRefresh}
        onLoadMore={handleLoadMore}
        scrollDirection="vertical"
        shrinkWrap={true}
        style={{ flex: 1, backgroundColor: '#f5f5f5' }}
      >
        {posts.map(post => (
          <PostCard key={post.id} post={post} />
        ))}
      </WebFListView>
    </div>
  );
}

export default SocialFeed;
```

## Example 2: E-Commerce Product Grid (React)

A product catalog with category filtering and infinite scrolling.

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState, memo } from 'react';

interface Product {
  id: number;
  name: string;
  price: number;
  image: string;
  category: string;
  rating: number;
}

const ProductCard = memo(({ product }: { product: Product }) => (
  <div
    style={{
      width: '180px',
      flexShrink: 0,
      marginRight: '16px',
      marginBottom: '16px',
      backgroundColor: 'white',
      borderRadius: '8px',
      overflow: 'hidden',
      boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
    }}
  >
    <img
      src={product.image}
      alt={product.name}
      style={{ width: '100%', height: '180px', objectFit: 'cover' }}
    />
    <div style={{ padding: '12px' }}>
      <h3 style={{ fontSize: '14px', marginBottom: '8px' }}>{product.name}</h3>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ fontWeight: 'bold', fontSize: '18px', color: '#1DA1F2' }}>
          ${product.price}
        </span>
        <span style={{ fontSize: '12px' }}>⭐ {product.rating}</span>
      </div>
    </div>
  </div>
));

function ProductCatalog() {
  const listRef = useRef<WebFListViewElement>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [category, setCategory] = useState<string>('all');
  const [page, setPage] = useState(1);

  // Fetch products by category
  const fetchProducts = async (cat: string, pageNum: number) => {
    const response = await fetch(
      `/api/products?category=${cat}&page=${pageNum}&limit=20`
    );
    return response.json();
  };

  // Category changed - reset and load
  const handleCategoryChange = async (newCategory: string) => {
    setCategory(newCategory);
    setPage(1);

    const freshProducts = await fetchProducts(newCategory, 1);
    setProducts(freshProducts);
  };

  const handleLoadMore = async () => {
    try {
      const nextPage = page + 1;
      const newProducts = await fetchProducts(category, nextPage);

      if (newProducts.length > 0) {
        setProducts(prev => [...prev, ...newProducts]);
        setPage(nextPage);
        listRef.current?.finishLoad('success');
      } else {
        listRef.current?.finishLoad('noMore');
      }
    } catch (error) {
      listRef.current?.finishLoad('fail');
    }
  };

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Category Filter */}
      <div style={{ padding: '16px', backgroundColor: 'white', borderBottom: '1px solid #e0e0e0' }}>
        <div style={{ display: 'flex', gap: '8px', overflowX: 'auto' }}>
          {['all', 'electronics', 'clothing', 'home', 'sports'].map(cat => (
            <button
              key={cat}
              onClick={() => handleCategoryChange(cat)}
              style={{
                padding: '8px 16px',
                borderRadius: '20px',
                border: 'none',
                backgroundColor: category === cat ? '#1DA1F2' : '#f0f0f0',
                color: category === cat ? 'white' : 'black',
                cursor: 'pointer',
                textTransform: 'capitalize'
              }}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Product Grid */}
      <WebFListView
        ref={listRef}
        onLoadMore={handleLoadMore}
        scrollDirection="vertical"
        shrinkWrap={true}
        style={{ flex: 1, padding: '16px' }}
      >
        <div
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            gap: '16px'
          }}
        >
          {products.map(product => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </WebFListView>
    </div>
  );
}

export default ProductCatalog;
```

## Example 3: Chat Messages (Vue)

A chat interface with reverse scrolling (load older messages at the top).

```vue
<template>
  <div class="chat-container">
    <!-- Chat Header -->
    <header class="chat-header">
      <div class="chat-title">Chat with Alice</div>
    </header>

    <!-- Messages List -->
    <webf-list-view
      ref="listRef"
      @loadmore="handleLoadMore"
      scroll-direction="vertical"
      :shrink-wrap="true"
      class="messages-list"
    >
      <div
        v-for="message in messages"
        :key="message.id"
        :class="['message', message.isOwn ? 'message-own' : 'message-other']"
      >
        <div class="message-bubble">
          <p>{{ message.text }}</p>
          <span class="message-time">{{ formatTime(message.timestamp) }}</span>
        </div>
      </div>
    </webf-list-view>

    <!-- Input Area -->
    <div class="chat-input">
      <input
        v-model="newMessage"
        type="text"
        placeholder="Type a message..."
        @keypress.enter="sendMessage"
      />
      <button @click="sendMessage">Send</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import '@openwebf/vue-core-ui';

interface Message {
  id: number;
  text: string;
  timestamp: number;
  isOwn: boolean;
}

const listRef = ref<HTMLElement>();
const messages = ref<Message[]>([
  {
    id: 1,
    text: 'Hey! How are you?',
    timestamp: Date.now() - 3600000,
    isOwn: false
  },
  {
    id: 2,
    text: "I'm good! How about you?",
    timestamp: Date.now() - 3000000,
    isOwn: true
  },
  {
    id: 3,
    text: 'Doing great! Want to grab lunch?',
    timestamp: Date.now() - 2400000,
    isOwn: false
  }
]);
const newMessage = ref('');
const page = ref(1);

// Load older messages (when scrolling to top)
async function handleLoadMore() {
  try {
    const oldestId = messages.value[0]?.id;

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    // In real app: fetch older messages
    const response = await fetch(`/api/messages?before=${oldestId}&limit=20`);
    const olderMessages: Message[] = await response.json();

    if (olderMessages.length > 0) {
      // Prepend older messages
      messages.value = [...olderMessages, ...messages.value];
      page.value++;

      (listRef.value as any)?.finishLoad('success');
    } else {
      (listRef.value as any)?.finishLoad('noMore');
    }
  } catch (error) {
    (listRef.value as any)?.finishLoad('fail');
  }
}

// Send new message
async function sendMessage() {
  if (!newMessage.value.trim()) return;

  const message: Message = {
    id: Date.now(),
    text: newMessage.value,
    timestamp: Date.now(),
    isOwn: true
  };

  messages.value.push(message);
  newMessage.value = '';

  // In real app: send to server
  await fetch('/api/messages', {
    method: 'POST',
    body: JSON.stringify(message)
  });
}

function formatTime(timestamp: number): string {
  const date = new Date(timestamp);
  return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}
</script>

<style scoped>
.chat-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f5f5f5;
}

.chat-header {
  padding: 16px;
  background-color: #1DA1F2;
  color: white;
}

.chat-title {
  font-weight: bold;
  font-size: 18px;
}

.messages-list {
  flex: 1;
  padding: 16px;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.message {
  margin-bottom: 12px;
  display: flex;
}

.message-own {
  justify-content: flex-end;
}

.message-other {
  justify-content: flex-start;
}

.message-bubble {
  max-width: 70%;
  padding: 12px;
  border-radius: 16px;
}

.message-own .message-bubble {
  background-color: #1DA1F2;
  color: white;
}

.message-other .message-bubble {
  background-color: white;
  color: black;
}

.message-time {
  font-size: 10px;
  opacity: 0.7;
  margin-top: 4px;
  display: block;
}

.chat-input {
  padding: 16px;
  background-color: white;
  border-top: 1px solid #e0e0e0;
  display: flex;
  gap: 8px;
}

.chat-input input {
  flex: 1;
  padding: 12px;
  border: 1px solid #e0e0e0;
  border-radius: 24px;
  font-size: 14px;
}

.chat-input button {
  padding: 12px 24px;
  background-color: #1DA1F2;
  color: white;
  border: none;
  border-radius: 24px;
  font-weight: bold;
  cursor: pointer;
}
</style>
```

## Example 4: News Feed with Search (React)

A news feed with search functionality and category tabs.

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState, memo, useMemo } from 'react';

interface Article {
  id: number;
  title: string;
  summary: string;
  author: string;
  category: string;
  image: string;
  timestamp: number;
}

const ArticleCard = memo(({ article }: { article: Article }) => (
  <article
    style={{
      display: 'flex',
      gap: '12px',
      padding: '16px',
      backgroundColor: 'white',
      borderBottom: '1px solid #e0e0e0'
    }}
  >
    <img
      src={article.image}
      alt={article.title}
      style={{
        width: '100px',
        height: '100px',
        objectFit: 'cover',
        borderRadius: '8px',
        flexShrink: 0
      }}
    />
    <div style={{ flex: 1 }}>
      <div
        style={{
          fontSize: '10px',
          color: '#1DA1F2',
          fontWeight: 'bold',
          marginBottom: '4px',
          textTransform: 'uppercase'
        }}
      >
        {article.category}
      </div>
      <h3 style={{ fontSize: '16px', marginBottom: '8px' }}>{article.title}</h3>
      <p style={{ fontSize: '14px', color: '#666', marginBottom: '8px' }}>
        {article.summary}
      </p>
      <div style={{ fontSize: '12px', color: '#999' }}>
        {article.author} • {new Date(article.timestamp).toLocaleDateString()}
      </div>
    </div>
  </article>
));

function NewsFeed() {
  const listRef = useRef<WebFListViewElement>(null);
  const [articles, setArticles] = useState<Article[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('all');
  const [page, setPage] = useState(1);

  const categories = ['all', 'technology', 'business', 'sports', 'entertainment'];

  // Filter articles by search query
  const filteredArticles = useMemo(() => {
    if (!searchQuery) return articles;

    return articles.filter(article =>
      article.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      article.summary.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [articles, searchQuery]);

  // Fetch articles
  const fetchArticles = async (category: string, pageNum: number) => {
    const response = await fetch(
      `/api/articles?category=${category}&page=${pageNum}&limit=15`
    );
    return response.json();
  };

  // Pull to refresh
  const handleRefresh = async () => {
    try {
      const freshArticles = await fetchArticles(activeCategory, 1);
      setArticles(freshArticles);
      setPage(1);
      listRef.current?.finishRefresh('success');
    } catch (error) {
      listRef.current?.finishRefresh('fail');
    }
  };

  // Load more articles
  const handleLoadMore = async () => {
    try {
      const nextPage = page + 1;
      const newArticles = await fetchArticles(activeCategory, nextPage);

      if (newArticles.length > 0) {
        setArticles(prev => [...prev, ...newArticles]);
        setPage(nextPage);
        listRef.current?.finishLoad('success');
      } else {
        listRef.current?.finishLoad('noMore');
      }
    } catch (error) {
      listRef.current?.finishLoad('fail');
    }
  };

  // Category changed
  const handleCategoryChange = async (category: string) => {
    setActiveCategory(category);
    setPage(1);

    const freshArticles = await fetchArticles(category, 1);
    setArticles(freshArticles);
  };

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Header with Search */}
      <div
        style={{
          padding: '16px',
          backgroundColor: 'white',
          borderBottom: '1px solid #e0e0e0'
        }}
      >
        <h1 style={{ marginBottom: '12px', fontSize: '24px' }}>News Feed</h1>
        <input
          type="text"
          placeholder="Search articles..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          style={{
            width: '100%',
            padding: '12px',
            border: '1px solid #e0e0e0',
            borderRadius: '8px',
            fontSize: '14px'
          }}
        />
      </div>

      {/* Category Tabs */}
      <div
        style={{
          display: 'flex',
          gap: '8px',
          padding: '12px 16px',
          backgroundColor: 'white',
          borderBottom: '1px solid #e0e0e0',
          overflowX: 'auto'
        }}
      >
        {categories.map(category => (
          <button
            key={category}
            onClick={() => handleCategoryChange(category)}
            style={{
              padding: '8px 16px',
              border: 'none',
              backgroundColor: activeCategory === category ? '#1DA1F2' : 'transparent',
              color: activeCategory === category ? 'white' : 'black',
              borderRadius: '20px',
              fontWeight: activeCategory === category ? 'bold' : 'normal',
              cursor: 'pointer',
              textTransform: 'capitalize',
              whiteSpace: 'nowrap'
            }}
          >
            {category}
          </button>
        ))}
      </div>

      {/* Articles List */}
      <WebFListView
        ref={listRef}
        onRefresh={handleRefresh}
        onLoadMore={handleLoadMore}
        scrollDirection="vertical"
        shrinkWrap={true}
        style={{ flex: 1, backgroundColor: '#f5f5f5' }}
      >
        {filteredArticles.length > 0 ? (
          filteredArticles.map(article => (
            <ArticleCard key={article.id} article={article} />
          ))
        ) : (
          <div
            style={{
              padding: '40px',
              textAlign: 'center',
              color: '#999'
            }}
          >
            {searchQuery ? 'No articles found matching your search' : 'No articles available'}
          </div>
        )}
      </WebFListView>
    </div>
  );
}

export default NewsFeed;
```

## Example 5: Image Gallery (Horizontal Scroll - React)

A horizontal scrolling image gallery with lazy loading.

```tsx
import { WebFListView, WebFListViewElement } from '@openwebf/react-core-ui';
import { useRef, useState } from 'react';

interface Image {
  id: number;
  url: string;
  title: string;
  width: number;
  height: number;
}

function ImageGallery() {
  const listRef = useRef<WebFListViewElement>(null);
  const [images, setImages] = useState<Image[]>([
    { id: 1, url: 'https://picsum.photos/300/200?random=1', title: 'Image 1', width: 300, height: 200 },
    { id: 2, url: 'https://picsum.photos/300/200?random=2', title: 'Image 2', width: 300, height: 200 },
    { id: 3, url: 'https://picsum.photos/300/200?random=3', title: 'Image 3', width: 300, height: 200 },
  ]);

  const handleLoadMore = async () => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));

      const newImages: Image[] = Array.from({ length: 5 }, (_, i) => ({
        id: images.length + i + 1,
        url: `https://picsum.photos/300/200?random=${images.length + i + 1}`,
        title: `Image ${images.length + i + 1}`,
        width: 300,
        height: 200
      }));

      setImages(prev => [...prev, ...newImages]);

      listRef.current?.finishLoad(images.length < 50 ? 'success' : 'noMore');
    } catch (error) {
      listRef.current?.finishLoad('fail');
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h2 style={{ marginBottom: '16px' }}>Photo Gallery</h2>

      <WebFListView
        ref={listRef}
        onLoadMore={handleLoadMore}
        scrollDirection="horizontal"
        shrinkWrap={true}
        style={{
          display: 'flex',
          gap: '12px',
          height: '220px',
          padding: '8px 0'
        }}
      >
        {images.map(image => (
          <div
            key={image.id}
            style={{
              flexShrink: 0,
              width: '300px',
              height: '200px',
              position: 'relative',
              borderRadius: '8px',
              overflow: 'hidden',
              boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
            }}
          >
            <img
              src={image.url}
              alt={image.title}
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'cover'
              }}
            />
            <div
              style={{
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
                padding: '12px',
                background: 'linear-gradient(transparent, rgba(0,0,0,0.7))',
                color: 'white',
                fontWeight: 'bold'
              }}
            >
              {image.title}
            </div>
          </div>
        ))}
      </WebFListView>
    </div>
  );
}

export default ImageGallery;
```

## Example 6: Real-Time Data Feed (Vue)

A real-time cryptocurrency price feed with auto-refresh.

```vue
<template>
  <div class="crypto-feed">
    <header class="header">
      <h1>Crypto Prices</h1>
      <button @click="toggleAutoRefresh">
        {{ autoRefresh ? '⏸ Pause' : '▶️ Start' }} Auto-Refresh
      </button>
    </header>

    <webf-list-view
      ref="listRef"
      @refresh="handleRefresh"
      @loadmore="handleLoadMore"
      scroll-direction="vertical"
      :shrink-wrap="true"
      class="price-list"
    >
      <div
        v-for="coin in coins"
        :key="coin.id"
        class="coin-card"
      >
        <img :src="coin.icon" :alt="coin.name" class="coin-icon" />
        <div class="coin-info">
          <div class="coin-name">{{ coin.name }}</div>
          <div class="coin-symbol">{{ coin.symbol }}</div>
        </div>
        <div class="coin-price-info">
          <div class="coin-price">${{ coin.price.toLocaleString() }}</div>
          <div
            :class="['coin-change', coin.change >= 0 ? 'positive' : 'negative']"
          >
            {{ coin.change >= 0 ? '↑' : '↓' }} {{ Math.abs(coin.change).toFixed(2) }}%
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import '@openwebf/vue-core-ui';

interface Coin {
  id: number;
  name: string;
  symbol: string;
  price: number;
  change: number;
  icon: string;
}

const listRef = ref<HTMLElement>();
const coins = ref<Coin[]>([]);
const page = ref(1);
const autoRefresh = ref(false);
let refreshInterval: NodeJS.Timeout | null = null;

// Fetch coins
async function fetchCoins(pageNum: number): Promise<Coin[]> {
  const response = await fetch(`/api/crypto?page=${pageNum}&limit=20`);
  return response.json();
}

// Pull to refresh
async function handleRefresh() {
  try {
    const freshCoins = await fetchCoins(1);
    coins.value = freshCoins;
    page.value = 1;

    (listRef.value as any)?.finishRefresh('success');
  } catch (error) {
    (listRef.value as any)?.finishRefresh('fail');
  }
}

// Load more
async function handleLoadMore() {
  try {
    const nextPage = page.value + 1;
    const newCoins = await fetchCoins(nextPage);

    if (newCoins.length > 0) {
      coins.value.push(...newCoins);
      page.value = nextPage;
      (listRef.value as any)?.finishLoad('success');
    } else {
      (listRef.value as any)?.finishLoad('noMore');
    }
  } catch (error) {
    (listRef.value as any)?.finishLoad('fail');
  }
}

// Toggle auto-refresh
function toggleAutoRefresh() {
  autoRefresh.value = !autoRefresh.value;

  if (autoRefresh.value) {
    // Refresh every 10 seconds
    refreshInterval = setInterval(async () => {
      const freshCoins = await fetchCoins(1);
      coins.value = freshCoins;
    }, 10000);
  } else if (refreshInterval) {
    clearInterval(refreshInterval);
    refreshInterval = null;
  }
}

onMounted(async () => {
  const initialCoins = await fetchCoins(1);
  coins.value = initialCoins;
});

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval);
  }
});
</script>

<style scoped>
.crypto-feed {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #0d1117;
  color: white;
}

.header {
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #161b22;
  border-bottom: 1px solid #30363d;
}

.header h1 {
  font-size: 24px;
  margin: 0;
}

.header button {
  padding: 8px 16px;
  background-color: #238636;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
}

.price-list {
  flex: 1;
}

.coin-card {
  display: flex;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #30363d;
  gap: 12px;
}

.coin-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
}

.coin-info {
  flex: 1;
}

.coin-name {
  font-weight: bold;
  font-size: 16px;
}

.coin-symbol {
  font-size: 12px;
  color: #8b949e;
  text-transform: uppercase;
}

.coin-price-info {
  text-align: right;
}

.coin-price {
  font-size: 16px;
  font-weight: bold;
}

.coin-change {
  font-size: 12px;
  font-weight: bold;
  margin-top: 4px;
}

.coin-change.positive {
  color: #3fb950;
}

.coin-change.negative {
  color: #f85149;
}
</style>
```

## Key Patterns Summary

1. **Social Feed**: Pull-to-refresh + infinite scroll for feed-style content
2. **Product Catalog**: Category filtering with lazy loading
3. **Chat Messages**: Reverse scrolling for chat interfaces
4. **News Feed**: Search + filtering + categorization
5. **Image Gallery**: Horizontal scrolling with lazy loading
6. **Real-Time Feed**: Auto-refresh with real-time updates

All examples follow the critical requirement: **Items are direct children of WebFListView**.