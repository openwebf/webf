interface FlutterTabProperties {
  // Children should be flutter-tab-item elements
}

interface FlutterTabEvents {
  tabchange: CustomEvent<number>;
}

interface FlutterTabItemProperties {
  title: string;
}