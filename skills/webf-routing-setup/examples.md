# WebF Routing - Complete Examples

## Example 1: Basic Multi-Screen App (React)

A simple app with three screens: Home, Profile, and Settings.

```jsx
// src/App.jsx
import { Routes, Route } from '@openwebf/react-router';
import HomePage from './pages/HomePage';
import ProfilePage from './pages/ProfilePage';
import SettingsPage from './pages/SettingsPage';

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} title="Home" />
      <Route path="/profile" element={<ProfilePage />} title="Profile" />
      <Route path="/settings" element={<SettingsPage />} title="Settings" />
    </Routes>
  );
}

export default App;
```

```jsx
// src/pages/HomePage.jsx
import { WebFRouter } from '@openwebf/react-router';

function HomePage() {
  const goToProfile = () => {
    WebFRouter.pushState({}, '/profile');
  };

  const goToSettings = () => {
    WebFRouter.pushState({}, '/settings');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Home Page</h1>
      <p>Welcome to the home page!</p>

      <div style={{ marginTop: '20px' }}>
        <button onClick={goToProfile} style={{ marginRight: '10px' }}>
          View Profile
        </button>
        <button onClick={goToSettings}>
          Settings
        </button>
      </div>
    </div>
  );
}

export default HomePage;
```

```jsx
// src/pages/ProfilePage.jsx
import { WebFRouter } from '@openwebf/react-router';

function ProfilePage() {
  const goBack = () => {
    WebFRouter.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Profile Page</h1>
      <p>This is your profile.</p>

      <button onClick={goBack}>
        Go Back
      </button>
    </div>
  );
}

export default ProfilePage;
```

```jsx
// src/pages/SettingsPage.jsx
import { WebFRouter } from '@openwebf/react-router';

function SettingsPage() {
  const goHome = () => {
    // Replace current screen with home (no back button)
    WebFRouter.replaceState({}, '/');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Settings</h1>
      <p>App settings go here.</p>

      <button onClick={goHome}>
        Go Home (Replace)
      </button>
    </div>
  );
}

export default SettingsPage;
```

## Example 2: Passing Data Between Screens

Shopping app with product list and detail screens.

```jsx
// src/App.jsx
import { Routes, Route } from '@openwebf/react-router';
import ProductListPage from './pages/ProductListPage';
import ProductDetailPage from './pages/ProductDetailPage';
import CartPage from './pages/CartPage';

function App() {
  return (
    <Routes>
      <Route path="/" element={<ProductListPage />} title="Products" />
      <Route path="/product/detail" element={<ProductDetailPage />} title="Product Detail" />
      <Route path="/cart" element={<CartPage />} title="Shopping Cart" />
    </Routes>
  );
}

export default App;
```

```jsx
// src/pages/ProductListPage.jsx
import { WebFRouter } from '@openwebf/react-router';

const PRODUCTS = [
  { id: 1, name: 'Laptop', price: 999.99, description: 'Powerful laptop for work' },
  { id: 2, name: 'Mouse', price: 29.99, description: 'Wireless mouse' },
  { id: 3, name: 'Keyboard', price: 79.99, description: 'Mechanical keyboard' }
];

function ProductListPage() {
  const viewProduct = (product) => {
    // Pass entire product object to detail screen
    WebFRouter.pushState({
      product: product,
      source: 'list'
    }, '/product/detail');
  };

  const goToCart = () => {
    WebFRouter.pushState({}, '/cart');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Products</h1>

      <div style={{ marginBottom: '20px' }}>
        <button onClick={goToCart}>
          View Cart
        </button>
      </div>

      <div>
        {PRODUCTS.map(product => (
          <div
            key={product.id}
            style={{
              border: '1px solid #ccc',
              padding: '15px',
              marginBottom: '10px',
              borderRadius: '5px'
            }}
          >
            <h3>{product.name}</h3>
            <p>${product.price}</p>
            <button onClick={() => viewProduct(product)}>
              View Details
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ProductListPage;
```

```jsx
// src/pages/ProductDetailPage.jsx
import { useState } from 'react';
import { WebFRouter, useLocation } from '@openwebf/react-router';

function ProductDetailPage() {
  const location = useLocation();
  const { product, source } = location.state || {};
  const [quantity, setQuantity] = useState(1);

  if (!product) {
    return (
      <div style={{ padding: '20px' }}>
        <p>No product data found.</p>
        <button onClick={() => WebFRouter.back()}>
          Go Back
        </button>
      </div>
    );
  }

  const addToCart = () => {
    // In a real app, you'd add to cart state/context
    console.log(`Added ${quantity} x ${product.name} to cart`);

    // Navigate to cart with confirmation
    WebFRouter.pushState({
      addedProduct: product,
      addedQuantity: quantity
    }, '/cart');
  };

  const goBack = () => {
    WebFRouter.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>{product.name}</h1>
      <p style={{ fontSize: '24px', color: '#0066cc' }}>
        ${product.price}
      </p>
      <p>{product.description}</p>

      <div style={{ marginTop: '20px' }}>
        <label>
          Quantity:
          <input
            type="number"
            min="1"
            value={quantity}
            onChange={(e) => setQuantity(parseInt(e.target.value))}
            style={{ marginLeft: '10px', width: '60px' }}
          />
        </label>
      </div>

      <div style={{ marginTop: '20px' }}>
        <button
          onClick={addToCart}
          style={{ marginRight: '10px', padding: '10px 20px' }}
        >
          Add to Cart
        </button>
        <button onClick={goBack} style={{ padding: '10px 20px' }}>
          Back
        </button>
      </div>

      {source && (
        <p style={{ marginTop: '20px', fontSize: '12px', color: '#666' }}>
          Came from: {source}
        </p>
      )}
    </div>
  );
}

export default ProductDetailPage;
```

```jsx
// src/pages/CartPage.jsx
import { useLocation, WebFRouter } from '@openwebf/react-router';

function CartPage() {
  const location = useLocation();
  const { addedProduct, addedQuantity } = location.state || {};

  const goBack = () => {
    WebFRouter.back();
  };

  const continueShopping = () => {
    // Go back to product list (could use replaceState to prevent back navigation)
    WebFRouter.pushState({}, '/');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Shopping Cart</h1>

      {addedProduct && (
        <div style={{
          backgroundColor: '#d4edda',
          padding: '15px',
          borderRadius: '5px',
          marginBottom: '20px'
        }}>
          <strong>✓ Added to cart:</strong> {addedQuantity} x {addedProduct.name}
        </div>
      )}

      <p>Your cart items would appear here.</p>

      <div style={{ marginTop: '20px' }}>
        <button onClick={continueShopping} style={{ marginRight: '10px' }}>
          Continue Shopping
        </button>
        <button onClick={goBack}>
          Go Back
        </button>
      </div>
    </div>
  );
}

export default CartPage;
```

## Example 3: Dynamic Routes with Parameters

Blog app with dynamic post IDs.

```jsx
// src/App.jsx
import { Routes, Route } from '@openwebf/react-router';
import BlogListPage from './pages/BlogListPage';
import BlogPostPage from './pages/BlogPostPage';
import AuthorPage from './pages/AuthorPage';

function App() {
  return (
    <Routes>
      <Route path="/" element={<BlogListPage />} title="Blog" />
      <Route path="/post/:postId" element={<BlogPostPage />} title="Post" />
      <Route path="/author/:authorId" element={<AuthorPage />} title="Author" />
    </Routes>
  );
}

export default App;
```

```jsx
// src/pages/BlogListPage.jsx
import { WebFRouter } from '@openwebf/react-router';

const POSTS = [
  { id: '1', title: 'Getting Started with WebF', authorId: 'alice' },
  { id: '2', title: 'Understanding Async Rendering', authorId: 'bob' },
  { id: '3', title: 'Hybrid Routing Explained', authorId: 'alice' }
];

function BlogListPage() {
  const viewPost = (postId) => {
    // Navigate using route parameter
    WebFRouter.pushState({}, `/post/${postId}`);
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Blog Posts</h1>

      <div>
        {POSTS.map(post => (
          <div
            key={post.id}
            style={{
              border: '1px solid #ccc',
              padding: '15px',
              marginBottom: '10px',
              borderRadius: '5px'
            }}
          >
            <h3>{post.title}</h3>
            <p>By: {post.authorId}</p>
            <button onClick={() => viewPost(post.id)}>
              Read Post
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default BlogListPage;
```

```jsx
// src/pages/BlogPostPage.jsx
import { useParams, WebFRouter } from '@openwebf/react-router';

const POSTS = {
  '1': {
    id: '1',
    title: 'Getting Started with WebF',
    content: 'WebF is a W3C/WHATWG-compliant web runtime for Flutter...',
    authorId: 'alice',
    authorName: 'Alice Smith'
  },
  '2': {
    id: '2',
    title: 'Understanding Async Rendering',
    content: 'WebF uses async rendering which is different from browsers...',
    authorId: 'bob',
    authorName: 'Bob Johnson'
  },
  '3': {
    id: '3',
    title: 'Hybrid Routing Explained',
    content: 'Each route in WebF is a separate Flutter screen...',
    authorId: 'alice',
    authorName: 'Alice Smith'
  }
};

function BlogPostPage() {
  // Extract postId from URL parameter
  const { postId } = useParams();
  const post = POSTS[postId];

  if (!post) {
    return (
      <div style={{ padding: '20px' }}>
        <h1>Post Not Found</h1>
        <button onClick={() => WebFRouter.back()}>
          Go Back
        </button>
      </div>
    );
  }

  const viewAuthor = () => {
    WebFRouter.pushState(
      { authorName: post.authorName },
      `/author/${post.authorId}`
    );
  };

  const goBack = () => {
    WebFRouter.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>{post.title}</h1>

      <p style={{ color: '#666', marginBottom: '20px' }}>
        By <button onClick={viewAuthor} style={{ textDecoration: 'underline' }}>
          {post.authorName}
        </button>
      </p>

      <div style={{ lineHeight: '1.6', marginBottom: '20px' }}>
        {post.content}
      </div>

      <button onClick={goBack}>
        Back to Posts
      </button>
    </div>
  );
}

export default BlogPostPage;
```

```jsx
// src/pages/AuthorPage.jsx
import { useParams, useLocation, WebFRouter } from '@openwebf/react-router';

function AuthorPage() {
  const { authorId } = useParams();
  const location = useLocation();
  const { authorName } = location.state || {};

  const goBack = () => {
    WebFRouter.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Author: {authorName || authorId}</h1>
      <p>Author ID: {authorId}</p>
      <p>This would show the author's profile and posts.</p>

      <button onClick={goBack}>
        Go Back
      </button>
    </div>
  );
}

export default AuthorPage;
```

## Example 4: Authentication Flow

Login flow with protected routes and redirect after authentication.

```jsx
// src/App.jsx
import { Routes, Route } from '@openwebf/react-router';
import { useState } from 'react';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ProfilePage from './pages/ProfilePage';
import ProtectedRoute from './components/ProtectedRoute';

function App() {
  const [user, setUser] = useState(null);

  return (
    <Routes>
      <Route
        path="/login"
        element={<LoginPage setUser={setUser} />}
        title="Login"
      />
      <Route
        path="/"
        element={
          <ProtectedRoute user={user}>
            <DashboardPage user={user} />
          </ProtectedRoute>
        }
        title="Dashboard"
      />
      <Route
        path="/profile"
        element={
          <ProtectedRoute user={user}>
            <ProfilePage user={user} setUser={setUser} />
          </ProtectedRoute>
        }
        title="Profile"
      />
    </Routes>
  );
}

export default App;
```

```jsx
// src/components/ProtectedRoute.jsx
import { useEffect } from 'react';
import { WebFRouter, useLocation } from '@openwebf/react-router';

function ProtectedRoute({ children, user }) {
  const location = useLocation();

  useEffect(() => {
    if (!user) {
      // Save current path for redirect after login
      WebFRouter.replaceState({
        redirectTo: location.pathname
      }, '/login');
    }
  }, [user, location.pathname]);

  if (!user) {
    return null; // Or a loading spinner
  }

  return children;
}

export default ProtectedRoute;
```

```jsx
// src/pages/LoginPage.jsx
import { useState } from 'react';
import { WebFRouter, useLocation } from '@openwebf/react-router';

function LoginPage({ setUser }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const location = useLocation();
  const redirectTo = location.state?.redirectTo || '/';

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    // Simulate login
    if (email && password) {
      // In real app, call authentication API
      const user = {
        id: 1,
        email: email,
        name: 'John Doe'
      };

      setUser(user);

      // Redirect to saved location or home
      WebFRouter.replaceState({}, redirectTo);
    } else {
      setError('Please enter email and password');
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '400px', margin: '0 auto' }}>
      <h1>Login</h1>

      {redirectTo !== '/' && (
        <p style={{ color: '#666', marginBottom: '20px' }}>
          Please log in to continue to {redirectTo}
        </p>
      )}

      <form onSubmit={handleLogin}>
        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>
            Email:
          </label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{ width: '100%', padding: '8px' }}
          />
        </div>

        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>
            Password:
          </label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={{ width: '100%', padding: '8px' }}
          />
        </div>

        {error && (
          <p style={{ color: 'red', marginBottom: '15px' }}>{error}</p>
        )}

        <button type="submit" style={{ width: '100%', padding: '10px' }}>
          Log In
        </button>
      </form>
    </div>
  );
}

export default LoginPage;
```

```jsx
// src/pages/DashboardPage.jsx
import { WebFRouter } from '@openwebf/react-router';

function DashboardPage({ user }) {
  const goToProfile = () => {
    WebFRouter.pushState({}, '/profile');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Dashboard</h1>
      <p>Welcome, {user.name}!</p>

      <div style={{ marginTop: '20px' }}>
        <button onClick={goToProfile}>
          View Profile
        </button>
      </div>
    </div>
  );
}

export default DashboardPage;
```

```jsx
// src/pages/ProfilePage.jsx
import { WebFRouter } from '@openwebf/react-router';

function ProfilePage({ user, setUser }) {
  const handleLogout = () => {
    setUser(null);
    WebFRouter.replaceState({}, '/login');
  };

  const goBack = () => {
    WebFRouter.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Profile</h1>
      <p><strong>Name:</strong> {user.name}</p>
      <p><strong>Email:</strong> {user.email}</p>
      <p><strong>ID:</strong> {user.id}</p>

      <div style={{ marginTop: '20px' }}>
        <button onClick={handleLogout} style={{ marginRight: '10px' }}>
          Log Out
        </button>
        <button onClick={goBack}>
          Back to Dashboard
        </button>
      </div>
    </div>
  );
}

export default ProfilePage;
```

## Example 5: Tabs with Navigation

App with tab navigation and nested routes.

```jsx
// src/App.jsx
import { Routes, Route } from '@openwebf/react-router';
import TabsLayout from './layouts/TabsLayout';
import HomePage from './pages/tabs/HomePage';
import ExplorePage from './pages/tabs/ExplorePage';
import NotificationsPage from './pages/tabs/NotificationsPage';
import ProfilePage from './pages/tabs/ProfilePage';
import SettingsPage from './pages/SettingsPage';

function App() {
  return (
    <Routes>
      {/* Tab routes wrapped in TabsLayout */}
      <Route path="/" element={<TabsLayout><HomePage /></TabsLayout>} title="Home" />
      <Route path="/explore" element={<TabsLayout><ExplorePage /></TabsLayout>} title="Explore" />
      <Route path="/notifications" element={<TabsLayout><NotificationsPage /></TabsLayout>} title="Notifications" />
      <Route path="/profile" element={<TabsLayout><ProfilePage /></TabsLayout>} title="Profile" />

      {/* Full screen routes (no tabs) */}
      <Route path="/settings" element={<SettingsPage />} title="Settings" />
    </Routes>
  );
}

export default App;
```

```jsx
// src/layouts/TabsLayout.jsx
import { WebFRouter, useLocation } from '@openwebf/react-router';

function TabsLayout({ children }) {
  const location = useLocation();
  const currentPath = location.pathname;

  const tabs = [
    { path: '/', label: 'Home' },
    { path: '/explore', label: 'Explore' },
    { path: '/notifications', label: 'Notifications' },
    { path: '/profile', label: 'Profile' }
  ];

  const navigateToTab = (path) => {
    if (path !== currentPath) {
      WebFRouter.pushState({}, path);
    }
  };

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Content area */}
      <div style={{ flex: 1, overflow: 'auto' }}>
        {children}
      </div>

      {/* Tab bar */}
      <div style={{
        display: 'flex',
        borderTop: '1px solid #ccc',
        backgroundColor: '#f8f8f8'
      }}>
        {tabs.map(tab => (
          <button
            key={tab.path}
            onClick={() => navigateToTab(tab.path)}
            style={{
              flex: 1,
              padding: '15px',
              border: 'none',
              backgroundColor: currentPath === tab.path ? '#007bff' : 'transparent',
              color: currentPath === tab.path ? 'white' : '#333',
              fontWeight: currentPath === tab.path ? 'bold' : 'normal'
            }}
          >
            {tab.label}
          </button>
        ))}
      </div>
    </div>
  );
}

export default TabsLayout;
```

```jsx
// src/pages/tabs/HomePage.jsx
import { WebFRouter } from '@openwebf/react-router';

function HomePage() {
  const goToSettings = () => {
    // Navigate to full-screen settings (no tabs)
    WebFRouter.pushState({}, '/settings');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Home</h1>
      <p>Welcome to the home tab!</p>

      <button onClick={goToSettings} style={{ marginTop: '20px' }}>
        Open Settings
      </button>
    </div>
  );
}

export default HomePage;
```

```jsx
// src/pages/tabs/ProfilePage.jsx
function ProfilePage() {
  return (
    <div style={{ padding: '20px' }}>
      <h1>Profile</h1>
      <p>Your profile information.</p>
    </div>
  );
}

export default ProfilePage;
```

```jsx
// src/pages/SettingsPage.jsx
import { WebFRouter } from '@openwebf/react-router';

function SettingsPage() {
  const goBack = () => {
    WebFRouter.back();
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Settings</h1>
      <p>App settings (full screen, no tabs).</p>

      <button onClick={goBack} style={{ marginTop: '20px' }}>
        Back
      </button>
    </div>
  );
}

export default SettingsPage;
```

## Key Patterns Summary

### Pattern 1: Basic Navigation
```jsx
WebFRouter.pushState({}, '/path');
```

### Pattern 2: Pass Data
```jsx
WebFRouter.pushState({ data: value }, '/path');
```

### Pattern 3: Access Data
```jsx
const location = useLocation();
const data = location.state?.data;
```

### Pattern 4: Route Parameters
```jsx
// Define route: /user/:userId
const { userId } = useParams();
```

### Pattern 5: Replace (No Back Button)
```jsx
WebFRouter.replaceState({}, '/path');
```

### Pattern 6: Go Back
```jsx
WebFRouter.back();
```

### Pattern 7: Protected Routes
```jsx
<ProtectedRoute user={user}>
  <Component />
</ProtectedRoute>
```

## Testing Navigation

To test navigation in development:

1. **Check route transitions**: Verify native transitions happen
2. **Test back button**: Hardware back button should work on Android
3. **Verify state passing**: Data should persist between screens
4. **Test deep linking**: Direct URLs should work
5. **Check lifecycle**: Components should mount/unmount correctly

## Common Issues and Solutions

### Issue: "Cannot read property 'state' of undefined"
**Cause**: Accessing `location.state` when no state was passed
**Solution**: Use optional chaining or default values
```jsx
const data = location.state?.data || defaultValue;
```

### Issue: Navigation doesn't work
**Cause**: Using react-router-dom instead of @openwebf/react-router
**Solution**: Install and import correct package
```bash
npm install @openwebf/react-router
```

### Issue: Back button goes to wrong screen
**Cause**: Using `pushState` when should use `replaceState`
**Solution**: Use `replaceState` for redirects
```jsx
// After login, replace login screen
WebFRouter.replaceState({}, '/dashboard');
```
