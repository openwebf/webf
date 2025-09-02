import React, { useEffect, useRef } from 'react';
import { FlutterCupertinoTabBar, FlutterCupertinoTabBarItem } from '@openwebf/react-cupertino-ui';
import { RoutingDemo } from '../components/RoutingDemo';
import { EnhancedRoutingDemo } from '../components/EnhancedRoutingDemo';
import { WebFRouter } from '@openwebf/react-router';
import TabBarManager from '../utils/tabBarManager';


export const RoutingPage: React.FC = () => {
  const tabBar = useRef<any>(null);
  
  useEffect(() => {
    if (tabBar.current) {
      TabBarManager.setTabBarRef(tabBar.current);
    }
    TabBarManager.setTabBarPath('/routing');
    TabBarManager.setCurrentPath('/routing');
    
    return () => {
      console.log('RoutingPage: Component unmounting, resetting TabBarManager');
    };
  }, []);

  useEffect(() => {
    if (tabBar.current) {
      TabBarManager.setTabBarRef(tabBar.current);
      console.log('RoutingPage: TabBar ref updated');
    }
  });

  return (
    <FlutterCupertinoTabBar ref={tabBar}>
      <FlutterCupertinoTabBarItem title="Demo" icon="home" path="/demo">
        <RoutingDemo />
      </FlutterCupertinoTabBarItem>
      <FlutterCupertinoTabBarItem title="Search" icon="search" path="/search">
        <div style={{ padding: '20px', textAlign: 'center', backgroundColor: 'var(--background-color)' }}>
          <h3 style={{ color: 'var(--font-color-primary)' }}>Search Page</h3>
          <p style={{ color: 'var(--secondary-font-color)' }}>This is the search tab content.</p>
          <button 
            onClick={() => {
              console.log('Search page: Switching to /my tab');
              TabBarManager.switchTab('/my');
            }}
            style={{
              padding: '10px 20px',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '16px'
            }}
          >
            Switch to My Tab
          </button>
        </div>
      </FlutterCupertinoTabBarItem>
      <FlutterCupertinoTabBarItem title="My" icon="person" path="/my">
        <div style={{ padding: '20px', textAlign: 'center', backgroundColor: 'var(--background-color)' }}>
          <h3 style={{ color: 'var(--font-color-primary)' }}>My Page</h3>
          <p style={{ color: 'var(--secondary-font-color)' }}>This is the my tab content.</p>
          <button 
            onClick={() => {
              console.log('My page: Navigating to /animation');
              WebFRouter.pushState({}, '/animation');
            }}
            style={{
              padding: '10px 20px',
              backgroundColor: '#34C759',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '16px'
            }}
          >
            Go to Animation Page
          </button>
        </div>
      </FlutterCupertinoTabBarItem>
      <FlutterCupertinoTabBarItem title="Enhanced" icon="gear" path="/enhanced">
        <EnhancedRoutingDemo />
      </FlutterCupertinoTabBarItem>      
    </FlutterCupertinoTabBar>
  );
};