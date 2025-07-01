import React, { useState, useRef } from 'react';
import ChatRoomTailwind from './pages/ChatRoomTailwind';
import {
  FlutterCupertinoTabBar,
  FlutterCupertinoTabBarItem,
  FlutterCupertinoTabBarElement
} from '@openwebf/react-cupertino-ui';
import BitcoinPriceTailwind from './pages/BitcoinPriceTailwind';
import { WebFListView, WebFLazyRender } from '@openwebf/react-core-ui';
// import Demo from './pages/Demo';
import { Routes, Route, useRoutes } from '@openwebf/react-router';
import Demo from './pages/DemoTailwind';
import FlexLayoutDemo from './pages/FlexLayoutDemoTailwind';
// import GridStickyDemo from './pages/GridStickyDemo';
import NestedScrollDemo from './pages/NestedScrollDemoTailwind';

function AppTailwind() {
  const [currentTabIndex, setCurrentTabIndex] = useState(0);
  const tabBarRef = useRef<FlutterCupertinoTabBarElement>(null);

  const handleTabChange = (event: CustomEvent<number>) => {
    const index = event.detail;
    setCurrentTabIndex(index);
    console.log('Current tab index:', index);
  };

  const switchToChat = () => {
    if (tabBarRef.current) {
      tabBarRef.current.switchTab('/chat');
    }
  };

  const switchToBitcoin = () => {
    if (tabBarRef.current) {
      tabBarRef.current.switchTab('/bitcoin');
    }
  };

  return (
    <div className="text-center h-screen flex flex-col border">
      <FlutterCupertinoTabBar
        ref={tabBarRef}
        currentIndex={currentTabIndex.toString()}
        backgroundColor="#f8f8f8"
        activeColor="#007AFF"
        inactiveColor="#8E8E93"
        height="60"
        onTabchange={handleTabChange}
      >
        <FlutterCupertinoTabBarItem
          title="Chat"
          icon="chat_bubble_2_fill"
          path="/chat"
        >
          <WebFListView shrinkWrap={false} className="h-full">
            <ChatRoomTailwind />
          </WebFListView>
        </FlutterCupertinoTabBarItem>

        <FlutterCupertinoTabBarItem
          title="Bitcoin"
          icon="money_dollar_circle_fill"
          path="/bitcoin"
        >

          <WebFLazyRender className="h-full">
            <BitcoinPriceTailwind />
          </WebFLazyRender>
        </FlutterCupertinoTabBarItem>
        <FlutterCupertinoTabBarItem
          title="Demo"
          icon="doc"
          path="/demo"
        >
          <WebFLazyRender className="h-full">
            <WebFListView className='border h-full' shrinkWrap={false}>
              <Demo />
            </WebFListView>
          </WebFLazyRender>
        </FlutterCupertinoTabBarItem>
      </FlutterCupertinoTabBar>
      <Routes>
        <Route path="/demo/flex-layout" element={<FlexLayoutDemo />} title="Flex布局与文字样式"></Route>
        <Route path="/demo/nested-scroll" element={<NestedScrollDemo />} title="嵌套滚动场景" />
      </Routes>
    </div>
  );
}

export default AppTailwind;