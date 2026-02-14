/**
 * Properties for <flutter-cupertino-menu>.
 * A tap-triggered popup menu wrapping Flutter's showMenu with Cupertino styling.
 */

interface MenuAction {
  /** Button label text. */
  text: string;
  /** Optional trailing icon name (Cupertino icon key). */
  icon?: string;
  /** Marks this action as destructive (red). */
  destructive?: boolean;
  /**
   * Optional event name associated with this action.
   * If omitted, a name is derived from the text.
   */
  event?: string;
}

interface FlutterCupertinoMenuProperties {
  /**
   * Whether the menu trigger is disabled.
   * When disabled, tapping the child will not open the menu.
   * @default false
   */
  disabled?: boolean;
}

interface FlutterCupertinoMenuMethods {
  /**
   * Set the list of actions displayed in the popup menu.
   */
  setActions(actions: MenuAction[]): void;
}

interface FlutterCupertinoMenuSelectDetail {
  /** Zero-based index of the selected action. */
  index: number;
  /** Action text. */
  text: string;
  /** Event name for this action. */
  event: string;
  /** Whether the action is destructive. */
  destructive: boolean;
}

interface FlutterCupertinoMenuEvents {
  /**
   * Fired when an action is selected.
   * detail contains metadata about the selected action.
   */
  select: CustomEvent<FlutterCupertinoMenuSelectDetail>;
}
