/**
 * Properties for <flutter-cupertino-context-menu>.
 * Wraps Flutter's CupertinoContextMenu.
 */
interface ContextMenuAction {
  /** Button label text. */
  text: string;
  /** Optional trailing icon name (Cupertino icon key). */
  icon?: string;
  /** Marks this action as destructive (red). */
  destructive?: boolean;
  /** Marks this action as the default action. */
  default?: boolean;
  /**
   * Optional event name associated with this action.
   * If omitted, a name may be derived from the text.
   */
  event?: string;
}

interface FlutterCupertinoContextMenuProperties {
  /**
   * Whether to enable haptic feedback when the menu is opened.
   * Default: false.
   */
  'enable-haptic-feedback'?: boolean;
}

interface FlutterCupertinoContextMenuMethods {
  /**
   * Set the list of actions displayed in the context menu.
   */
  setActions(actions: ContextMenuAction[]): void;
}

interface FlutterCupertinoContextMenuSelectDetail {
  /** Zero-based index of the selected action. */
  index: number;
  /** Action text. */
  text: string;
  /** Event name for this action. */
  event: string;
  /** Whether the action is destructive. */
  destructive: boolean;
  /** Whether the action is the default one. */
  default: boolean;
}

interface FlutterCupertinoContextMenuEvents {
  /**
   * Fired when an action is selected.
   * detail contains metadata about the selected action.
   */
  select: CustomEvent<FlutterCupertinoContextMenuSelectDetail>;
}

