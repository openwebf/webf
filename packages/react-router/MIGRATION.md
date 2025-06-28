# Migration Guide

## Migrating from React Router v6

This guide helps you migrate from React Router v6 to @openwebf/react-router.

### Key Differences

1. **WebF Integration**: This router is specifically designed for WebF applications and uses WebF's hybrid history API
2. **Flutter-like Navigation**: Additional navigation methods inspired by Flutter's Navigator
3. **No Nested Routes**: Current version doesn't support nested routes
4. **Different State Management**: Route state is handled differently

### Component Changes

#### Routes Component

React Router v6:
```tsx
import { Routes, Route } from 'react-router-dom';

<Routes>
  <Route path="/" element={<Home />} />
  <Route path="/about" element={<About />} />
</Routes>
```

@openwebf/react-router:
```tsx
import { Routes, Route } from '@openwebf/react-router';

<Routes>
  <Route path="/" element={<Home />} />
  <Route path="/about" element={<About />} prerender /> 
</Routes>
```

**Changes:**
- Import from `@openwebf/react-router` instead of `react-router-dom`
- Added `prerender` prop for performance optimization
- No `<BrowserRouter>` or `<Router>` wrapper needed

### Hook Changes

#### useNavigate

React Router v6:
```tsx
import { useNavigate } from 'react-router-dom';

const navigate = useNavigate();
navigate('/about');
navigate('/profile', { state: { userId: 123 } });
navigate(-1); // Go back
```

@openwebf/react-router:
```tsx
import { useNavigate } from '@openwebf/react-router';

const { navigate, pop, canPop, popAndPush } = useNavigate();
navigate('/about');
navigate('/profile', { state: { userId: 123 } });
navigate(-1); // Go back

// Additional Flutter-like methods
pop(); // Go back
popAndPush('/new-route', { state: 'data' });
```

**Changes:**
- `useNavigate` returns an object with multiple methods
- Additional navigation methods available
- Same basic `navigate()` API

#### useLocation

React Router v6:
```tsx
import { useLocation } from 'react-router-dom';

const location = useLocation();
console.log(location.pathname);
console.log(location.state);
console.log(location.search); // Query string
console.log(location.hash);   // Hash
```

@openwebf/react-router:
```tsx
import { useLocation } from '@openwebf/react-router';

const location = useLocation();
console.log(location.pathname);
console.log(location.state);
console.log(location.isActive); // New property
// Note: search and hash not available in WebF
```

**Changes:**
- No `search` or `hash` properties (WebF doesn't use query strings or hashes)
- Added `isActive` property

#### useParams

React Router v6:
```tsx
import { useParams } from 'react-router-dom';

// Route: /users/:id
const { id } = useParams();
```

@openwebf/react-router:
```tsx
// Dynamic params not supported in current version
// Use state to pass data between routes instead
navigate('/user', { state: { id: userId } });
```

**Changes:**
- No dynamic route parameters support
- Use route state for passing data

### Feature Comparison

| Feature | React Router v6 | @openwebf/react-router |
|---------|----------------|----------------------|
| Basic routing | ✅ | ✅ |
| Nested routes | ✅ | ❌ |
| Route parameters | ✅ | ❌ |
| Query strings | ✅ | ❌ |
| Route guards | ✅ | ❌ |
| Lazy loading | ✅ | ✅ (via prerender) |
| Navigate with state | ✅ | ✅ |
| Flutter-like navigation | ❌ | ✅ |
| WebF integration | ❌ | ✅ |

### Common Migration Patterns

#### Protected Routes

React Router v6:
```tsx
function ProtectedRoute({ children }) {
  const auth = useAuth();
  const location = useLocation();
  
  if (!auth.user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  
  return children;
}

<Route path="/dashboard" element={
  <ProtectedRoute>
    <Dashboard />
  </ProtectedRoute>
} />
```

@openwebf/react-router:
```tsx
function ProtectedRoute({ children }) {
  const auth = useAuth();
  const location = useLocation();
  const { navigate } = useNavigate();
  
  useEffect(() => {
    if (!auth.user) {
      navigate('/login', { 
        state: { from: location.pathname },
        replace: true 
      });
    }
  }, [auth.user]);
  
  if (!auth.user) {
    return null; // or loading spinner
  }
  
  return children;
}

<Route path="/dashboard" element={
  <ProtectedRoute>
    <Dashboard />
  </ProtectedRoute>
} />
```

#### Nested Routes

React Router v6:
```tsx
<Routes>
  <Route path="/users" element={<Users />}>
    <Route path=":id" element={<UserDetail />} />
    <Route path="new" element={<NewUser />} />
  </Route>
</Routes>
```

@openwebf/react-router (workaround):
```tsx
// Create separate routes
<Routes>
  <Route path="/users" element={<Users />} />
  <Route path="/users/detail" element={<UserDetail />} />
  <Route path="/users/new" element={<NewUser />} />
</Routes>

// Pass ID via state
navigate('/users/detail', { state: { userId: id } });
```

#### Query Parameters

React Router v6:
```tsx
const [searchParams, setSearchParams] = useSearchParams();
const filter = searchParams.get('filter');
setSearchParams({ filter: 'active' });
```

@openwebf/react-router (workaround):
```tsx
// Use route state instead
const location = useLocation();
const { filter } = location.state || {};

// Update state
navigate(location.pathname, { 
  state: { ...location.state, filter: 'active' },
  replace: true 
});
```

### Step-by-Step Migration

1. **Update imports**
   ```tsx
   // Replace
   import { Routes, Route, useNavigate, useLocation } from 'react-router-dom';
   // With
   import { Routes, Route, useNavigate, useLocation } from '@openwebf/react-router';
   ```

2. **Remove Router wrapper**
   ```tsx
   // Remove BrowserRouter
   - <BrowserRouter>
       <App />
   - </BrowserRouter>
   
   // Just use App directly
   <App />
   ```

3. **Update navigation code**
   ```tsx
   // Change
   const navigate = useNavigate();
   
   // To
   const { navigate } = useNavigate();
   ```

4. **Replace dynamic routes**
   ```tsx
   // Instead of
   <Route path="/users/:id" element={<UserDetail />} />
   
   // Use
   <Route path="/users/detail" element={<UserDetail />} />
   
   // And navigate with state
   navigate('/users/detail', { state: { id: userId } });
   ```

5. **Add prerender for performance**
   ```tsx
   // Identify heavy components and add prerender
   <Route path="/dashboard" element={<Dashboard />} prerender />
   ```

### Benefits After Migration

1. **Better WebF Integration**: Direct integration with WebF's navigation system
2. **Flutter-like Navigation**: Access to methods like `popUntil`, `popAndPush`
3. **Performance**: Pre-rendering support for heavy components
4. **Simpler Setup**: No router wrapper components needed

### Need Help?

If you encounter issues during migration:
1. Check the [API documentation](./API.md)
2. Review the [examples](./examples) directory
3. Submit an issue on our GitHub repository