import React from 'react';
import './App.css';
import './main.css';
import { Routes, Route } from '@openwebf/react-router';
import { HomePage } from './pages/HomePage';
import { ShowCasePage } from './pages/ShowCasePage';
import { ListviewPage } from './pages/ListviewPage';
import { FormPage } from './pages/FormPage';
import { EChartsPage } from './pages/EChartsPage';
import { ImagePage } from './pages/ImagePage';
import { AnimationPage } from './pages/AnimationPage';
import { TypographyPage } from './pages/TypographyPage';
import { ActionSheetPage } from './pages/ActionSheetPage';
import { VideoPage } from './pages/VideoPage';
import { FontFacePage } from './pages/FontFacePage';
import { NativeInteractionPage } from './pages/NativeInteractionPage';
import { FlutterInteractionPage } from './pages/FlutterInteractionPage';
import { DeepLinkPage } from './pages/DeepLinkPage';
import { NetworkPage } from './pages/NetworkPage';
import { ResponsivePage } from './pages/ResponsivePage';
import { RoutingPage } from './pages/RoutingPage';
import { ContextMenuPage } from './pages/ContextMenuPage';
import { ModalPopupPage } from './pages/ModalPopupPage';
import { LoadingPage } from './pages/LoadingPage';
import { AlertPage } from './pages/AlertPage';
import { ImagePreloadPage } from './pages/ImagePreloadPage';
import { ThemeTogglePage } from './pages/ThemeTogglePage';
import { FormAdvancedPage } from './pages/FormAdvancedPage';

function App() {
  return (
    <div className="App">
      <Routes>
        <Route path="/" title="Home" element={<HomePage />} />
        <Route path="/show_case" title="Show Case" element={<ShowCasePage />} />
        <Route path="/listview" title="Listview" element={<ListviewPage />} />
        <Route path="/form" title="Form" element={<FormPage />} />
        <Route path="/advanced-form" title="Advanced Form" element={<FormAdvancedPage />} />
        <Route path="/echarts" title="ECharts" element={<EChartsPage />} />
        <Route path="/image" title="Image Gallery" element={<ImagePage />} />
        <Route path="/animation" title="Animations" element={<AnimationPage />} />
        <Route path="/typography" title="Typography" element={<TypographyPage />} />
        <Route path="/actionsheet" title="Action Sheets" element={<ActionSheetPage />} />
        <Route path="/video" title="Video Player" element={<VideoPage />} />
        <Route path="/fontface" title="Custom Fonts" element={<FontFacePage />} />
        <Route path="/native-interaction" title="Native Interaction" element={<NativeInteractionPage />} />
        <Route path="/flutter-interaction" title="Flutter Interaction" element={<FlutterInteractionPage />} />
        <Route path="/deep-link" title="Deep Links" element={<DeepLinkPage />} />
        <Route path="/network" title="Network Requests" element={<NetworkPage />} />
        <Route path="/responsive" title="Responsive Design" element={<ResponsivePage />} />
        <Route path="/routing" title="Routing & Navigation" element={<RoutingPage />} />
        <Route path="/contextmenu" title="Context Menu" element={<ContextMenuPage />} />
        <Route path="/modalpopup" title="Modal Popup" element={<ModalPopupPage />} />
        <Route path="/loading" title="Loading" element={<LoadingPage />} />
        <Route path="/alert" title="Alert" element={<AlertPage />} />
        <Route path="/image-preload" title="Image Preload" element={<ImagePreloadPage />} />
        <Route path="/theme-toggle" title="Theme Toggle" element={<ThemeTogglePage />} />
      </Routes>
    </div>
  );
}

export default App;