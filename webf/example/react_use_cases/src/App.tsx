import React from 'react';
import './App.css';
import './main.css';
import { RouterView } from './components/RouterView';
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
// import { FormAdvancedPage } from './pages/FormAdvancedPage';

function App() {
  return (
    <div className="App">
      <RouterView path="/" title="Home">
        <HomePage />
      </RouterView>
      <RouterView path="/show_case" title="Show Case">
        <ShowCasePage />
      </RouterView>
      <RouterView path="/listview" title="Listview">
        <ListviewPage />
      </RouterView>
      <RouterView path="/form" title="Form">
        <FormPage />
      </RouterView>
      {/* <RouterView path="/form-advanced" title="Form Advanced">
        <FormAdvancedPage />
      </RouterView> */}
      <RouterView path="/echarts" title="ECharts">
        <EChartsPage />
      </RouterView>
      <RouterView path="/image" title="Image Gallery">
        <ImagePage />
      </RouterView>
      <RouterView path="/animation" title="Animations">
        <AnimationPage />
      </RouterView>
      <RouterView path="/typography" title="Typography">
        <TypographyPage />
      </RouterView>
      <RouterView path="/actionsheet" title="Action Sheets">
        <ActionSheetPage />
      </RouterView>
      <RouterView path="/video" title="Video Player">
        <VideoPage />
      </RouterView>
      <RouterView path="/fontface" title="Custom Fonts">
        <FontFacePage />
      </RouterView>
      <RouterView path="/native-interaction" title="Native Interaction">
        <NativeInteractionPage />
      </RouterView>
      <RouterView path="/flutter-interaction" title="Flutter Interaction">
        <FlutterInteractionPage />
      </RouterView>
      <RouterView path="/deep-link" title="Deep Links">
        <DeepLinkPage />
      </RouterView>
      <RouterView path="/network" title="Network Requests">
        <NetworkPage />
      </RouterView>
      <RouterView path="/responsive" title="Responsive Design">
        <ResponsivePage />
      </RouterView>
      <RouterView path="/routing" title="Routing & Navigation">
        <RoutingPage />
      </RouterView>
      <RouterView path="/contextmenu" title="Context Menu">
        <ContextMenuPage />
      </RouterView>
      <RouterView path="/modalpopup" title="Modal Popup">
        <ModalPopupPage />
      </RouterView>
      <RouterView path="/loading" title="Loading">
        <LoadingPage />
      </RouterView>
      <RouterView path="/alert" title="Alert">
        <AlertPage />
      </RouterView>
      <RouterView path="/image-preload" title="Image Preload">
        <ImagePreloadPage />
      </RouterView>
    </div>
  );
}

export default App;