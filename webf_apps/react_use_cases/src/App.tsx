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
import { QRCodePage } from './pages/QRCodePage';
import { TablePage } from './pages/TablePage';
import { GesturePage } from './pages/GesturePage';
import { ResizeObserverPage } from './pages/ResizeObserverPage';
import { MutationObserverPage } from './pages/MutationObserverPage';
import { WebStoragePage } from './pages/WebStoragePage';
import { DOMBoundingRectPage } from './pages/DOMBoundingRectPage';
import { CSSShowcasePage } from './pages/CSSShowcasePage';
import { BGPage } from './pages/css/BGPage';
import { BGGradientPage } from './pages/css/BGGradientPage';
import { BGImagePage } from './pages/css/BGImagePage';
import { BGRadialPage } from './pages/css/BGRadialPage';
import { BorderPage } from './pages/css/BorderPage';
import { BorderRadiusPage } from './pages/css/BorderRadiusPage';
import { BoxShadowPage } from './pages/css/BoxShadowPage';
import { FilterPage } from './pages/css/FilterPage';
import { FlexLayoutPage } from './pages/css/FlexLayoutPage';
import { KeyframesPage } from './pages/css/KeyframesPage';
import { ClipPathPage } from './pages/css/ClipPathPage';
import { BorderBackgroundShadowPage } from './pages/css/BorderBackgroundShadowPage';
import { UserDetailsPage } from './pages/routeDemo/UserDetailsPage';
import { ReportDetailsPage } from './pages/routeDemo/ReportDetailsPage';
import { ProfileEditPage } from './pages/routeDemo/ProfileEditPage';

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
        <Route path="/table" title="Tables" element={<TablePage />} />
        <Route path="/typography" title="Typography" element={<TypographyPage />} />
        <Route path="/actionsheet" title="Action Sheets" element={<ActionSheetPage />} />
        <Route path="/video" title="Video Player" element={<VideoPage />} />
        <Route path="/qrcode" title="QR Code Generator" element={<QRCodePage />} />
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
        <Route path="/gesture" title="Gesture Detection" element={<GesturePage />} />
        
        {/* Advanced Web APIs */}
        <Route path="/resize-observer" title="ResizeObserver API" element={<ResizeObserverPage />} />
        <Route path="/mutation-observer" title="MutationObserver API" element={<MutationObserverPage />} />
        <Route path="/web-storage" title="Web Storage API" element={<WebStoragePage />} />
        <Route path="/dom-bounding-rect" title="DOM Measurements API" element={<DOMBoundingRectPage />} />
        
        {/* CSS Showcase */}
        <Route path="/css-showcase" title="CSS Showcase" element={<CSSShowcasePage />} />
        <Route path="/css/bg" title="Background" element={<BGPage />} />
        <Route path="/css/bg-gradient" title="Background Gradient" element={<BGGradientPage />} />
        <Route path="/css/bg-image" title="Background Image" element={<BGImagePage />} />
        <Route path="/css/bg-radial" title="Background Radial" element={<BGRadialPage />} />
        <Route path="/css/border" title="Border" element={<BorderPage />} />
        <Route path="/css/border-radius" title="Border Radius" element={<BorderRadiusPage />} />
        <Route path="/css/box-shadow" title="Box Shadow" element={<BoxShadowPage />} />
        <Route path="/css/filter" title="Filter" element={<FilterPage />} />
        <Route path="/css/flex-layout" title="Flex Layout" element={<FlexLayoutPage />} />
        <Route path="/css/keyframes" title="Keyframes" element={<KeyframesPage />} />
        <Route path="/css/clip-path" title="Clip Path" element={<ClipPathPage />} />
        <Route path="/css/border-background-shadow" title="Border Background Shadow" element={<BorderBackgroundShadowPage />} />
        
        {/* Dynamic Routes */}
        <Route path="/user/:userId" title="User Details" element={<UserDetailsPage />} />
        <Route path="/dashboard/:year/:month/reports/:reportId" title="Report Details" element={<ReportDetailsPage />} />
        <Route path="/profile/edit" title="Edit Profile" element={<ProfileEditPage />} />
      </Routes>
    </div>
  );
}

export default App;