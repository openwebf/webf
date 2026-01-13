import React from 'react';
import './App.css';
import './main.css';
import { Routes, Route } from './router';
import {HomePage} from './pages/HomePage';
import { FeatureCatalogPage } from './pages/FeatureCatalogPage';
import { CookiesPage } from './pages/CookiesPage';
import { UrlEncodingPage } from './pages/UrlEncodingPage';
import { WebSocketPage } from './pages/WebSocketPage';
import { SvgImagePage } from './pages/SvgImagePage';
import { AccessibilityPage } from './pages/AccessibilityPage';
// cleaned: remove unused demo imports
import {ImagePage} from './pages/ImagePage';
import {AnimationPage} from './pages/AnimationPage';
import {TypographyPage} from './pages/TypographyPage';
import {ActionSheetPage} from './pages/ActionSheetPage';
import {VideoPage} from './pages/VideoPage';
import {FontFacePage} from './pages/FontFacePage';
import {WebFSharePage} from './pages/WebFSharePage';
import {WebFSQFlitePage} from './pages/WebFSQFlitePage';
import {WebFBluetoothPage} from './pages/WebFBluetoothPage';
import {WebFVideoPlayerPage} from './pages/WebFVideoPlayerPage';
import {WebFCameraPage} from './pages/WebFCameraPage';
import {NetworkPage} from './pages/NetworkPage';
import {ResponsivePage} from './pages/ResponsivePage';
import { RoutingPage } from './pages/RoutingPage';
import { RoutingAboutPage } from './pages/RoutingAboutPage';
import { RoutingUserPage } from './pages/RoutingUserPage';
import { RoutingFilesPage } from './pages/RoutingFilesPage';
import { RoutingNotFoundPage } from './pages/RoutingNotFoundPage';
import { WebFRouterAPIDemoPage } from './pages/WebFRouterAPIDemoPage';
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
import {MutationObserverPage} from './pages/MutationObserverPage';
import {WebStoragePage} from './pages/WebStoragePage';
import {DOMBoundingRectPage} from './pages/DOMBoundingRectPage';
import {BGPage} from './pages/css/BGPage';
import {BGGradientPage} from './pages/css/BGGradientPage';
import {BGImagePage} from './pages/css/BGImagePage';
import {BGRadialPage} from './pages/css/BGRadialPage';
import {BorderPage} from './pages/css/BorderPage';
import BorderRadiusPage from './pages/css/BorderRadiusPage';
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
import { DOMOffsetsPage } from './pages/dom/DOMOffsetsPage';
import { DOMClassListPage } from './pages/dom/DOMClassListPage';
import { DOMInnerHTMLPage } from './pages/dom/DOMInnerHTMLPage';
import { DOMStylePage } from './pages/dom/DOMStylePage';
import { Canvas2dPage } from './pages/Canvas2dPage';
import { TailwindShowcasePage } from './pages/TailwindShowcasePage';
import { CupertinoShowcasePage } from './pages/CupertinoShowcasePage';
import CupertinoButtonsPage from './pages/cupertino/CupertinoButtonsPage';
import { CupertinoActionSheetPage } from './pages/cupertino/CupertinoActionSheetPage';
import { CupertinoModalPopupPage } from './pages/cupertino/CupertinoModalPopupPage';
import { CupertinoAlertPage } from './pages/cupertino/CupertinoAlertPage';
import { CupertinoControlsPage } from './pages/cupertino/CupertinoControlsPage';
import CupertinoColorsPage from './pages/cupertino/CupertinoColorsPage';
import { CupertinoIconsPage } from './pages/cupertino/CupertinoIconsPage';
import { CupertinoTabsPage } from './pages/cupertino/CupertinoTabsPage';
import { CupertinoPageRoutePage } from './pages/cupertino/CupertinoPageRoutePage';
import { CupertinoDialogRoutePage } from './pages/cupertino/CupertinoDialogRoutePage';
import { CupertinoModalPopupRoutePage } from './pages/cupertino/CupertinoModalPopupRoutePage';
import { CupertinoPageTransitionPage } from './pages/cupertino/CupertinoPageTransitionPage';
import { CupertinoFullscreenDialogTransitionPage } from './pages/cupertino/CupertinoFullscreenDialogTransitionPage';
import { CupertinoPopupSurfacePage } from './pages/cupertino/CupertinoPopupSurfacePage';
import { CupertinoContextMenuPage } from './pages/cupertino/CupertinoContextMenuPage';
import { CupertinoListSectionPage } from './pages/cupertino/CupertinoListSectionPage';
import { CupertinoListTilePage } from './pages/cupertino/CupertinoListTilePage';
import { CupertinoFormSectionPage } from './pages/cupertino/CupertinoFormSectionPage';
import { CupertinoTextFieldPage } from './pages/cupertino/CupertinoTextFieldPage';
import { CupertinoTextFormFieldRowPage } from './pages/cupertino/CupertinoTextFormFieldRowPage';
import { CupertinoSearchTextFieldPage } from './pages/cupertino/CupertinoSearchTextFieldPage';
import { CupertinoAdaptiveTextSelectionToolbarPage } from './pages/cupertino/CupertinoAdaptiveTextSelectionToolbarPage';
import { CupertinoTextSelectionToolbarPage } from './pages/cupertino/CupertinoTextSelectionToolbarPage';
import { CupertinoDesktopTextSelectionToolbarPage } from './pages/cupertino/CupertinoDesktopTextSelectionToolbarPage';
import { CupertinoTextSelectionControlsPage } from './pages/cupertino/CupertinoTextSelectionControlsPage';
import { CupertinoMagnifierPage } from './pages/cupertino/CupertinoMagnifierPage';
import { CupertinoSpellCheckSuggestionsToolbarPage } from './pages/cupertino/CupertinoSpellCheckSuggestionsToolbarPage';
import { CupertinoDatePickerPage } from './pages/cupertino/CupertinoDatePickerPage';
import { CupertinoTimerPickerPage } from './pages/cupertino/CupertinoTimerPickerPage';
import { CupertinoPickerPage } from './pages/cupertino/CupertinoPickerPage';
import { CupertinoSwitchPage } from './pages/cupertino/CupertinoSwitchPage';
import { CupertinoSliderPage } from './pages/cupertino/CupertinoSliderPage';
import { CupertinoSlidingSegmentedControlPage } from './pages/cupertino/CupertinoSlidingSegmentedControlPage';
import { CupertinoCheckBoxPage } from './pages/cupertino/CupertinoCheckBoxPage';
import { CupertinoRadioPage } from './pages/cupertino/CupertinoRadioPage';
import {UserDetailsPage} from './pages/routeDemo/UserDetailsPage';
import {ReportDetailsPage} from './pages/routeDemo/ReportDetailsPage';
import {ProfileEditPage} from './pages/routeDemo/ProfileEditPage';
import {DragableListPage} from './pages/DragableListPage';

function App() {

  return (
    <div className="App">
      <Routes>
        <Route path="/" title="Home" element={<HomePage/>}/>
        <Route path="/features" title="Features" element={<FeatureCatalogPage/>}/>

        <Route path="/tailwind" title="Tailwind CSS Showcase" element={<TailwindShowcasePage />} />

        {/* Feature catalog routes */}
        <Route path="/cookies" title="Cookies" element={<CookiesPage/>}/>
        <Route path="/url-encoding" title="URL & Encoding" element={<UrlEncodingPage/>}/>
        <Route path="/websocket" title="WebSocket" element={<WebSocketPage/>}/>
        <Route path="/svg-image" title="SVG via Img" element={<SvgImagePage/>}/>
        <Route path="/accessibility" title="Accessibility Use Cases" element={<AccessibilityPage />} />

        <Route path="/dom/events" title="DOM Events" element={<DOMEventsPage />} />
        <Route path="/dom/geometry" title="DOM Geometry" element={<DOMGeometryPage />} />
        <Route path="/dom/offsets" title="DOM Offsets" element={<DOMOffsetsPage />} />
        <Route path="/dom/classlist" title="DOMTokenList (classList)" element={<DOMClassListPage />} />
        <Route path="/dom/innerhtml" title="innerHTML vs textContent" element={<DOMInnerHTMLPage />} />
        <Route path="/dom/style" title="element.style" element={<DOMStylePage />} />

        <Route path="/canvas-2d" title="Canvas 2D" element={<Canvas2dPage />} />

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
        {/*<Route path="/css/clip-path" title="Clip Path" element={<ClipPathPage />} />*/}
        <Route path="/css/border-background-shadow" title="Border Background Shadow" element={<BorderBackgroundShadowPage />} />
        <Route path="/css/overflow" title="Overflow" element={<OverflowPage />} />
        <Route path="/css/transforms" title="Transforms" element={<TransformsPage />} />
        <Route path="/css/animation" title="Animations" element={<AnimationPage/>}/>
        <Route path="/css/transitions" title="Transitions" element={<TransitionsPage />} />
        <Route path="/css/display-flow" title="Display & Flow" element={<DisplayFlowPage />} />
        <Route path="/css/sizing" title="Sizing" element={<SizingPage />} />
        <Route path="/css/inline-formatting" title="Inline Formatting" element={<InlineFormattingPage />} />
        <Route path="/css/position" title="Positioned Layout" element={<PositionPage />} />
        {/*<Route path="/css/selectors" title="Selectors" element={<SelectorsPage />} />*/}
        <Route path="/css/values-units" title="Values & Units" element={<ValuesUnitsPage />} />


        <Route path="/web-storage" title="Web Storage API" element={<WebStoragePage />} />
        <Route path="/dom-bounding-rect" title="DOM getBoundingClientRect API" element={<DOMBoundingRectPage />} />
        <Route path="/mutation-observer" title="MutationObserver API" element={<MutationObserverPage />} />


        <Route path="/cupertino-showcase" title="Cupertino UI Showcase" theme={'cupertino'} element={<CupertinoShowcasePage />} />
        <Route path="/cupertino/buttons" title="Cupertino Buttons" theme={'cupertino'} element={<CupertinoButtonsPage />} />
        <Route path="/cupertino/modal-popup" title="Cupertino Modal Popup" theme={'cupertino'} element={<CupertinoModalPopupPage />} />
        <Route path="/cupertino/actionsheet" title="Cupertino Action Sheet" theme={'cupertino'} element={<CupertinoActionSheetPage />} />
        <Route path="/cupertino/alert" title="Cupertino Alert Dialog" theme={'cupertino'} element={<CupertinoAlertPage />} />
        <Route path="/cupertino/controls" title="Cupertino Switches & Sliders" theme={'cupertino'} element={<CupertinoControlsPage />} />
        <Route path="/cupertino/colors" title="Cupertino Colors" theme={'cupertino'} element={<CupertinoColorsPage />} />
        <Route path="/cupertino/icons" title="Cupertino Icons" theme={'cupertino'} element={<CupertinoIconsPage />} />
        <Route path="/cupertino/tabs" title="Cupertino Tabs" theme={'cupertino'} element={<CupertinoTabsPage />} />
        <Route path="/cupertino/context-menu" title="Cupertino Context Menu" theme={'cupertino'} element={<CupertinoContextMenuPage />} />
        <Route path="/cupertino/list-section" title="Cupertino List Section" theme={'cupertino'} element={<CupertinoListSectionPage />} />
        <Route path="/cupertino/list-tile" title="Cupertino List Tile" theme={'cupertino'} element={<CupertinoListTilePage />} />
        <Route path="/cupertino/form-section" title="Cupertino Form Section" theme={'cupertino'} element={<CupertinoFormSectionPage />} />
        <Route path="/cupertino/text-field" title="Cupertino Text Field" theme={'cupertino'} element={<CupertinoTextFieldPage />} />
        <Route path="/cupertino/text-form-field-row" title="Cupertino TextFormFieldRow" theme={'cupertino'} element={<CupertinoTextFormFieldRowPage />} />
        <Route path="/cupertino/search-text-field" title="Cupertino Search Text Field" theme={'cupertino'} element={<CupertinoSearchTextFieldPage />} />
        <Route path="/cupertino/adaptive-text-selection-toolbar" title="Adaptive Text Selection Toolbar" theme={'cupertino'} element={<CupertinoAdaptiveTextSelectionToolbarPage />} />
        <Route path="/cupertino/text-selection-toolbar" title="Text Selection Toolbar" theme={'cupertino'} element={<CupertinoTextSelectionToolbarPage />} />
        <Route path="/cupertino/desktop-text-selection-toolbar" title="Desktop Text Selection Toolbar" theme={'cupertino'} element={<CupertinoDesktopTextSelectionToolbarPage />} />
        <Route path="/cupertino/text-selection-controls" title="Text Selection Controls" theme={'cupertino'} element={<CupertinoTextSelectionControlsPage />} />
        <Route path="/cupertino/magnifier" title="Cupertino Magnifier" theme={'cupertino'} element={<CupertinoMagnifierPage />} />
        <Route path="/cupertino/spell-check-suggestions-toolbar" title="Spell Check Suggestions Toolbar" theme={'cupertino'} element={<CupertinoSpellCheckSuggestionsToolbarPage />} />
        <Route path="/cupertino/date-picker" title="Cupertino Date Picker" theme={'cupertino'} element={<CupertinoDatePickerPage />} />
        <Route path="/cupertino/timer-picker" title="Cupertino Timer Picker" theme={'cupertino'} element={<CupertinoTimerPickerPage />} />
        <Route path="/cupertino/picker" title="Cupertino Picker" theme={'cupertino'} element={<CupertinoPickerPage />} />
        <Route path="/cupertino/switch" title="Cupertino Switch" theme={'cupertino'} element={<CupertinoSwitchPage />} />
        <Route path="/cupertino/slider" title="Cupertino Slider" theme={'cupertino'} element={<CupertinoSliderPage />} />
        <Route path="/cupertino/sliding-segmented-control" title="Sliding Segmented Control" theme={'cupertino'} element={<CupertinoSlidingSegmentedControlPage />} />
        <Route path="/cupertino/checkbox" title="Cupertino CheckBox" theme={'cupertino'} element={<CupertinoCheckBoxPage />} />
        <Route path="/cupertino/radio" title="Cupertino Radio" theme={'cupertino'} element={<CupertinoRadioPage />} />


        <Route path="/image-preload" title="Image Preload" element={<ImagePreloadPage />} />

        {/* Routing / Navigation */}
        <Route path="/routing/about" title="Routing Demo: About" element={<RoutingAboutPage />} />
        <Route path="/routing/users/:id" title="Routing Demo: User" element={<RoutingUserPage />} />
        <Route path="/routing/files/*" title="Routing Demo: Files" element={<RoutingFilesPage />} />
        <Route path="/routing" title="Routing & Navigation" element={<RoutingPage />} />
        <Route path="/routing/*" title="Routing Demo: Not Found" element={<RoutingNotFoundPage />} />
        <Route path="/routing-api" title="WebFRouter API Showcase" element={<WebFRouterAPIDemoPage />} />

        {/* Dynamic Route Examples */}
        <Route path="/user/:id" title="User Details" element={<UserDetailsPage />} />
        <Route path="/dashboard/:year/:month/reports/:id" title="Report Details" element={<ReportDetailsPage />} />
        <Route path="/profile/edit" title="Profile Edit" element={<ProfileEditPage />} />
        <Route path="/webf-share" title="WebF Share" element={<WebFSharePage />} />
        <Route path="/webf-sqflite" title="WebF SQFlite" element={<WebFSQFlitePage />} />
        <Route path="/webf-video-player" title="WebF Video Player" element={<WebFVideoPlayerPage />} />
        <Route path="/webf-camera" title="WebF Camera" element={<WebFCameraPage />} />
        <Route path="/webf-bluetooth" title="WebF Bluetooth" element={<WebFBluetoothPage />} />
        <Route path="/network" title="Network Requests" element={<NetworkPage />} />
        <Route path="/image" title="Image Gallery" element={<ImagePage />} />
        <Route path="/typography" title="Typography" element={<TypographyPage />} />
        <Route path="/fontface" title="Custom Fonts" element={<FontFacePage />} />
        <Route path="/responsive" title="Responsive Design" element={<ResponsivePage />} />
        <Route path="/alert" title="Alert" element={<AlertPage />} />
        <Route path="/theme-toggle" title="Theme Toggle" element={<ThemeTogglePage />} />
        <Route path="/gesture" title="Gesture Detection" element={<GesturePage />} />
        <Route path="/dragable-list" title="Dragable List" element={<DragableListPage />} />

        {/*<Route path="/show_case" title="Show Case" element={<ShowCasePage />} />*/}
        <Route path="/listview" title="WebFListView" element={<ListviewPage />} />
        {/*<Route path="/form" title="Form" element={<FormPage />} />*/}
        {/*<Route path="/basic-form-elements" title="Basic Form Elements" element={<BasicFormElementsPage />} />*/}
        {/*<Route path="/input-sizing" title="Input Sizing" element={<InputSizingPage />} />*/}
        {/*<Route path="/advanced-form" title="Advanced Form" element={<FormAdvancedPage />} />*/}
        {/*<Route path="/table" title="Tables" element={<TablePage />} />*/}
        {/*<Route path="/actionsheet" title="Action Sheets" element={<ActionSheetPage />} />*/}
        {/*<Route path="/video" title="Video Player" element={<VideoPage />} />*/}
        {/*<Route path="/qrcode" title="QR Code Generator" element={<QRCodePage />} />*/}
        {/*<Route path="/contextmenu" title="Context Menu" element={<ContextMenuPage />} />*/}
        {/*<Route path="/modalpopup" title="Modal Popup" element={<ModalPopupPage />} />*/}
        {/*<Route path="/loading" title="Loading" element={<LoadingPage />} />*/}
      </Routes>
    </div>
  );
}

export default App;
