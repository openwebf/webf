import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const EnhancedRoutingDemo: React.FC = () => {
  const testDynamicRoutes = () => {
    const userId = Math.floor(Math.random() * 1000);
    
    window.webf.hybridHistory.pushState({
      userId: userId,
      userType: 'premium'
    }, `/user/${userId}`);
  };

  const testComplexRoutes = () => {
    const year = new Date().getFullYear();
    const month = String(new Date().getMonth() + 1).padStart(2, '0');
    const reportId = `report-${Math.floor(Math.random() * 1000)}`;
    window.webf.hybridHistory.pushState({
      year,
      month,
      reportId,
      department: 'sales',
      format: 'pdf',
      metadata: {
        timestamp: Date.now(),
        generator: 'auto'
      }
    }, `/dashboard/${year}/${month}/reports/${reportId}`);
  };

  const testDirectNavigation = () => {
    window.webf.hybridHistory.pushState({
      formData: {
        name: 'John Doe',
        email: 'john@example.com',
        preferences: {
          theme: 'dark',
          language: 'en'
        }
      },
      scrollPosition: 250,
      editMode: true,
      lastModified: Date.now()
    }, '/profile/edit');
  };

  const routingFeatures = [
    {
      title: 'Dynamic Routes',
      example: '/user/:id - Single parameter routing',
      testFunction: testDynamicRoutes,
      description: 'Navigate to routes with dynamic parameters'
    },
    {
      title: 'Complex Multi-Parameter Routes',
      example: '/dashboard/:year/:month/reports/:id',
      testFunction: testComplexRoutes,
      description: 'Handle routes with multiple nested parameters'
    },
    {
      title: 'Direct Page Navigation',
      example: 'Skip intermediate pages with state',
      testFunction: testDirectNavigation,
      description: 'Navigate directly to specific pages while preserving navigation context'
    }
  ];

  return (
    <WebFListView style={{ padding: '16px', backgroundColor: 'var(--background-color)' }}>
      <h2 style={{ 
        fontSize: '20px', 
        marginBottom: '16px',
        color: 'var(--font-color-primary)'
      }}>
        Enhanced Routing
      </h2>
      
      {routingFeatures.map((feature, index) => (
        <div key={index} style={{
          backgroundColor: 'var(--background-secondary)',
          borderRadius: '8px',
          padding: '16px',
          marginBottom: '12px',
          border: '1px solid var(--border-color)'
        }}>
          <div style={{ marginBottom: '12px' }}>
            <h3 style={{ 
              fontSize: '16px', 
              fontWeight: '600', 
              marginBottom: '6px',
              color: 'var(--font-color-primary)'
            }}>
              {feature.title}
            </h3>
            <p style={{
              fontSize: '14px',
              color: 'var(--secondary-font-color)',
              marginBottom: '8px',
              lineHeight: '1.4'
            }}>
              {feature.description}
            </p>
            <code style={{ 
              fontSize: '12px',
              color: 'var(--font-color-primary)',
              backgroundColor: 'var(--background-tertiary)',
              padding: '4px 8px',
              borderRadius: '4px',
              border: '1px solid var(--border-color)',
              display: 'inline-block'
            }}>
              {feature.example}
            </code>
          </div>

          <button
            onClick={feature.testFunction}
            style={{
              background: '#007aff',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              padding: '10px 16px',
              fontSize: '14px',
              cursor: 'pointer',
              fontWeight: '500'
            }}
          >
            Test {feature.title}
          </button>
        </div>
      ))}
    </WebFListView>
  );
};