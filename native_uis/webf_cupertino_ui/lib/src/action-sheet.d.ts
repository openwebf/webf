/**
 * Properties for <flutter-cupertino-action-sheet>.
 * Imperative wrapper around Flutter's CupertinoActionSheet.
 */
interface FlutterCupertinoActionSheetProperties {}

interface FlutterCupertinoActionSheetAction {
  /** Button label text. */
  text: string;
  /** Marks this action as the default (emphasized) action. */
  isDefault?: boolean;
  /** Marks this action as destructive (red). */
  isDestructive?: boolean;
  /**
   * Optional event name associated with this action.
   * If omitted, a name is derived from the text.
   */
  event?: string;
}

interface FlutterCupertinoActionSheetOptions {
  /** Optional title text shown at the top of the sheet. */
  title?: string;
  /** Optional message/body text shown below the title. */
  message?: string;
  /**
   * List of action buttons.
   * Each action maps to a row in the sheet.
   */
  actions?: FlutterCupertinoActionSheetAction[];
  /**
   * Optional cancel button displayed separately at the bottom.
   */
  cancelButton?: FlutterCupertinoActionSheetAction;
}

interface FlutterCupertinoActionSheetMethods {
  /**
   * Show the action sheet with the given options.
   */
  show(options: FlutterCupertinoActionSheetOptions): void;
}

interface FlutterCupertinoActionSheetSelectDetail {
  /** Action text. */
  text: string;
  /** Event name for this action. */
  event: string;
  /** Whether the action is the default one. */
  isDefault: boolean;
  /** Whether the action is destructive. */
  isDestructive: boolean;
  /** Zero-based index of the action within `actions`, if applicable. */
  index?: number;
}

interface FlutterCupertinoActionSheetEvents {
  /**
   * Fired when any action (including cancel) is selected.
   * detail contains metadata about the selected action.
   */
  select: CustomEvent<FlutterCupertinoActionSheetSelectDetail>;
}

