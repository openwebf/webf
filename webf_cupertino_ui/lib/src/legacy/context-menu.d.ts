interface ContextMenuAction {
  text: string;
  icon?: string;
  destructive?: boolean;
  default?: boolean;
  event?: string;
}

interface FlutterCupertinoContextMenuProperties {
  'enable-haptic-feedback'?: boolean;
}

interface FlutterCupertinoContextMenuMethods {
  // Methods
  setActions(actions: ContextMenuAction[]): void;
}

interface FlutterCupertinoContextMenuSelectDetail {
  index: number;
  text: string;
  event: string;
  destructive: boolean;
  default: boolean;
}

interface FlutterCupertinoContextMenuEvents {
  select: CustomEvent<FlutterCupertinoContextMenuSelectDetail>;
}
