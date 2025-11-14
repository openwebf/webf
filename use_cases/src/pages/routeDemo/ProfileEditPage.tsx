import React from 'react';
import { useLocation, WebFRouter } from '../../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const ProfileEditPage: React.FC = () => {
  const location = useLocation();

  return (
    <WebFListView style={{
      padding: '20px',
      backgroundColor: 'var(--background-secondary)',
      borderRadius: '12px',
      marginBottom: '20px',
      border: '1px solid var(--border-color)'
    }}>
      <h1 style={{
        fontSize: '24px',
        marginBottom: '16px',
        color: 'var(--font-color-primary)'
      }}>
        Edit Profile
      </h1>

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
            Deep Link Navigation Demo
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            <p style={{ margin: '0 0 8px 0', color: 'var(--secondary-font-color)' }}>
              This page demonstrates direct deep-link navigation.
            </p>
            <p style={{ margin: '0', color: 'var(--secondary-font-color)' }}>
              When you click "Back", it will return to the home page instead of the previous route.
            </p>
          </div>
        </div>
        
        {location.state?.formData && (
          <div style={{ marginBottom: '20px' }}>
            <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
              Form Data:
            </h2>
            <div style={{
              backgroundColor: 'var(--background-tertiary)',
              padding: '16px',
              borderRadius: '8px',
              border: '1px solid var(--border-color)'
            }}>
              <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
                <strong>Name:</strong> {location.state.formData.name || 'Not provided'}
              </p>
              <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
                <strong>Email:</strong> {location.state.formData.email || 'Not provided'}
              </p>
              {location.state.formData.preferences && (
                <div style={{ marginTop: '12px' }}>
                  <p style={{ margin: '0 0 8px 0', fontWeight: 'bold', color: 'var(--font-color)' }}>Preferences:</p>
                  <div style={{ paddingLeft: '16px' }}>
                    <p style={{ margin: '0 0 4px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
                      <strong>Theme:</strong> {location.state.formData.preferences.theme}
                    </p>
                    <p style={{ margin: '0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
                      <strong>Language:</strong> {location.state.formData.preferences.language}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
            Session Information:
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            {location.state?.editMode && (
              <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
                <strong>Edit Mode:</strong> {location.state.editMode ? 'Enabled' : 'Disabled'}
              </p>
            )}
            {location.state?.scrollPosition && (
              <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
                <strong>Scroll Position:</strong> {location.state.scrollPosition}px
              </p>
            )}
            {location.state?.lastModified && (
              <p style={{ margin: '0', fontFamily: 'monospace' }}>
                <strong>Last Modified:</strong> {new Date(location.state.lastModified).toLocaleString()}
              </p>
            )}
          </div>
        </div>

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
            Complete State:
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

        <button
          onClick={() => WebFRouter.pushState({}, '/')}
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
          Back to Home (Deep Link Navigation)
        </button>
    </WebFListView>
  );
};
