'use client';

import { useState, useEffect } from 'react';

export default function ClientCounter() {
  const [count, setCount] = useState(0);
  const [isClient, setIsClient] = useState(false);
  const [interactions, setInteractions] = useState<string[]>([]);

  useEffect(() => {
    setIsClient(true);
  }, []);

  const handleIncrement = () => {
    setCount(prev => prev + 1);
    setInteractions(prev => [...prev, `Incremented to ${count + 1} at ${new Date().toLocaleTimeString()}`]);
  };

  const handleDecrement = () => {
    setCount(prev => prev - 1);
    setInteractions(prev => [...prev, `Decremented to ${count - 1} at ${new Date().toLocaleTimeString()}`]);
  };

  const handleReset = () => {
    setCount(0);
    setInteractions([]);
  };

  return (
    <div style={{ 
      padding: '20px', 
      border: '2px solid #7c3aed', 
      borderRadius: '8px',
      backgroundColor: '#faf5ff',
      margin: '20px 0'
    }}>
      <h3>Client Interactive Counter</h3>
      
      <div style={{ marginBottom: '20px' }}>
        <p><strong>Hydration Status:</strong> {isClient ? '✅ Hydrated' : '⏳ Server-side'}</p>
        <p><strong>Current Count:</strong> <span style={{ fontSize: '24px', fontWeight: 'bold', color: '#7c3aed' }}>{count}</span></p>
      </div>

      <div style={{ marginBottom: '20px' }}>
        <button 
          onClick={handleIncrement}
          disabled={!isClient}
          style={{
            padding: '10px 20px',
            backgroundColor: isClient ? '#059669' : '#9ca3af',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: isClient ? 'pointer' : 'not-allowed',
            marginRight: '10px',
            fontSize: '16px'
          }}
        >
          + Increment
        </button>
        <button 
          onClick={handleDecrement}
          disabled={!isClient}
          style={{
            padding: '10px 20px',
            backgroundColor: isClient ? '#dc2626' : '#9ca3af',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: isClient ? 'pointer' : 'not-allowed',
            marginRight: '10px',
            fontSize: '16px'
          }}
        >
          - Decrement
        </button>
        <button 
          onClick={handleReset}
          disabled={!isClient}
          style={{
            padding: '10px 20px',
            backgroundColor: isClient ? '#6b7280' : '#9ca3af',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: isClient ? 'pointer' : 'not-allowed',
            fontSize: '16px'
          }}
        >
          Reset
        </button>
      </div>

      {interactions.length > 0 && (
        <div style={{
          backgroundColor: '#f9fafb',
          border: '1px solid #e5e7eb',
          borderRadius: '4px',
          padding: '15px',
          maxHeight: '150px',
          overflowY: 'auto'
        }}>
          <h4 style={{ margin: '0 0 10px 0', fontSize: '14px', color: '#6b7280' }}>Interaction History:</h4>
          {interactions.slice(-5).map((interaction, index) => (
            <p key={index} style={{ 
              margin: '5px 0', 
              fontSize: '12px', 
              color: '#374151',
              fontFamily: 'monospace'
            }}>
              {interaction}
            </p>
          ))}
        </div>
      )}
    </div>
  );
}