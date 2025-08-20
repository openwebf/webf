interface FlutterShowcaseViewProperties {
  disableBarrierInteraction?: boolean;
  tooltipPosition?: string;
}

interface FlutterShowcaseViewMethods {
  start(): void;
  dismiss(): void;
}

interface FlutterShowcaseViewEvents {
  finish: Event;
}

interface FlutterShowcaseItemProperties {
  // Properties for showcase item
}

interface FlutterShowcaseDescriptionProperties {
  // Properties for showcase description
}