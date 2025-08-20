import { Suspense } from 'react';
import ClientCounter from './client-counter';

// Server Component that fetches data
async function ServerUserData() {
  // Simulate fetching user data from database
  await new Promise(resolve => setTimeout(resolve, 150));
  
  const userData = {
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    role: 'developer',
    lastLogin: new Date().toISOString(),
    preferences: {
      theme: 'dark',
      language: 'en',
      notifications: true
    }
  };

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #059669', 
      borderRadius: '8px',
      backgroundColor: '#f0fdf4',
      margin: '20px 0'
    }}>
      <h3>Server-Rendered User Data</h3>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        <div>
          <p><strong>ID:</strong> {userData.id}</p>
          <p><strong>Name:</strong> {userData.name}</p>
          <p><strong>Email:</strong> {userData.email}</p>
          <p><strong>Role:</strong> {userData.role}</p>
        </div>
        <div>
          <p><strong>Last Login:</strong> {userData.lastLogin}</p>
          <p><strong>Theme:</strong> {userData.preferences.theme}</p>
          <p><strong>Language:</strong> {userData.preferences.language}</p>
          <p><strong>Notifications:</strong> {userData.preferences.notifications ? 'Enabled' : 'Disabled'}</p>
        </div>
      </div>
    </div>
  );
}

// Server Component that renders a list
async function ServerProductList() {
  // Simulate API call to get products
  await new Promise(resolve => setTimeout(resolve, 100));
  
  const products = [
    { id: 1, name: 'WebF Runtime', price: 99.99, category: 'Software' },
    { id: 2, name: 'Flutter Widget', price: 49.99, category: 'UI Component' },
    { id: 3, name: 'React Hook', price: 29.99, category: 'Library' },
    { id: 4, name: 'Next.js Template', price: 79.99, category: 'Template' }
  ];

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #0891b2', 
      borderRadius: '8px',
      backgroundColor: '#f0f9ff',
      margin: '20px 0'
    }}>
      <h3>Server-Rendered Product List</h3>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px' }}>
        {products.map(product => (
          <div key={product.id} style={{
            padding: '15px',
            border: '1px solid #e5e7eb',
            borderRadius: '6px',
            backgroundColor: 'white'
          }}>
            <h4 style={{ margin: '0 0 10px 0', color: '#1f2937' }}>{product.name}</h4>
            <p style={{ margin: '5px 0', color: '#6b7280' }}>Category: {product.category}</p>
            <p style={{ margin: '5px 0', fontWeight: 'bold', color: '#059669' }}>${product.price}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function HybridPage() {
  return (
    <div style={{ padding: '40px', maxWidth: '1000px', margin: '0 auto' }}>
      <h1>Hybrid Server + Client Components</h1>
      <p>This page demonstrates the combination of Server Components (static data) and Client Components (interactive features).</p>
      
      {/* Server Components */}
      <Suspense fallback={
        <div style={{ 
          padding: '20px', 
          textAlign: 'center', 
          color: '#666',
          fontStyle: 'italic'
        }}>
          Loading user data...
        </div>
      }>
        <ServerUserData />
      </Suspense>

      <Suspense fallback={
        <div style={{ 
          padding: '20px', 
          textAlign: 'center', 
          color: '#666',
          fontStyle: 'italic'
        }}>
          Loading product list...
        </div>
      }>
        <ServerProductList />
      </Suspense>

      {/* Client Component */}
      <ClientCounter />

      <div style={{ 
        padding: '20px', 
        border: '2px solid #ff6b35', 
        borderRadius: '8px',
        backgroundColor: '#fff5f5',
        margin: '20px 0'
      }}>
        <h3>Hybrid Architecture Benefits</h3>
        <ul>
          <li><strong>Server Components:</strong> Fast initial load, SEO-friendly, no JavaScript bundle</li>
          <li><strong>Client Components:</strong> Interactive features, real-time updates, user interactions</li>
          <li><strong>Combined:</strong> Best of both worlds - fast loading with rich interactivity</li>
        </ul>
        
        <h4>Testing in WebF:</h4>
        <ul>
          <li>Server data should appear immediately without hydration</li>
          <li>Client counter requires JavaScript to function</li>
          <li>Page should be partially functional even with limited JS support</li>
        </ul>
      </div>

      <div style={{ marginTop: '40px' }}>
        <a 
          href="/"
          style={{ 
            color: '#0070f3', 
            textDecoration: 'none',
            fontSize: '16px'
          }}
        >
          ← Back to Home
        </a>
      </div>
    </div>
  );
}