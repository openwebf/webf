import React from 'react';
import './App.css';
import './main.css';
import {Routes, Route} from '@openwebf/react-router';
import {HomePage} from './pages/HomePage';
import { FeatureCatalogPage } from './pages/FeatureCatalogPage';
import { CookiesPage } from './pages/CookiesPage';
import { UrlEncodingPage } from './pages/UrlEncodingPage';
import { WebSocketPage } from './pages/WebSocketPage';
import { SvgImagePage } from './pages/SvgImagePage';
// cleaned: remove unused demo imports
import {ImagePage} from './pages/ImagePage';
import {AnimationPage} from './pages/AnimationPage';
import {TypographyPage} from './pages/TypographyPage';
import {ActionSheetPage} from './pages/ActionSheetPage';
import {VideoPage} from './pages/VideoPage';
import {FontFacePage} from './pages/FontFacePage';
import {NativeInteractionPage} from './pages/NativeInteractionPage';
import {FlutterInteractionPage} from './pages/FlutterInteractionPage';
import {DeepLinkPage} from './pages/DeepLinkPage';
import {NetworkPage} from './pages/NetworkPage';
import {ResponsivePage} from './pages/ResponsivePage';
import {RoutingPage} from './pages/RoutingPage';
import {ContextMenuPage} from './pages/ContextMenuPage';
import {ModalPopupPage} from './pages/ModalPopupPage';
import {LoadingPage} from './pages/LoadingPage';
import {AlertPage} from './pages/AlertPage';
import {ImagePreloadPage} from './pages/ImagePreloadPage';
import {ThemeTogglePage} from './pages/ThemeTogglePage';
import {FormAdvancedPage} from './pages/FormAdvancedPage';
import {BasicFormElementsPage} from './pages/BasicFormElementsPage';
import {InputSizingPage} from './pages/InputSizingPage';
import {QRCodePage} from './pages/QRCodePage';
import {TablePage} from './pages/TablePage';
import {GesturePage} from './pages/GesturePage';
import {ShowCasePage} from './pages/ShowCasePage';
import {ListviewPage} from './pages/ListviewPage';
import {FormPage} from './pages/FormPage';
import {ResizeObserverPage} from './pages/ResizeObserverPage';
import {MutationObserverPage} from './pages/MutationObserverPage';
import {WebStoragePage} from './pages/WebStoragePage';
import {DOMBoundingRectPage} from './pages/DOMBoundingRectPage';
import {CSSShowcasePage} from './pages/CSSShowcasePage';
import {BGPage} from './pages/css/BGPage';
import {BGGradientPage} from './pages/css/BGGradientPage';
import {BGImagePage} from './pages/css/BGImagePage';
import {BGRadialPage} from './pages/css/BGRadialPage';
import {BorderPage} from './pages/css/BorderPage';
import {BorderRadiusPage} from './pages/css/BorderRadiusPage';
import {BoxShadowPage} from './pages/css/BoxShadowPage';
import {FilterPage} from './pages/css/FilterPage';
import {FlexLayoutPage} from './pages/css/FlexLayoutPage';
import {KeyframesPage} from './pages/css/KeyframesPage';
import {ClipPathPage} from './pages/css/ClipPathPage';
import {OverflowPage} from './pages/css/OverflowPage';
import {TransformsPage} from './pages/css/TransformsPage';
import {TransitionsPage} from './pages/css/TransitionsPage';
import {BorderBackgroundShadowPage} from './pages/css/BorderBackgroundShadowPage';
import {DisplayFlowPage} from './pages/css/DisplayFlowPage';
import {SizingPage} from './pages/css/SizingPage';
import {InlineFormattingPage} from './pages/css/InlineFormattingPage';
import {PositionPage} from './pages/css/PositionPage';
import {SelectorsPage} from './pages/css/SelectorsPage';
import {ValuesUnitsPage} from './pages/css/ValuesUnitsPage';
import { DOMEventsPage } from './pages/dom/DOMEventsPage';
import { DOMGeometryPage } from './pages/dom/DOMGeometryPage';
import { DOMDatasetPage } from './pages/dom/DOMDatasetPage';
import { DOMNodesPage } from './pages/dom/DOMNodesPage';
import { DOMOffsetsPage } from './pages/dom/DOMOffsetsPage';
import { DOMClassListPage } from './pages/dom/DOMClassListPage';
import { DOMInnerHTMLPage } from './pages/dom/DOMInnerHTMLPage';
import { DOMStylePage } from './pages/dom/DOMStylePage';
import { TailwindShowcasePage } from './pages/TailwindShowcasePage';
// import {UserDetailsPage} from './pages/routeDemo/UserDetailsPage';
// import {ReportDetailsPage} from './pages/routeDemo/ReportDetailsPage';
// import {ProfileEditPage} from './pages/routeDemo/ProfileEditPage';

function App() {

  return (
    <div className="App">
      <Routes>
        <Route path="/" title="Home" element={<HomePage/>}/>
        <Route path="/features" title="Features" element={<FeatureCatalogPage/>}/>
        <Route path="/animation" title="Animations" element={<AnimationPage/>}/>
        {/* Feature catalog routes */}
        <Route path="/cookies" title="Cookies" element={<CookiesPage/>}/>
        <Route path="/url-encoding" title="URL & Encoding" element={<UrlEncodingPage/>}/>
        <Route path="/websocket" title="WebSocket" element={<WebSocketPage/>}/>
        <Route path="/svg-image" title="SVG via Img" element={<SvgImagePage/>}/>

        {/* Re-enabled showcases to match Feature Catalog links */}
        <Route path="/css-showcase" title="CSS Showcase" element={<CSSShowcasePage />} />
        <Route path="/resize-observer" title="ResizeObserver API" element={<ResizeObserverPage />} />
        <Route path="/mutation-observer" title="MutationObserver API" element={<MutationObserverPage />} />
        <Route path="/web-storage" title="Web Storage API" element={<WebStoragePage />} />
        <Route path="/dom-bounding-rect" title="DOM getBoundingClientRect API" element={<DOMBoundingRectPage />} />
        <Route path="/dom/events" title="DOM Events" element={<DOMEventsPage />} />
        <Route path="/dom/geometry" title="DOM Geometry" element={<DOMGeometryPage />} />
        <Route path="/dom/dataset" title="DOM dataset" element={<DOMDatasetPage />} />
        <Route path="/dom/nodes" title="DOM Nodes" element={<DOMNodesPage />} />
        <Route path="/dom/offsets" title="DOM Offsets" element={<DOMOffsetsPage />} />
        <Route path="/dom/classlist" title="DOMTokenList (classList)" element={<DOMClassListPage />} />
        <Route path="/dom/innerhtml" title="innerHTML vs textContent" element={<DOMInnerHTMLPage />} />
        <Route path="/dom/style" title="element.style" element={<DOMStylePage />} />
        <Route path="/tailwind" title="Tailwind CSS Showcase" element={<TailwindShowcasePage />} />
        <Route path="/image-preload" title="Image Preload" element={<ImagePreloadPage />} />
        <Route path="/routing" title="Routing & Navigation" element={<RoutingPage />} />
        <Route path="/deep-link" title="Deep Links" element={<DeepLinkPage />} />
        <Route path="/flutter-interaction" title="Flutter Interaction" element={<FlutterInteractionPage />} />
        <Route path="/native-interaction" title="Native Interaction" element={<NativeInteractionPage />} />
        <Route path="/network" title="Network Requests" element={<NetworkPage />} />
        <Route path="/image" title="Image Gallery" element={<ImagePage />} />
        <Route path="/typography" title="Typography" element={<TypographyPage />} />
        <Route path="/fontface" title="Custom Fonts" element={<FontFacePage />} />
        <Route path="/responsive" title="Responsive Design" element={<ResponsivePage />} />
        <Route path="/alert" title="Alert" element={<AlertPage />} />
        <Route path="/theme-toggle" title="Theme Toggle" element={<ThemeTogglePage />} />
        <Route path="/gesture" title="Gesture Detection" element={<GesturePage />} />
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
        <Route path="/css/overflow" title="Overflow" element={<OverflowPage />} />
        <Route path="/css/transforms" title="Transforms" element={<TransformsPage />} />
        <Route path="/css/transitions" title="Transitions" element={<TransitionsPage />} />
        <Route path="/css/display-flow" title="Display & Flow" element={<DisplayFlowPage />} />
        <Route path="/css/sizing" title="Sizing" element={<SizingPage />} />
        <Route path="/css/inline-formatting" title="Inline Formatting" element={<InlineFormattingPage />} />
        <Route path="/css/position" title="Positioned Layout" element={<PositionPage />} />
        <Route path="/css/selectors" title="Selectors" element={<SelectorsPage />} />
        <Route path="/css/values-units" title="Values & Units" element={<ValuesUnitsPage />} />
        <Route path="/show_case" title="Show Case" element={<ShowCasePage />} />
        <Route path="/listview" title="Listview" element={<ListviewPage />} />
        <Route path="/form" title="Form" element={<FormPage />} />
        <Route path="/basic-form-elements" title="Basic Form Elements" element={<BasicFormElementsPage />} />
        <Route path="/input-sizing" title="Input Sizing" element={<InputSizingPage />} />
        <Route path="/advanced-form" title="Advanced Form" element={<FormAdvancedPage />} />
        <Route path="/table" title="Tables" element={<TablePage />} />
        <Route path="/actionsheet" title="Action Sheets" element={<ActionSheetPage />} />
        <Route path="/video" title="Video Player" element={<VideoPage />} />
        <Route path="/qrcode" title="QR Code Generator" element={<QRCodePage />} />
        <Route path="/contextmenu" title="Context Menu" element={<ContextMenuPage />} />
        <Route path="/modalpopup" title="Modal Popup" element={<ModalPopupPage />} />
        <Route path="/loading" title="Loading" element={<LoadingPage />} />
      </Routes>
    </div>
  );
}

export default App;
