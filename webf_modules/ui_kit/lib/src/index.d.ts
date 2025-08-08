// WebF UI Kit Type Definitions

/// <reference path="./button.d.ts" />
/// <reference path="./switch.d.ts" />
/// <reference path="./select.d.ts" />
/// <reference path="./icon.d.ts" />
/// <reference path="./search.d.ts" />
/// <reference path="./tab.d.ts" />
/// <reference path="./slider.d.ts" />
/// <reference path="./bottom_sheet.d.ts" />
/// <reference path="./svg_img.d.ts" />
/// <reference path="./showcase_view.d.ts" />
/// <reference path="./listview_cupertino.d.ts" />
/// <reference path="./listview_material.d.ts" />

declare global {
  namespace JSX {
    interface IntrinsicElements {
      'flutter-button': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterButtonProperties,
        HTMLElement
      >;
      'flutter-switch': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterSwitchProperties,
        HTMLElement
      >;
      'flutter-select': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterSelectProperties,
        HTMLElement
      >;
      'flutter-icon': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterIconProperties,
        HTMLElement
      >;
      'flutter-search': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterSearchProperties,
        HTMLElement
      >;
      'flutter-tab': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterTabProperties,
        HTMLElement
      >;
      'flutter-tab-item': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterTabItemProperties,
        HTMLElement
      >;
      'flutter-slider': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterSliderProperties,
        HTMLElement
      >;
      'flutter-bottom-sheet': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterBottomSheetProperties,
        HTMLElement
      >;
      'flutter-svg-img': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterSVGImgProperties,
        HTMLElement
      >;
      'flutter-showcase-view': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterShowCaseViewProperties,
        HTMLElement
      >;
      'flutter-showcase-item': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterShowCaseItemProperties,
        HTMLElement
      >;
      'flutter-showcase-description': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & FlutterShowCaseDescriptionProperties,
        HTMLElement
      >;
      'webf-listview-cupertino': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & WebFListViewCupertinoProperties,
        HTMLElement
      >;
      'webf-listview-material': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & WebFListViewMaterialProperties,
        HTMLElement
      >;
    }
  }

  interface HTMLElementTagNameMap {
    'flutter-button': HTMLElement & FlutterButtonProperties;
    'flutter-switch': HTMLElement & FlutterSwitchProperties;
    'flutter-select': HTMLElement & FlutterSelectProperties;
    'flutter-icon': HTMLElement & FlutterIconProperties;
    'flutter-search': HTMLElement & FlutterSearchProperties;
    'flutter-tab': HTMLElement & FlutterTabProperties;
    'flutter-tab-item': HTMLElement & FlutterTabItemProperties;
    'flutter-slider': HTMLElement & FlutterSliderProperties;
    'flutter-bottom-sheet': HTMLElement & FlutterBottomSheetProperties & FlutterBottomSheetMethods;
    'flutter-svg-img': HTMLElement & FlutterSVGImgProperties;
    'flutter-showcase-view': HTMLElement & FlutterShowCaseViewProperties & FlutterShowCaseViewMethods;
    'flutter-showcase-item': HTMLElement & FlutterShowCaseItemProperties;
    'flutter-showcase-description': HTMLElement & FlutterShowCaseDescriptionProperties;
    'webf-listview-cupertino': HTMLElement & WebFListViewCupertinoProperties & WebFListViewCupertinoMethods;
    'webf-listview-material': HTMLElement & WebFListViewMaterialProperties & WebFListViewMaterialMethods;
  }

  interface HTMLElementEventMap extends 
    FlutterButtonEvents,
    FlutterSwitchEvents,
    FlutterSelectEvents,
    FlutterTabEvents,
    FlutterSliderEvents,
    FlutterSVGImgEvents,
    WebFListViewCupertinoEvents,
    WebFListViewMaterialEvents {}
}