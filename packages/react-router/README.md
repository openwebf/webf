# @openwebf/react-router

A React Router implementation for WebF applications using hybrid history API. This package provides navigation and routing capabilities specifically designed for WebF's hybrid environment, combining web-like history management with Flutter-like navigation patterns.

## Features

- 🚀 **Hybrid Navigation**: Seamlessly bridge between WebF's native navigation and React's routing
- 📱 **Flutter-like API**: Familiar navigation methods like `push`, `pop`, `popUntil`, etc.
- 🎯 **Type-safe Routing**: Full TypeScript support with type-safe route parameters
- ⚡ **Performance Optimized**: Pre-rendering support and smart component lifecycle management
- 🔄 **State Management**: Pass and receive data between routes with ease
- 📊 **Route Context**: Access route information anywhere in your component tree

## Installation

```bash
npm install @openwebf/react-router
# or
yarn add @openwebf/react-router
# or
pnpm add @openwebf/react-router
```

### Peer Dependencies

This package requires the following peer dependencies:
- `react` >= 16.8.0
- `react-dom` >= 16.8.0
- `@openwebf/webf-enterprise-typings` >= 0.22.0

## Quick Start

```tsx
import React from 'react';
import { Routes, Route } from '@openwebf/react-router';

// Import your page components
import HomePage from './pages/Home';
import AboutPage from './pages/About';
import ProfilePage from './pages/Profile';

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/about" element={<AboutPage />} />
      <Route path="/profile" element={<ProfilePage />} prerender />
    </Routes>
  );
}

export default App;
```

## Core Components

### `<Routes>`

The container component that wraps all your routes and provides the routing context.

```tsx
<Routes>
  {/* Your Route components go here */}
</Routes>
```

### `<Route>`

Defines a single route in your application.

```tsx
<Route 
  path="/profile"              // Required: The path for this route
  element={<ProfilePage />}    // Required: Component to render
  prerender={true}            // Optional: Pre-render for better performance
/>
```

#### Props

- `path` (string, required): The path pattern for this route
- `element` (ReactNode, required): The component to render when this route is active
- `prerender` (boolean, optional): Whether to pre-render this route for better performance

## Hooks

### `useNavigate()`

Returns navigation methods to programmatically navigate between routes.

```tsx
import { useNavigate } from '@openwebf/react-router';

function LoginPage() {
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
  
  return (
    <div>
      <button onClick={handleLogin}>Login</button>
      <button onClick={handleCancel}>Cancel</button>
    </div>
  );
}
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

```tsx
import { useLocation } from '@openwebf/react-router';

function ProfilePage() {
  const location = useLocation();
  
  console.log('Current path:', location.pathname);
  console.log('Location state:', location.state);
  console.log('Is active:', location.isActive);
  
  return (
    <div>
      <h1>Profile Page</h1>
      {location.state?.from && (
        <p>You came from: {location.state.from}</p>
      )}
    </div>
  );
}
```

### `useRouteContext()`

Access detailed route context information.

```tsx
import { useRouteContext } from '@openwebf/react-router';

function MyComponent() {
  const { path, params, isActive, activePath, routeEventKind } = useRouteContext();
  
  if (isActive) {
    console.log('This route is currently active');
    console.log('Route params:', params);
  }
  
  return <div>Current path: {path}</div>;
}
```

### `useRoutes()`

Create routes from a configuration object.

```tsx
import { useRoutes } from '@openwebf/react-router';

function App() {
  const routes = useRoutes([
    { path: '/', element: <Home /> },
    { path: '/about', element: <About /> },
    { path: '/profile', element: <Profile />, prerender: true },
    { path: '/settings', element: <Settings /> }
  ]);
  
  return routes;
}
```

## Advanced Usage

### Passing State Between Routes

```tsx
// Navigate with state
const { navigate } = useNavigate();
navigate('/details', { 
  state: { 
    productId: 123, 
    from: 'catalog' 
  } 
});

// Access state in the target component
function DetailsPage() {
  const location = useLocation();
  const { productId, from } = location.state || {};
  
  return (
    <div>
      <h1>Product {productId}</h1>
      <p>You came from: {from}</p>
    </div>
  );
}
```

### Pre-rendering Routes

Pre-rendering improves performance by rendering routes before they're navigated to:

```tsx
<Routes>
  <Route path="/" element={<Home />} />
  <Route path="/dashboard" element={<Dashboard />} prerender />
  <Route path="/profile" element={<Profile />} prerender />
</Routes>
```

### Programmatic Navigation Patterns

```tsx
function NavigationExamples() {
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
}
```

## WebF Router API

The package exports a `WebFRouter` object that provides low-level access to the routing system:

```tsx
import { WebFRouter } from '@openwebf/react-router';

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

This package is written in TypeScript and provides complete type definitions. Route state can be typed for better type safety:

```tsx
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
function ProfilePage() {
  const location = useLocation();
  const state = location.state as ProfileState | undefined;
  
  if (state?.userId) {
    // TypeScript knows state.userId is a string
  }
}
```

## Best Practices

1. **Use Pre-rendering for Heavy Components**: Enable `prerender` for routes with expensive initial renders
2. **Clean Up State**: Be mindful of state passed between routes, especially for sensitive data
3. **Handle Missing State**: Always provide fallbacks when accessing route state
4. **Use Type Safety**: Leverage TypeScript for route paths and state objects
5. **Avoid Deep Nesting**: Keep your route structure flat when possible

## Migration from React Router

If you're migrating from standard React Router, here are the key differences:

1. **Navigation API**: Use `navigate()` instead of `history.push()`
2. **Route State**: State is passed differently and accessed via `useLocation()`
3. **No Nested Routes**: Current version doesn't support nested routes
4. **Flutter-like Methods**: Additional navigation methods like `popUntil`, `popAndPush`

## Examples

Check out the [examples](./examples) directory for complete working examples:

- [Basic App](./examples/basic/App.tsx) - Simple routing setup
- [Navigation Example](./examples/basic/NavigationExample.tsx) - Advanced navigation patterns
- [WebF Pattern](./examples/basic/AppWebFPattern.tsx) - WebF-specific patterns
- [useRoutes Hook](./examples/basic/UseRoutesExample.tsx) - Configuration-based routing

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