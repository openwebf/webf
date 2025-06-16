interface FlutterCupertinoModalPopupProperties {
  visible?: boolean;
  height?: int;
  surfacePainted?: boolean;
  maskClosable?: boolean;
  backgroundOpacity?: number;
  show(): void;
  hide(): void;
}

interface FlutterCupertinoModalPopupEvents {
  close: CustomEvent;
}
