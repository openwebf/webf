import React from 'react';
import { useParams, useLocation } from '@openwebf/react-router';
import { WebFListView } from '@openwebf/react-core-ui';

export const UserDetailsPage: React.FC = () => {
  
  const params = useParams();
  const location = useLocation();

  return (
    <WebFListView style={{ padding: '20px' }}>
      <div style={{
        backgroundColor: 'var(--background-secondary)',
        borderRadius: '12px',
        padding: '24px',
        marginBottom: '20px',
        border: '1px solid var(--border-color)'
      }}>
        <h1 style={{ 
          fontSize: '24px', 
          marginBottom: '16px',
          color: 'var(--font-color-primary)'
        }}>
          User Details
        </h1>
        
        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ 
            fontSize: '18px', 
            marginBottom: '12px', 
            color: 'var(--font-color-primary)' 
          }}>
            Route Parameters:
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            <p style={{ 
              margin: '0 0 8px 0', 
              fontFamily: 'monospace',
              color: 'var(--font-color)'
            }}>
              <strong>userId:</strong> {params.userId || 'Not provided'}
            </p>
            {params.userType && (
              <p style={{ 
                margin: '0', 
                fontFamily: 'monospace',
                color: 'var(--font-color)'
              }}>
                <strong>userType:</strong> {params.userType}
              </p>
            )}
          </div>
        </div>

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ 
            fontSize: '18px', 
            marginBottom: '12px', 
            color: 'var(--font-color-primary)' 
          }}>
            Location State:
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            <pre style={{ 
              margin: 0, 
              fontSize: '12px',
              fontFamily: 'monospace',
              whiteSpace: 'pre-wrap',
              color: 'var(--font-color)'
            }}>
              {JSON.stringify(location.state, null, 2)}
            </pre>
          </div>
        </div>

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ 
            fontSize: '18px', 
            marginBottom: '12px', 
            color: 'var(--font-color-primary)' 
          }}>
            Current Path:
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            <p style={{ 
              margin: 0, 
              fontFamily: 'monospace',
              color: 'var(--font-color)'
            }}>
              {location.pathname}
            </p>
          </div>
        </div>

        <button
          onClick={() => window.webf.hybridHistory.pushState({}, '/')}
          style={{
            background: '#007aff',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            padding: '12px 24px',
            fontSize: '16px',
            cursor: 'pointer'
          }}
        >
          Back to Home
        </button>
        <button
          onClick={() => window.webf.hybridHistory.pushState({}, '/user/888')}
          style={{
            background: '#007aff',
            color: 'white',
            border: 'none',
            marginLeft: '10px',
            borderRadius: '8px',
            padding: '12px 24px',
            fontSize: '16px',
            cursor: 'pointer'
          }}
        >
          Go User Details 888
        </button>
      </div>
    </WebFListView>
  );
};