interface FlutterCupertinoAlertProperties {
  title?: string;
  message?: string;
  'cancel-text'?: string;
  'cancel-destructive'?: string;
  'cancel-default'?: string;
  'cancel-text-style'?: string;
  'confirm-text'?: string;
  'confirm-default'?: string;
  'confirm-destructive'?: string;
  'confirm-text-style'?: string;
}

interface FlutterCupertinoAlertOptions {
  title?: string;
  message?: string;
}

interface FlutterCupertinoAlertMethods {
  show(options?: FlutterCupertinoAlertOptions): void;
  hide(): void;
}

interface FlutterCupertinoAlertEvents {
  cancel: CustomEvent;
  confirm: CustomEvent;
}