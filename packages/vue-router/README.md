# @openwebf/vue-router

A Vue Router implementation for WebF applications using hybrid history API. This package provides navigation and routing capabilities specifically designed for WebF's hybrid environment, combining web-like history management with Flutter-like navigation patterns.

## Features

- 🚀 **Hybrid Navigation**: Seamlessly bridge between WebF's native navigation and Vue's routing
- 📱 **Flutter-like API**: Familiar navigation methods like `push`, `pop`, `popUntil`, etc.
- 🎯 **Type-safe Routing**: Full TypeScript support with type-safe route parameters
- ⚡ **Performance Optimized**: Lazy loading support and smart component lifecycle management
- 🔄 **State Management**: Pass and receive data between routes with ease
- 📊 **Route Context**: Access route information anywhere in your component tree

## Installation

```bash
npm install @openwebf/vue-router
# or
yarn add @openwebf/vue-router
# or
pnpm add @openwebf/vue-router
```

### Peer Dependencies

This package requires the following peer dependencies:
- `vue` >= 3.0.0
- `@openwebf/webf-enterprise-typings` >= 0.22.0

## Quick Start

```vue
<template>
  <div id="app">
    <Routes>
      <Route path="/" :element="HomePage" title="Home" />
      <Route path="/about" :element="AboutPage" title="About" />
      <Route path="/profile" :element="ProfilePage" title="Profile" :prerender="true" />
    </Routes>
  </div>
</template>

<script setup>
import { Routes, Route } from '@openwebf/vue-router';
import HomePage from './pages/HomePage.vue';
import AboutPage from './pages/AboutPage.vue';
import ProfilePage from './pages/ProfilePage.vue';
</script>
```

## Core Components

### `<Routes>`

The container component that wraps all your routes and provides the routing context.

```vue
<Routes>
  <!-- Your Route components go here -->
</Routes>
```

### `<Route>`

Defines a single route in your application.

```vue
<Route 
  path="/profile"           
  :element="ProfilePage"    
  title="Profile"           
  :prerender="true"        
/>
```

#### Props

- `path` (string, required): The path pattern for this route
- `element` (Component | string, required): The component to render when this route is active
- `title` (string, optional): Title for the route
- `prerender` (boolean, optional): Whether to pre-render this route for better performance

## Composition API

### `useNavigate()`

Returns navigation methods to programmatically navigate between routes.

```vue
<script setup>
import { useNavigate } from '@openwebf/vue-router';

const { navigate, pop, canPop, popAndPush } = useNavigate();

const handleLogin = async () => {
  await loginUser();
  
  // Navigate to dashboard
  navigate('/dashboard');
  
  // Navigate with state
  navigate('/profile', { state: { from: 'login' } });
  
  // Replace current route
  navigate('/home', { replace: true });
  
  // Go back
  navigate(-1);
};

const handleCancel = () => {
  if (canPop()) {
    pop(); // Go back
  } else {
    navigate('/'); // Go to home if can't go back
  }
};
</script>
```

#### Navigation Methods

- `navigate(to, options?)`: Navigate to a route
  - `to`: string (path) or number (-1 for back)
  - `options`: { replace?: boolean, state?: any }
- `pop(result?)`: Go back to the previous route
- `popUntil(path)`: Pop routes until reaching a specific route
- `popAndPush(path, state?)`: Pop current route and push a new one
- `pushAndRemoveUntil(newPath, untilPath, state?)`: Push new route and remove all routes until a specific route
- `canPop()`: Check if navigation can go back
- `maybePop(result?)`: Pop if possible, returns boolean

### `useLocation()`

Returns the current location object with pathname and state.

```vue
<script setup>
import { useLocation } from '@openwebf/vue-router';

const location = useLocation();

console.log('Current path:', location.value.pathname);
console.log('Location state:', location.value.state);
console.log('Is active:', location.value.isActive);
</script>

<template>
  <div>
    <h1>Profile Page</h1>
    <p v-if="location.state?.from">
      You came from: {{ location.state.from }}
    </p>
  </div>
</template>
```

### `useRouteContext()`

Access detailed route context information.

```vue
<script setup>
import { useRouteContext } from '@openwebf/vue-router';

const { path, params, isActive, activePath, routeEventKind } = useRouteContext();

if (isActive.value) {
  console.log('This route is currently active');
  console.log('Route params:', params.value);
}
</script>
```

### `useParams()`

Get route parameters from dynamic routes.

```vue
<script setup>
// For route pattern "/user/:userId" and actual path "/user/123"
import { useParams } from '@openwebf/vue-router';

const params = useParams();
console.log(params.value.userId); // "123"
</script>

<template>
  <div>User ID: {{ params.userId }}</div>
</template>
```

### `useRoutes()`

Create routes from a configuration object.

```vue
<script setup>
import { useRoutes } from '@openwebf/vue-router';
import HomePage from './pages/HomePage.vue';
import AboutPage from './pages/AboutPage.vue';

const routes = useRoutes([
  { path: '/', element: HomePage, title: 'Home' },
  { path: '/about', element: AboutPage, title: 'About' },
  { path: '/profile', element: 'ProfilePage', prerender: true }, // String for lazy loading
]);
</script>

<template>
  <component :is="routes" />
</template>
```

## Advanced Usage

### Dynamic Routes

Support for route parameters like React Router:

```vue
<template>
  <Routes>
    <Route path="/user/:userId" :element="UserPage" />
    <Route path="/posts/:postId/comments/:commentId" :element="CommentPage" />
  </Routes>
</template>

<script setup>
// In UserPage component
import { useParams } from '@openwebf/vue-router';

const params = useParams();
// Access params.value.userId
</script>
```

### Passing State Between Routes

```vue
<script setup>
// Navigate with state
const { navigate } = useNavigate();
navigate('/details', { 
  state: { 
    productId: 123, 
    from: 'catalog' 
  } 
});

// Access state in the target component
const location = useLocation();
const { productId, from } = location.value.state || {};
</script>
```

### Pre-rendering Routes

Pre-rendering improves performance by rendering routes before they're navigated to:

```vue
<Routes>
  <Route path="/" :element="Home" />
  <Route path="/dashboard" :element="Dashboard" :prerender="true" />
  <Route path="/profile" :element="Profile" :prerender="true" />
</Routes>
```

### Programmatic Navigation Patterns

```vue
<script setup>
const nav = useNavigate();

// Simple navigation
const goToHome = () => nav.navigate('/');

// Replace current entry
const replaceWithLogin = () => nav.navigate('/login', { replace: true });

// Navigate with complex state
const goToProduct = (product) => {
  nav.navigate(`/products/${product.id}`, {
    state: { 
      product,
      timestamp: Date.now()
    }
  });
};

// Complex navigation flow
const completeCheckout = async () => {
  // Process payment...
  await processPayment();
  
  // Go to success page and prevent going back to checkout
  await nav.pushAndRemoveUntil('/success', '/');
};

// Conditional navigation
const smartBack = () => {
  if (nav.canPop()) {
    nav.pop();
  } else {
    nav.navigate('/');
  }
};
</script>
```

## WebF Router API

The package exports a `WebFRouter` object that provides low-level access to the routing system:

```js
import { WebFRouter } from '@openwebf/vue-router';

// Get current route info
console.log('Current path:', WebFRouter.path);
console.log('Current state:', WebFRouter.state);

// Navigation methods
WebFRouter.push('/new-route', { data: 'value' });
WebFRouter.replace('/replacement-route');
WebFRouter.back();
WebFRouter.pop();
WebFRouter.popUntil('/target');
```

## TypeScript Support

This package is written in TypeScript and provides complete type definitions:

```typescript
import { useNavigate, useLocation } from '@openwebf/vue-router';
import type { NavigateOptions, Location } from '@openwebf/vue-router';

interface ProfileState {
  userId: string;
  referrer?: string;
}

// Navigate with typed state
const { navigate } = useNavigate();
navigate('/profile', { 
  state: { 
    userId: '123', 
    referrer: 'dashboard' 
  } as ProfileState 
});

// Access typed state
const location = useLocation();
const state = location.value.state as ProfileState | undefined;

if (state?.userId) {
  // TypeScript knows state.userId is a string
}
```

## Best Practices

1. **Use Pre-rendering for Heavy Components**: Enable `prerender` for routes with expensive initial renders
2. **Clean Up State**: Be mindful of state passed between routes, especially for sensitive data
3. **Handle Missing State**: Always provide fallbacks when accessing route state
4. **Use Type Safety**: Leverage TypeScript for route paths and state objects
5. **Lazy Loading**: Use string component names for automatic lazy loading

## Migration from Vue Router

If you're migrating from standard Vue Router, here are the key differences:

1. **Navigation API**: Use `navigate()` instead of `router.push()`
2. **Route State**: State is passed differently and accessed via `useLocation()`
3. **No Nested Routes**: Current version doesn't support nested routes
4. **Flutter-like Methods**: Additional navigation methods like `popUntil`, `popAndPush`
5. **Component Structure**: Use `<Routes>` and `<Route>` instead of `<router-view>`

## Examples

### Basic Setup

```vue
<template>
  <div id="app">
    <Routes>
      <Route path="/" :element="HomePage" title="Home" />
      <Route path="/about" :element="AboutPage" title="About" />
      <Route path="/contact" :element="ContactPage" title="Contact" />
    </Routes>
  </div>
</template>

<script setup>
import { Routes, Route } from '@openwebf/vue-router';
import HomePage from './pages/HomePage.vue';
import AboutPage from './pages/AboutPage.vue';
import ContactPage from './pages/ContactPage.vue';
</script>
```

### Navigation Component

```vue
<template>
  <nav>
    <button @click="() => navigate('/')">Home</button>
    <button @click="() => navigate('/about')">About</button>
    <button @click="() => navigate('/contact')">Contact</button>
  </nav>
</template>

<script setup>
import { useNavigate } from '@openwebf/vue-router';

const { navigate } = useNavigate();
</script>
```

## Troubleshooting

### Routes not updating

Ensure your `Routes` component is at the root of your component tree and not inside any conditional rendering.

### State is undefined

Route state is only available when navigating TO a route. It's not persisted across page refreshes in WebF.

### Performance issues

Enable `prerender` for routes that take time to render initially.

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

Apache-2.0 License. See [LICENSE](LICENSE) for details.