import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
interface FlutterShadcnContextMenuRadioGroupChangeEventDetail {
  value: string | null;
}
export interface FlutterShadcnContextMenuProps {
  /**
   * Whether the menu is open.
   * 
   * This value is updated automatically when the native menu opens/closes.
   * Setting it to `false` will close the menu.
   */
  open?: boolean;
  /**
   * Fired when menu opens.
   */
  onOpen?: (event: Event) => void;
  /**
   * Fired when menu closes.
   */
  onClose?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuElement extends WebFElementWithMethods<{
}> {
  /** Whether the menu is open. */
  open?: boolean;
}
/**
 * Properties for <flutter-shadcn-context-menu>
A context menu that appears on right-click.
@example
```html
<flutter-shadcn-context-menu>
  <flutter-shadcn-context-menu-trigger>
    <div>Right click here</div>
  </flutter-shadcn-context-menu-trigger>
  <flutter-shadcn-context-menu-content>
    <flutter-shadcn-context-menu-item>Cut</flutter-shadcn-context-menu-item>
    <flutter-shadcn-context-menu-item>Copy</flutter-shadcn-context-menu-item>
    <flutter-shadcn-context-menu-item>Paste</flutter-shadcn-context-menu-item>
  </flutter-shadcn-context-menu-content>
</flutter-shadcn-context-menu>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenu
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenu>
 * ```
 */
export const FlutterShadcnContextMenu = createWebFComponent<FlutterShadcnContextMenuElement, FlutterShadcnContextMenuProps>({
  tagName: 'flutter-shadcn-context-menu',
  displayName: 'FlutterShadcnContextMenu',
  // Map props to attributes
  attributeProps: [
    'open',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onOpen',
      eventName: 'open',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onClose',
      eventName: 'close',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuTriggerProps {
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuTriggerElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-context-menu-trigger>
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuTrigger>
 * ```
 */
export const FlutterShadcnContextMenuTrigger = createWebFComponent<FlutterShadcnContextMenuTriggerElement, FlutterShadcnContextMenuTriggerProps>({
  tagName: 'flutter-shadcn-context-menu-trigger',
  displayName: 'FlutterShadcnContextMenuTrigger',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuContentProps {
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-context-menu-content>
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuContent>
 * ```
 */
export const FlutterShadcnContextMenuContent = createWebFComponent<FlutterShadcnContextMenuContentElement, FlutterShadcnContextMenuContentProps>({
  tagName: 'flutter-shadcn-context-menu-content',
  displayName: 'FlutterShadcnContextMenuContent',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuItemProps {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;
  /**
   * Keyboard shortcut to display (e.g., "⌘Z", "Ctrl+C").
   * 
   * When the context menu is open, matching key presses will trigger the
   * item's `click` handler.
   */
  shortcut?: string;
  /**
   * Whether to use inset styling (adds left padding for alignment with checkbox/radio items).
   */
  inset?: boolean;
  /**
   * Fired when the item is clicked.
   */
  onClick?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuItemElement extends WebFElementWithMethods<{
}> {
  /** Whether the item is disabled. */
  disabled?: boolean;
  /** Keyboard shortcut to display (e.g., "⌘Z", "Ctrl+C"). */
  shortcut?: string;
  /** Whether to use inset styling (adds left padding for alignment with checkbox/radio items). */
  inset?: boolean;
}
/**
 * Properties for <flutter-shadcn-context-menu-item>
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuItem>
 * ```
 */
export const FlutterShadcnContextMenuItem = createWebFComponent<FlutterShadcnContextMenuItemElement, FlutterShadcnContextMenuItemProps>({
  tagName: 'flutter-shadcn-context-menu-item',
  displayName: 'FlutterShadcnContextMenuItem',
  // Map props to attributes
  attributeProps: [
    'disabled',
    'shortcut',
    'inset',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuSeparatorProps {
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuSeparatorElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-context-menu-separator>
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuSeparator
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuSeparator>
 * ```
 */
export const FlutterShadcnContextMenuSeparator = createWebFComponent<FlutterShadcnContextMenuSeparatorElement, FlutterShadcnContextMenuSeparatorProps>({
  tagName: 'flutter-shadcn-context-menu-separator',
  displayName: 'FlutterShadcnContextMenuSeparator',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuLabelProps {
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuLabelElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-context-menu-label>
A label/header for grouping context menu items.
@example
```html
<flutter-shadcn-context-menu-label>People</flutter-shadcn-context-menu-label>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuLabel
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuLabel>
 * ```
 */
export const FlutterShadcnContextMenuLabel = createWebFComponent<FlutterShadcnContextMenuLabelElement, FlutterShadcnContextMenuLabelProps>({
  tagName: 'flutter-shadcn-context-menu-label',
  displayName: 'FlutterShadcnContextMenuLabel',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuSubProps {
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuSubElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-context-menu-sub>
A container for nested submenu items.
Submenus open on hover (mouse) and can be toggled by tap/click.
@example
```html
<flutter-shadcn-context-menu-sub>
  <flutter-shadcn-context-menu-sub-trigger>More Tools</flutter-shadcn-context-menu-sub-trigger>
  <flutter-shadcn-context-menu-sub-content>
    <flutter-shadcn-context-menu-item>Save Page As...</flutter-shadcn-context-menu-item>
    <flutter-shadcn-context-menu-item>Create Shortcut...</flutter-shadcn-context-menu-item>
  </flutter-shadcn-context-menu-sub-content>
</flutter-shadcn-context-menu-sub>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuSub
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuSub>
 * ```
 */
export const FlutterShadcnContextMenuSub = createWebFComponent<FlutterShadcnContextMenuSubElement, FlutterShadcnContextMenuSubProps>({
  tagName: 'flutter-shadcn-context-menu-sub',
  displayName: 'FlutterShadcnContextMenuSub',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuSubTriggerProps {
  /**
   * Whether the submenu trigger is disabled.
   */
  disabled?: boolean;
  /**
   * Whether to use inset styling (adds left padding for alignment).
   */
  inset?: boolean;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuSubTriggerElement extends WebFElementWithMethods<{
}> {
  /** Whether the submenu trigger is disabled. */
  disabled?: boolean;
  /** Whether to use inset styling (adds left padding for alignment). */
  inset?: boolean;
}
/**
 * Properties for <flutter-shadcn-context-menu-sub-trigger>
The trigger element for a submenu.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuSubTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuSubTrigger>
 * ```
 */
export const FlutterShadcnContextMenuSubTrigger = createWebFComponent<FlutterShadcnContextMenuSubTriggerElement, FlutterShadcnContextMenuSubTriggerProps>({
  tagName: 'flutter-shadcn-context-menu-sub-trigger',
  displayName: 'FlutterShadcnContextMenuSubTrigger',
  // Map props to attributes
  attributeProps: [
    'disabled',
    'inset',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuSubContentProps {
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuSubContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-context-menu-sub-content>
Container for submenu items.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuSubContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuSubContent>
 * ```
 */
export const FlutterShadcnContextMenuSubContent = createWebFComponent<FlutterShadcnContextMenuSubContentElement, FlutterShadcnContextMenuSubContentProps>({
  tagName: 'flutter-shadcn-context-menu-sub-content',
  displayName: 'FlutterShadcnContextMenuSubContent',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuCheckboxItemProps {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;
  /**
   * Whether the checkbox is checked.
   */
  checked?: boolean;
  /**
   * Keyboard shortcut to display (e.g., "⌘B").
   */
  shortcut?: string;
  /**
   * Fired when the checked state changes.
   */
  onChange?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuCheckboxItemElement extends WebFElementWithMethods<{
}> {
  /** Whether the item is disabled. */
  disabled?: boolean;
  /** Whether the checkbox is checked. */
  checked?: boolean;
  /** Keyboard shortcut to display (e.g., "⌘B"). */
  shortcut?: string;
}
/**
 * Properties for <flutter-shadcn-context-menu-checkbox-item>
A menu item with a checkbox indicator.
@example
```html
<flutter-shadcn-context-menu-checkbox-item checked>
  Show Bookmarks Bar
</flutter-shadcn-context-menu-checkbox-item>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuCheckboxItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuCheckboxItem>
 * ```
 */
export const FlutterShadcnContextMenuCheckboxItem = createWebFComponent<FlutterShadcnContextMenuCheckboxItemElement, FlutterShadcnContextMenuCheckboxItemProps>({
  tagName: 'flutter-shadcn-context-menu-checkbox-item',
  displayName: 'FlutterShadcnContextMenuCheckboxItem',
  // Map props to attributes
  attributeProps: [
    'disabled',
    'checked',
    'shortcut',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuRadioGroupProps {
  /**
   * The value of the currently selected radio item.
   */
  value?: string;
  /**
   * Fired when the selected value changes.
   */
  onChange?: (event: CustomEvent<FlutterShadcnContextMenuRadioGroupChangeEventDetail>) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuRadioGroupElement extends WebFElementWithMethods<{
}> {
  /** The value of the currently selected radio item. */
  value?: string;
}
/**
 * Properties for <flutter-shadcn-context-menu-radio-group>
A group of radio items where only one can be selected.
@example
```html
<flutter-shadcn-context-menu-radio-group value="pedro">
  <flutter-shadcn-context-menu-label>People</flutter-shadcn-context-menu-label>
  <flutter-shadcn-context-menu-separator />
  <flutter-shadcn-context-menu-radio-item value="pedro">Pedro Duarte</flutter-shadcn-context-menu-radio-item>
  <flutter-shadcn-context-menu-radio-item value="colm">Colm Tuite</flutter-shadcn-context-menu-radio-item>
</flutter-shadcn-context-menu-radio-group>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuRadioGroup
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuRadioGroup>
 * ```
 */
export const FlutterShadcnContextMenuRadioGroup = createWebFComponent<FlutterShadcnContextMenuRadioGroupElement, FlutterShadcnContextMenuRadioGroupProps>({
  tagName: 'flutter-shadcn-context-menu-radio-group',
  displayName: 'FlutterShadcnContextMenuRadioGroup',
  // Map props to attributes
  attributeProps: [
    'value',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: CustomEvent<FlutterShadcnContextMenuRadioGroupChangeEventDetail>) => void) => (event: Event) => {
        callback(event as CustomEvent<FlutterShadcnContextMenuRadioGroupChangeEventDetail>);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnContextMenuRadioItemProps {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;
  /**
   * The value of this radio item.
   */
  value?: string;
  /**
   * Keyboard shortcut to display.
   */
  shortcut?: string;
  /**
   * Fired when the item is clicked.
   */
  onClick?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnContextMenuRadioItemElement extends WebFElementWithMethods<{
}> {
  /** Whether the item is disabled. */
  disabled?: boolean;
  /** The value of this radio item. */
  value?: string;
  /** Keyboard shortcut to display. */
  shortcut?: string;
}
/**
 * Properties for <flutter-shadcn-context-menu-radio-item>
A radio-style menu item within a radio group.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnContextMenuRadioItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnContextMenuRadioItem>
 * ```
 */
export const FlutterShadcnContextMenuRadioItem = createWebFComponent<FlutterShadcnContextMenuRadioItemElement, FlutterShadcnContextMenuRadioItemProps>({
  tagName: 'flutter-shadcn-context-menu-radio-item',
  displayName: 'FlutterShadcnContextMenuRadioItem',
  // Map props to attributes
  attributeProps: [
    'disabled',
    'value',
    'shortcut',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});