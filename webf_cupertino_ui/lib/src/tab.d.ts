interface FlutterCupertinoTabProperties {
  // Methods
  switchTab(index: int): void;
}

interface FlutterCupertinoTabEvents {
  change: CustomEvent<int>;
}

interface FlutterCupertinoTabItemProperties {
  title?: string;
}

// Type alias for clarity
type int = number;