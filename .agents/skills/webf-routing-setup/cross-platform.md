# Cross-Platform Routing Patterns

Build applications that work in both WebF (native) and browsers (web) using a single codebase.

## The Challenge

WebF uses hybrid routing with native screen transitions:
- `@openwebf/react-router` for WebF
- Each route is a separate Flutter screen

Browsers use SPA routing with History API:
- `react-router-dom` for browsers
- All routes render in a single page
- Transitions are CSS-based

**Goal**: Write one app that works in both environments.

## Solution: Router Adapter Pattern

Create an adapter that detects the environment and uses the appropriate router.

## Complete React Example

### Step 1: Install Both Routers

```bash
# WebF router
npm install @openwebf/react-router

# Browser router
npm install react-router-dom
```

### Step 2: Create Router Adapter

```jsx
// src/routing/router-adapter.jsx
import * as WebFRouter from '@openwebf/react-router';
import * as BrowserRouter from 'react-router-dom';

// Detect if running in WebF
const isWebF = typeof window !== 'undefined' && typeof (window as any).webf !== 'undefined';

// Export appropriate router components
export const Routes = isWebF ? WebFRouter.Routes : BrowserRouter.Routes;
export const Route = isWebF ? WebFRouter.Route : BrowserRouter.Route;
export const useLocation = isWebF ? WebFRouter.useLocation : BrowserRouter.useLocation;
export const useParams = isWebF ? WebFRouter.useParams : BrowserRouter.useParams;
export const useNavigate = isWebF ? WebFRouter.useNavigate : BrowserRouter.useNavigate;

// Router provider wrapper
export function RouterProvider({ children }) {
  if (isWebF) {
    // WebF doesn't need a provider wrapper
    return <>{children}</>;
  }

  // Browser needs BrowserRouter wrapper
  return <BrowserRouter.BrowserRouter>{children}</BrowserRouter.BrowserRouter>;
}

// Navigation helper (unified API)
export const navigate = {
  push: (path, state = {}) => {
    if (isWebF) {
      WebFRouter.WebFRouter.pushState(state, path);
    } else {
      // In browser, use window.history or useNavigate hook
      window.history.pushState(state, '', path);
      window.dispatchEvent(new PopStateEvent('popstate'));
    }
  },

  replace: (path, state = {}) => {
    if (isWebF) {
      WebFRouter.WebFRouter.replaceState(state, path);
    } else {
      window.history.replaceState(state, '', path);
      window.dispatchEvent(new PopStateEvent('popstate'));
    }
  },

  back: () => {
    if (isWebF) {
      WebFRouter.WebFRouter.back();
    } else {
      window.history.back();
    }
  },

  forward: () => {
    if (isWebF) {
      WebFRouter.WebFRouter.forward();
    } else {
      window.history.forward();
    }
  }
};

// Link component that works in both environments
export function Link({ to, state, children, ...props }) {
  const handleClick = (e) => {
    e.preventDefault();
    navigate.push(to, state);
  };

  return (
    <a href={to} onClick={handleClick} {...props}>
      {children}
    </a>
  );
}

// Check if running in WebF
export { isWebF };
```

### Step 3: Update App to Use Adapter

```jsx
// src/App.jsx
import { Routes, Route, RouterProvider } from './routing/router-adapter';
import HomePage from './pages/HomePage';
import ProfilePage from './pages/ProfilePage';
import SettingsPage from './pages/SettingsPage';

function App() {
  return (
    <RouterProvider>
      <Routes>
        <Route path="/" element={<HomePage />} title="Home" />
        <Route path="/profile" element={<ProfilePage />} title="Profile" />
        <Route path="/settings" element={<SettingsPage />} title="Settings" />
      </Routes>
    </RouterProvider>
  );
}

export default App;
```

**Note**: The `title` prop is ignored by react-router-dom, so it's safe to include for both.

### Step 4: Use Adapter in Components

```jsx
// src/pages/HomePage.jsx
import { navigate, Link, isWebF } from '../routing/router-adapter';

function HomePage() {
  const goToProfile = () => {
    navigate.push('/profile', { source: 'home' });
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Home Page</h1>

      {isWebF && (
        <p style={{ color: 'green' }}>
          Running in WebF (Native App)
        </p>
      )}

      {!isWebF && (
        <p style={{ color: 'blue' }}>
          Running in Browser (Web)
        </p>
      )}

      <div style={{ marginTop: '20px' }}>
        {/* Programmatic navigation */}
        <button onClick={goToProfile} style={{ marginRight: '10px' }}>
          Go to Profile (Button)
        </button>

        {/* Declarative navigation */}
        <Link to="/settings" state={{ from: 'home' }}>
          Go to Settings (Link)
        </Link>
      </div>
    </div>
  );
}

export default HomePage;
```

```jsx
// src/pages/ProfilePage.jsx
import { useLocation, navigate } from '../routing/router-adapter';

function ProfilePage() {
  const location = useLocation();
  const source = location.state?.source;

  const goBack = () => {
    navigate.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Profile Page</h1>

      {source && (
        <p>Came from: {source}</p>
      )}

      <button onClick={goBack} style={{ marginTop: '20px' }}>
        Go Back
      </button>
    </div>
  );
}

export default ProfilePage;
```

## Advanced: Custom Hook for Navigation

Create a unified `useNavigation` hook:

```jsx
// src/routing/use-navigation.js
import { useCallback } from 'react';
import { navigate, isWebF } from './router-adapter';

export function useNavigation() {
  const push = useCallback((path, state) => {
    navigate.push(path, state);
  }, []);

  const replace = useCallback((path, state) => {
    navigate.replace(path, state);
  }, []);

  const back = useCallback(() => {
    navigate.back();
  }, []);

  const forward = useCallback(() => {
    navigate.forward();
  }, []);

  return {
    push,
    replace,
    back,
    forward,
    isWebF
  };
}
```

**Usage**:

```jsx
import { useNavigation } from '../routing/use-navigation';

function MyComponent() {
  const { push, back, isWebF } = useNavigation();

  const handleClick = () => {
    push('/details', { itemId: 123 });
  };

  return (
    <div>
      <button onClick={handleClick}>View Details</button>
      <button onClick={back}>Go Back</button>

      {isWebF ? (
        <p>Native transitions enabled</p>
      ) : (
        <p>Browser mode</p>
      )}
    </div>
  );
}
```

## Environment Detection

### Method 1: Check for WebF Global

```javascript
const isWebF = typeof window !== 'undefined' && typeof window.webf !== 'undefined';
```

### Method 2: Check for WebFRouter

```javascript
import { WebFRouter } from '@openwebf/react-router';

const isWebF = typeof WebFRouter !== 'undefined';
```

### Method 3: Environment Variable

Set environment variable during build:

```bash
# .env.webf
VITE_PLATFORM=webf

# .env.browser
VITE_PLATFORM=browser
```

```javascript
const isWebF = import.meta.env.VITE_PLATFORM === 'webf';
```

## Platform-Specific Features

Some features only make sense in one environment:

```jsx
import { isWebF } from './routing/router-adapter';
import { WebFShare } from '@openwebf/webf-share';

function ShareButton({ title, url }) {
  if (!isWebF) {
    // Browser: Use Web Share API or fallback
    const handleShare = async () => {
      if (navigator.share) {
        await navigator.share({ title, url });
      } else {
        // Fallback: copy to clipboard
        navigator.clipboard.writeText(url);
        alert('Link copied to clipboard!');
      }
    };

    return <button onClick={handleShare}>Share</button>;
  }

  // WebF: Use native share
  if (!WebFShare.isAvailable()) {
    return null;
  }

  const handleShare = async () => {
    await WebFShare.shareText({ text: title, url });
  };

  return <button onClick={handleShare}>Share</button>;
}
```

## Build Configuration

### Vite Configuration

```javascript
// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const isWebF = mode === 'webf';

  return {
    plugins: [react()],
    define: {
      'import.meta.env.IS_WEBF': isWebF
    },
    build: {
      // Different output directories for different platforms
      outDir: isWebF ? 'dist-webf' : 'dist-browser'
    }
  };
});
```

**Build commands**:

```bash
# Build for browser
npm run build

# Build for WebF
npm run build -- --mode webf
```

### Package.json Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "dev:webf": "vite --mode webf",
    "build": "vite build",
    "build:webf": "vite build --mode webf",
    "preview": "vite preview"
  }
}
```

## TypeScript Support

Add types for the router adapter:

```typescript
// src/routing/router-adapter.d.ts
export interface NavigateState {
  [key: string]: any;
}

export interface NavigateAPI {
  push: (path: string, state?: NavigateState) => void;
  replace: (path: string, state?: NavigateState) => void;
  back: () => void;
  forward: () => void;
}

export const navigate: NavigateAPI;
export const isWebF: boolean;

export function RouterProvider({ children }: { children: React.ReactNode }): JSX.Element;
export function Link({ to, state, children, ...props }: {
  to: string;
  state?: NavigateState;
  children: React.ReactNode;
  [key: string]: any;
}): JSX.Element;

export { Routes, Route, useLocation, useParams, useNavigate } from '@openwebf/react-router';
```

## Testing Both Platforms

### Test in Browser

```bash
npm run dev
# Open http://localhost:5173 in browser
```

### Test in WebF

```bash
npm run dev -- --host
# Open http://192.168.x.x:5173 in WebF Go
```

## Best Practices

### 1. Use Adapter Consistently

❌ **Don't mix routers**:
```jsx
import { WebFRouter } from '@openwebf/react-router';
import { useNavigate } from 'react-router-dom';
// This will break!
```

✅ **Use adapter everywhere**:
```jsx
import { navigate, useLocation } from './routing/router-adapter';
// Works in both environments
```

### 2. Handle Missing State Gracefully

```jsx
function DetailPage() {
  const location = useLocation();
  const data = location.state?.data || getDefaultData();

  // Always have fallback for missing state
  return <div>{data.name}</div>;
}
```

### 3. Test in Both Environments

- Develop in browser for fast iteration
- Test in WebF Go regularly
- CI/CD should test both builds

### 4. Platform-Specific Code

Use feature flags for platform-specific behavior:

```jsx
import { isWebF } from './routing/router-adapter';

function Header() {
  return (
    <header>
      <h1>My App</h1>
      {isWebF ? (
        <NativeBackButton />
      ) : (
        <BrowserBackButton />
      )}
    </header>
  );
}
```

### 5. Keep Router Logic Simple

Don't create overly complex abstractions. The adapter should be thin and predictable.

## Summary

The router adapter pattern allows you to:

1. ✅ Write once, run in browser and WebF
2. ✅ Use familiar routing APIs
3. ✅ Handle platform differences gracefully
4. ✅ Test consistently across platforms
5. ✅ Maintain a single codebase

**Key Files**:
- `src/routing/router-adapter.jsx` - Router abstraction
- `src/routing/use-navigation.js` - Navigation hook
- `.env.webf` / `.env.browser` - Environment config

**Development Flow**:
1. Develop in browser (fast iteration)
2. Test in WebF Go (native behavior)
3. Build for both platforms
4. Deploy to web and app stores

This approach gives you the best of both worlds: web development speed and native app experience.