interface FlutterCupertinoModalPopupProperties {
  visible?: boolean;
  height?: int;
  surfacePainted?: boolean;
  maskClosable?: boolean;
  backgroundOpacity?: number;
}

interface FlutterCupertinoModalPopupMethods {
  show(): void;
  hide(): void;
}

interface FlutterCupertinoModalPopupEvents {
  close: CustomEvent;
}
