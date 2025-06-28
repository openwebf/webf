import React, { useEffect, useRef } from 'react';
import { createComponent } from '../utils/CreateComponent';
import { RoutingDemo } from '../components/RoutingDemo';
import TabBarManager from '../utils/tabBarManager';


const CupertinoTabBar = createComponent({
  tagName: 'flutter-cupertino-tab-bar',
  displayName: 'CupertinoTabBar'
});

const CupertinoTabBarItem = createComponent({
  tagName: 'flutter-cupertino-tab-bar-item',
  displayName: 'CupertinoTabBarItem'
});


export const RoutingPage: React.FC = () => {
  const tabBar = useRef<any>(null);
  
  useEffect(() => {
    // 设置TabBar引用和路径信息
    if (tabBar.current) {
      TabBarManager.setTabBarRef(tabBar.current);
    }
    TabBarManager.setTabBarPath('/routing'); // 设置TabBar所在页面路径
    TabBarManager.setCurrentPath('/routing'); // 设置当前路径
    
    // 清理函数
    return () => {
      // 组件卸载时清理状态
      console.log('RoutingPage: Component unmounting, resetting TabBarManager');
    };
  }, []);

  // TabBar引用更新时的处理
  useEffect(() => {
    if (tabBar.current) {
      TabBarManager.setTabBarRef(tabBar.current);
      console.log('RoutingPage: TabBar ref updated');
    }
  }, [tabBar.current]);

  return (
    <CupertinoTabBar ref={tabBar}>
      <CupertinoTabBarItem title="Demo" icon="home" path="/demo">
        <RoutingDemo />
      </CupertinoTabBarItem>
      <CupertinoTabBarItem title="Search" icon="search" path="/search">
        <div style={{ padding: '20px', textAlign: 'center' }}>
          <h3>Search Page</h3>
          <p>This is the search tab content.</p>
          <button 
            onClick={() => {
              console.log('Search page: Switching to /my tab');
              TabBarManager.switchTab('/my');
            }}
            style={{
              padding: '10px 20px',
              backgroundColor: '#007AFF',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '16px'
            }}
          >
            Switch to My Tab
          </button>
        </div>
      </CupertinoTabBarItem>
      <CupertinoTabBarItem title="My" icon="person" path="/my">
        <div style={{ padding: '20px', textAlign: 'center' }}>
          <h3>My Page</h3>
          <p>This is the my tab content.</p>
          <button 
            onClick={() => {
              console.log('My page: Navigating to /animation');
              window.webf.hybridHistory.pushState({}, '/animation');
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
      </CupertinoTabBarItem>      
    </CupertinoTabBar>
  );
};