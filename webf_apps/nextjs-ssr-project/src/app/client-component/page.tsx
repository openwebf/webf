'use client';

import { useState, useEffect } from 'react';

function ClientInteractiveComponent() {
  const [count, setCount] = useState(0);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #9333ea', 
      borderRadius: '8px',
      backgroundColor: '#faf5ff',
      margin: '20px 0'
    }}>
      <h3>Client Interactive Component</h3>
      <p><strong>Mounted:</strong> {mounted ? 'Yes' : 'No'}</p>
      <p><strong>Count:</strong> {count}</p>
      <button 
        onClick={() => setCount(count + 1)}
        style={{
          padding: '10px 20px',
          backgroundColor: '#9333ea',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
          marginRight: '10px'
        }}
      >
        Increment
      </button>
      <button 
        onClick={() => setCount(0)}
        style={{
          padding: '10px 20px',
          backgroundColor: '#dc2626',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer'
        }}
      >
        Reset
      </button>
    </div>
  );
}

function ClientTimerComponent() {
  const [time, setTime] = useState<string>('');

  useEffect(() => {
    const updateTime = () => {
      setTime(new Date().toLocaleTimeString());
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #ea580c', 
      borderRadius: '8px',
      backgroundColor: '#fff7ed',
      margin: '20px 0'
    }}>
      <h3>Client Timer Component</h3>
      <p><strong>Current Time:</strong> {time || 'Loading...'}</p>
      <p>This timer updates every second using client-side JavaScript.</p>
    </div>
  );
}

export default function ClientComponentPage() {
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
  }, []);

  return (
    <div style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>Client Components Test</h1>
      <p>This page demonstrates Next.js Client Components that require JavaScript hydration.</p>
      
      <div style={{ 
        padding: '20px', 
        border: '2px solid #0891b2', 
        borderRadius: '8px',
        backgroundColor: '#f0f9ff',
        margin: '20px 0'
      }}>
        <h3>Hydration Status</h3>
        <p><strong>Page Hydrated:</strong> {hydrated ? 'Yes' : 'No'}</p>
        <p>This indicates whether React has taken control on the client side.</p>
      </div>

      <ClientInteractiveComponent />
      <ClientTimerComponent />

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
          <li>These components require JavaScript to be interactive</li>
          <li>Initial render should show static content</li>
          <li>After hydration, buttons should be clickable</li>
          <li>Timer should start updating after hydration</li>
          <li>WebF needs to support React event handlers and state updates</li>
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