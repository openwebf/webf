import React from 'react';
import { useParams, useLocation, WebFRouter } from '../../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const ReportDetailsPage: React.FC = () => {
  const params = useParams();
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
        Report Details
      </h1>
        
        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
            Report Parameters:
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
              <strong>Year:</strong> {params.year || 'Not provided'}
            </p>
            <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
              <strong>Month:</strong> {params.month || 'Not provided'}
            </p>
            <p style={{ margin: '0 0 8px 0', fontFamily: 'monospace', color: 'var(--font-color)' }}>
              <strong>Report ID:</strong> {params.reportId || 'Not provided'}
            </p>
          </div>
        </div>

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
            Report Information:
          </h2>
          <div style={{
            backgroundColor: 'var(--background-tertiary)',
            padding: '16px',
            borderRadius: '8px',
            border: '1px solid var(--border-color)'
          }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <h3 style={{ fontSize: '14px', margin: '0 0 8px 0', color: 'var(--secondary-font-color)' }}>Period</h3>
                <p style={{ fontSize: '16px', margin: 0, color: 'var(--font-color)' }}>
                  {params.month}/{params.year}
                </p>
              </div>
              <div>
                <h3 style={{ fontSize: '14px', margin: '0 0 8px 0', color: 'var(--secondary-font-color)' }}>Department</h3>
                <p style={{ fontSize: '16px', margin: 0, textTransform: 'capitalize', color: 'var(--font-color)' }}>
                  {location.state?.department || 'Not specified'}
                </p>
              </div>
              <div>
                <h3 style={{ fontSize: '14px', margin: '0 0 8px 0', color: 'var(--secondary-font-color)' }}>Format</h3>
                <p style={{ fontSize: '16px', margin: 0, textTransform: 'uppercase', color: 'var(--font-color)' }}>
                  {location.state?.format || 'Not specified'}
                </p>
              </div>
              <div>
                <h3 style={{ fontSize: '14px', margin: '0 0 8px 0', color: 'var(--secondary-font-color)' }}>Report ID</h3>
                <p style={{ fontSize: '16px', margin: 0, fontFamily: 'monospace', color: 'var(--font-color)' }}>
                  {params.reportId}
                </p>
              </div>
            </div>
          </div>
        </div>

        <div style={{ marginBottom: '20px' }}>
          <h2 style={{ fontSize: '18px', marginBottom: '12px', color: 'var(--font-color-primary)' }}>
            Navigation State:
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

        <div style={{ display: 'flex' }}>
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
            Back to Home
          </button>
        </div>
    </WebFListView>
  );
};
