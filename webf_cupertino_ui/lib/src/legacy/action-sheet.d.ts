interface FlutterCupertinoActionSheetAction {
  text: string;
  isDefault?: boolean;
  isDestructive?: boolean;
  event?: string;
}

interface FlutterCupertinoActionSheetOptions {
  title?: string;
  message?: string;
  actions?: FlutterCupertinoActionSheetAction[];
  cancelButton?: FlutterCupertinoActionSheetAction;
}

interface FlutterCupertinoActionSheetMethods {
  show(options: FlutterCupertinoActionSheetOptions): void;
}

interface FlutterCupertinoActionSheetSelectDetail {
  text: string;
  event: string;
  isDefault: boolean;
  isDestructive: boolean;
  index?: number;
}

interface FlutterCupertinoActionSheetEvents {
  select: CustomEvent<FlutterCupertinoActionSheetSelectDetail>;
}