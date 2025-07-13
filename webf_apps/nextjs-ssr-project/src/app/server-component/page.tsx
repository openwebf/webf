import { Suspense } from 'react';

// Server Component that fetches data
async function ServerDataComponent() {
  // Simulate server-side data fetching
  await new Promise(resolve => setTimeout(resolve, 100));
  
  const data = {
    timestamp: new Date().toISOString(),
    serverMessage: 'This was rendered on the server!',
    randomNumber: Math.floor(Math.random() * 1000)
  };

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #0070f3', 
      borderRadius: '8px',
      backgroundColor: '#f9f9f9',
      margin: '20px 0'
    }}>
      <h3>Server Component Data</h3>
      <p><strong>Message:</strong> {data.serverMessage}</p>
      <p><strong>Server Timestamp:</strong> {data.timestamp}</p>
      <p><strong>Random Number:</strong> {data.randomNumber}</p>
    </div>
  );
}

// Another server component that simulates API call
async function ServerApiComponent() {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 200));
  
  const apiData = {
    version: '1.0.0',
    environment: 'server',
    features: ['SSR', 'Server Components', 'React 19']
  };

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #00aa00', 
      borderRadius: '8px',
      backgroundColor: '#f0fff0',
      margin: '20px 0'
    }}>
      <h3>Server API Component</h3>
      <p><strong>Version:</strong> {apiData.version}</p>
      <p><strong>Environment:</strong> {apiData.environment}</p>
      <p><strong>Features:</strong></p>
      <ul>
        {apiData.features.map((feature, index) => (
          <li key={index}>{feature}</li>
        ))}
      </ul>
    </div>
  );
}

export default function ServerComponentPage() {
  return (
    <div style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>Server Components Test</h1>
      <p>This page demonstrates Next.js Server Components that render on the server.</p>
      
      <Suspense fallback={
        <div style={{ 
          padding: '20px', 
          textAlign: 'center', 
          color: '#666',
          fontStyle: 'italic'
        }}>
          Loading server component...
        </div>
      }>
        <ServerDataComponent />
      </Suspense>

      <Suspense fallback={
        <div style={{ 
          padding: '20px', 
          textAlign: 'center', 
          color: '#666',
          fontStyle: 'italic'
        }}>
          Loading API component...
        </div>
      }>
        <ServerApiComponent />
      </Suspense>

      <div style={{ 
        padding: '20px', 
        border: '2px solid #ff6b35', 
        borderRadius: '8px',
        backgroundColor: '#fff5f5',
        margin: '20px 0'
      }}>
        <h3>Testing Notes</h3>
        <p>When testing in WebF:</p>
        <ul>
          <li>Server components should render their content immediately</li>
          <li>No JavaScript hydration should be required for these components</li>
          <li>Data should be available on initial page load</li>
          <li>Timestamps and random numbers should remain static after render</li>
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