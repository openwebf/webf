---
name: webf-routing-setup
description: Setup hybrid routing with native screen transitions in WebF - configure navigation using WebF routing instead of SPA routing. Use when setting up navigation, implementing multi-screen apps, or when react-router-dom/vue-router doesn't work as expected.
---

# WebF Routing Setup

> **Note**: WebF development is nearly identical to web development - you use the same tools (Vite, npm, Vitest), same frameworks (React, Vue, Svelte), and same deployment services (Vercel, Netlify). This skill covers **one of the 3 key differences**: routing with native screen transitions instead of SPA routing. The other two differences are async rendering and API compatibility.

**WebF does NOT use traditional Single-Page Application (SPA) routing.** Instead, it uses **hybrid routing** where each route renders on a separate, native Flutter screen with platform-native transitions.

## The Fundamental Difference

### In Browsers (SPA Routing)
Traditional web routing uses the History API or hash-based routing:

```javascript
// Browser SPA routing (react-router-dom, vue-router)
// ❌ This pattern does NOT work in WebF
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Single page with client-side routing
// All routes render in the same screen
// Transitions are CSS-based
```

The entire app runs in one screen, and route changes are simulated with JavaScript and CSS.

### In WebF (Hybrid Routing)
Each route is a separate Flutter screen with native transitions:

```javascript
// WebF hybrid routing
// ✅ This pattern WORKS in WebF
import { Routes, Route, WebFRouter } from '@openwebf/react-router';

// Each route renders on a separate Flutter screen
// Transitions use native platform animations
// Hardware back button works correctly
```

**Think of it like native mobile navigation** - each route is a new screen in a navigation stack, not a section of a single web page.

## Why Hybrid Routing?

WebF's approach provides true native app behavior:

1. **Native Transitions** - Platform-specific animations (Cupertino for iOS, Material for Android)
2. **Proper Lifecycle** - Each route has its own lifecycle, similar to native apps
3. **Hardware Back Button** - Android back button works correctly
4. **Memory Management** - Unused routes can be unloaded
5. **Deep Linking** - Integration with platform deep linking
6. **Synchronized Navigation** - Flutter Navigator and WebF routing stay in sync

## React Setup

### Installation

```bash
npm install @openwebf/react-router
```

**CRITICAL**: Do NOT use `react-router-dom` - it will not work correctly in WebF.

### Basic Route Configuration

```jsx
import { Route, Routes } from '@openwebf/react-router';
import { HomePage } from './pages/home';
import { ProfilePage } from './pages/profile';
import { SettingsPage } from './pages/settings';

function App() {
  return (
    <Routes>
      {/* Each Route must have a title prop */}
      <Route path="/" element={<HomePage />} title="Home" />
      <Route path="/profile" element={<ProfilePage />} title="Profile" />
      <Route path="/settings" element={<SettingsPage />} title="Settings" />
    </Routes>
  );
}

export default App;
```

**Important**: The `title` prop appears in the native navigation bar for that screen.

### Programmatic Navigation

Use the `WebFRouter` object for navigation:

```jsx
import { WebFRouter } from '@openwebf/react-router';

function HomePage() {
  // Navigate forward (push new screen)
  const goToProfile = () => {
    WebFRouter.pushState({ userId: 123 }, '/profile');
  };

  // Replace current screen (no back button)
  const replaceWithSettings = () => {
    WebFRouter.replaceState({}, '/settings');
  };

  // Navigate back
  const goBack = () => {
    WebFRouter.back();
  };

  // Navigate forward
  const goForward = () => {
    WebFRouter.forward();
  };

  return (
    <div>
      <h1>Home Page</h1>
      <button onClick={goToProfile}>View Profile</button>
      <button onClick={replaceWithSettings}>Go to Settings</button>
      <button onClick={goBack}>Back</button>
      <button onClick={goForward}>Forward</button>
    </div>
  );
}
```

### Passing Data Between Routes

Use the state parameter to pass data:

```jsx
import { WebFRouter, useLocation } from '@openwebf/react-router';

// Sender component
function ProductList() {
  const viewProduct = (product) => {
    // Pass product data to detail screen
    WebFRouter.pushState({
      productId: product.id,
      productName: product.name,
      productPrice: product.price
    }, '/product/detail');
  };

  return (
    <div>
      <button onClick={() => viewProduct({ id: 1, name: 'Widget', price: 19.99 })}>
        View Product
      </button>
    </div>
  );
}

// Receiver component
function ProductDetail() {
  const location = useLocation();
  const { productId, productName, productPrice } = location.state || {};

  if (!productId) {
    return <div>No product data</div>;
  }

  return (
    <div>
      <h1>{productName}</h1>
      <p>Price: ${productPrice}</p>
      <p>ID: {productId}</p>
    </div>
  );
}
```

### Using Route Parameters

WebF supports dynamic route parameters:

```jsx
import { Route, Routes, useParams } from '@openwebf/react-router';

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} title="Home" />
      <Route path="/user/:userId" element={<UserProfile />} title="User Profile" />
      <Route path="/post/:postId/comment/:commentId" element={<CommentDetail />} title="Comment" />
    </Routes>
  );
}

function UserProfile() {
  const { userId } = useParams();

  return (
    <div>
      <h1>User Profile</h1>
      <p>User ID: {userId}</p>
    </div>
  );
}

function CommentDetail() {
  const { postId, commentId } = useParams();

  return (
    <div>
      <h1>Comment Detail</h1>
      <p>Post ID: {postId}</p>
      <p>Comment ID: {commentId}</p>
    </div>
  );
}
```

### Declarative Navigation with Links

Use `WebFRouterLink` for clickable navigation:

```jsx
import { WebFRouterLink } from '@openwebf/react-router';

function NavigationMenu() {
  return (
    <nav>
      <WebFRouterLink path="/" title="Home">
        <button>Home</button>
      </WebFRouterLink>

      <WebFRouterLink path="/profile" title="My Profile">
        <button>Profile</button>
      </WebFRouterLink>

      <WebFRouterLink
        path="/settings"
        title="Settings"
        onScreen={() => console.log('Link is visible')}
      >
        <button>Settings</button>
      </WebFRouterLink>
    </nav>
  );
}
```

### Advanced Navigation Methods

WebFRouter provides Flutter-style navigation for complex scenarios:

```jsx
import { WebFRouter } from '@openwebf/react-router';

// Push a route (async, returns when screen is pushed)
await WebFRouter.push('/details', { itemId: 42 });

// Replace current route (no back button)
await WebFRouter.replace('/login', { sessionExpired: true });

// Pop and push (remove current, add new)
await WebFRouter.popAndPushNamed('/success', { orderId: 'ORD-123' });

// Check if can pop
if (WebFRouter.canPop()) {
  const didPop = WebFRouter.maybePop({ cancelled: false });
  console.log('Did pop:', didPop);
}

// Restorable navigation (state restoration support)
const restorationId = await WebFRouter.restorablePopAndPushNamed('/checkout', {
  cartItems: items,
  timestamp: Date.now()
});
```

## Hooks API

WebF routing provides React hooks for accessing route information:

```jsx
import { useLocation, useParams, useNavigate } from '@openwebf/react-router';

function MyComponent() {
  // Get current location (pathname, state, etc.)
  const location = useLocation();
  console.log('Current path:', location.pathname);
  console.log('Route state:', location.state);

  // Get route parameters
  const { userId, postId } = useParams();

  // Get navigation function
  const navigate = useNavigate();

  const handleClick = () => {
    // Navigate programmatically
    navigate('/profile', { userId: 123 });
  };

  return <button onClick={handleClick}>Go to Profile</button>;
}
```

## Common Patterns

### Pattern 1: Protected Routes

Redirect to login if not authenticated:

```jsx
import { useEffect } from 'react';
import { WebFRouter, useLocation } from '@openwebf/react-router';

function ProtectedRoute({ children, isAuthenticated }) {
  const location = useLocation();

  useEffect(() => {
    if (!isAuthenticated) {
      // Redirect to login, save current path
      WebFRouter.pushState({
        redirectTo: location.pathname
      }, '/login');
    }
  }, [isAuthenticated, location.pathname]);

  if (!isAuthenticated) {
    return null; // Or loading spinner
  }

  return children;
}

// Usage
function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} title="Login" />
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute isAuthenticated={isAuthenticated}>
            <DashboardPage />
          </ProtectedRoute>
        }
        title="Dashboard"
      />
    </Routes>
  );
}
```

### Pattern 2: Redirecting After Login

After successful login, navigate to saved location:

```jsx
function LoginPage() {
  const location = useLocation();
  const redirectTo = location.state?.redirectTo || '/';

  const handleLogin = async () => {
    // Perform login
    await loginUser();

    // Redirect to saved location or home
    WebFRouter.replaceState({}, redirectTo);
  };

  return (
    <button onClick={handleLogin}>
      Login
    </button>
  );
}
```

### Pattern 3: Conditional Navigation

Navigate based on result:

```jsx
async function handleSubmit(formData) {
  try {
    const result = await submitForm(formData);

    if (result.success) {
      // Navigate to success page
      WebFRouter.pushState({
        message: result.message,
        orderId: result.orderId
      }, '/success');
    } else {
      // Navigate to error page
      WebFRouter.pushState({
        error: result.error
      }, '/error');
    }
  } catch (error) {
    // Handle error
    WebFRouter.pushState({
      error: error.message
    }, '/error');
  }
}
```

### Pattern 4: Preventing Navigation

Confirm before leaving unsaved changes:

```jsx
import { useEffect } from 'react';
import { WebFRouter } from '@openwebf/react-router';

function FormPage() {
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  useEffect(() => {
    if (!hasUnsavedChanges) return;

    // Custom back button handler
    const handleBack = () => {
      const shouldLeave = confirm('You have unsaved changes. Leave anyway?');
      if (shouldLeave) {
        setHasUnsavedChanges(false);
        WebFRouter.back();
      }
    };

    // Note: This is a simplified example
    // Actual implementation depends on your back button handling
  }, [hasUnsavedChanges]);

  return (
    <form onChange={() => setHasUnsavedChanges(true)}>
      {/* Form fields */}
    </form>
  );
}
```

## Vue Setup

For Vue applications, use `@openwebf/vue-router`:

```bash
npm install @openwebf/vue-router
```

**Note**: The API is similar to Vue Router but adapted for WebF's hybrid routing. Full Vue examples are available in `examples.md`.

## Cross-Platform Support

For apps that run in both WebF and browsers, see `cross-platform.md` for router adapter patterns.

## Key Differences from SPA Routing

| Feature | SPA Routing (Browser) | Hybrid Routing (WebF) |
|---------|----------------------|----------------------|
| Screen transitions | CSS animations | Native platform animations |
| Route lifecycle | JavaScript-managed | Flutter-managed |
| Memory management | Manual | Automatic (Flutter Navigator) |
| Back button | History API | Hardware back button |
| Deep linking | URL-based | Platform deep linking |
| Route stacking | Virtual | Real native screen stack |

## Common Mistakes

### Mistake 1: Using react-router-dom

```jsx
// ❌ WRONG - Will not work correctly in WebF
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
      </Routes>
    </BrowserRouter>
  );
}
```

```jsx
// ✅ CORRECT - Use @openwebf/react-router
import { Routes, Route } from '@openwebf/react-router';

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} title="Home" />
    </Routes>
  );
}
```

### Mistake 2: Forgetting title Prop

```jsx
// ❌ WRONG - Missing title prop
<Route path="/" element={<HomePage />} />

// ✅ CORRECT - Include title
<Route path="/" element={<HomePage />} title="Home" />
```

### Mistake 3: Using window.history

```javascript
// ❌ WRONG - History API doesn't work in WebF
window.history.pushState({}, '', '/new-path');

// ✅ CORRECT - Use WebFRouter
WebFRouter.pushState({}, '/new-path');
```

### Mistake 4: Expecting SPA Behavior

```jsx
// ❌ WRONG - Expecting all routes to share state
// In WebF, each route is a separate screen
const [sharedState, setSharedState] = useState({}); // Won't persist across routes

// ✅ CORRECT - Use proper state management
// Use Context, Redux, or pass data via route state
WebFRouter.pushState({ data: myData }, '/next-route');
```

## Resources

- **Routing Documentation**: https://openwebf.com/en/docs/developer-guide/routing
- **Core Concepts - Hybrid Routing**: https://openwebf.com/en/docs/developer-guide/core-concepts#hybrid-routing
- **Complete Examples**: See `examples.md` in this skill
- **Cross-Platform Patterns**: See `cross-platform.md` in this skill
- **npm Package**: https://www.npmjs.com/package/@openwebf/react-router

## Quick Reference

```bash
# Install React router
npm install @openwebf/react-router

# Install Vue router
npm install @openwebf/vue-router
```

```jsx
// Basic setup
import { Routes, Route, WebFRouter } from '@openwebf/react-router';

// Navigate forward
WebFRouter.pushState({ data }, '/path');

// Navigate back
WebFRouter.back();

// Replace current
WebFRouter.replaceState({ data }, '/path');

// Get location
const location = useLocation();

// Get params
const { id } = useParams();
```

## Key Takeaways

✅ **DO**:
- Use `@openwebf/react-router` or `@openwebf/vue-router`
- Include `title` prop on all routes
- Use `WebFRouter` for navigation
- Pass data via route state
- Think of routes as native screens

❌ **DON'T**:
- Use react-router-dom or vue-router directly
- Expect SPA routing behavior
- Use window.history API
- Share state across routes without proper state management
- Forget that each route is a separate Flutter screen