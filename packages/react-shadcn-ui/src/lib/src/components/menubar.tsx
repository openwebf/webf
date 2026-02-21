import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
interface FlutterShadcnMenubarRadioGroupChangeEventDetail {
  value: string | null;
}
export interface FlutterShadcnMenubarProps {
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
export interface FlutterShadcnMenubarElement extends WebFElementWithMethods<{
}> {
}
/**
 * A horizontal menubar that contains a list of menus.
 * @example
 * ```tsx
 * <FlutterShadcnMenubar>
 *   <FlutterShadcnMenubarMenu>
 *     <FlutterShadcnMenubarTrigger>File</FlutterShadcnMenubarTrigger>
 *     <FlutterShadcnMenubarContent>
 *       <FlutterShadcnMenubarItem>New Tab</FlutterShadcnMenubarItem>
 *     </FlutterShadcnMenubarContent>
 *   </FlutterShadcnMenubarMenu>
 * </FlutterShadcnMenubar>
 * ```
 */
export const FlutterShadcnMenubar = createWebFComponent<FlutterShadcnMenubarElement, FlutterShadcnMenubarProps>({
  tagName: 'flutter-shadcn-menubar',
  displayName: 'FlutterShadcnMenubar',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarMenuProps {
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
export interface FlutterShadcnMenubarMenuElement extends WebFElementWithMethods<{
}> {
}
/**
 * A single menu in the menubar, containing a trigger and content.
 */
export const FlutterShadcnMenubarMenu = createWebFComponent<FlutterShadcnMenubarMenuElement, FlutterShadcnMenubarMenuProps>({
  tagName: 'flutter-shadcn-menubar-menu',
  displayName: 'FlutterShadcnMenubarMenu',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarTriggerProps {
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
export interface FlutterShadcnMenubarTriggerElement extends WebFElementWithMethods<{
}> {
}
/**
 * The trigger label for a menubar menu.
 */
export const FlutterShadcnMenubarTrigger = createWebFComponent<FlutterShadcnMenubarTriggerElement, FlutterShadcnMenubarTriggerProps>({
  tagName: 'flutter-shadcn-menubar-trigger',
  displayName: 'FlutterShadcnMenubarTrigger',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarContentProps {
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
export interface FlutterShadcnMenubarContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Container for the dropdown menu items within a menubar menu.
 */
export const FlutterShadcnMenubarContent = createWebFComponent<FlutterShadcnMenubarContentElement, FlutterShadcnMenubarContentProps>({
  tagName: 'flutter-shadcn-menubar-content',
  displayName: 'FlutterShadcnMenubarContent',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarItemProps {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;
  /**
   * Keyboard shortcut to display (e.g., "⌘T", "Ctrl+N").
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
export interface FlutterShadcnMenubarItemElement extends WebFElementWithMethods<{
}> {
  /** Whether the item is disabled. */
  disabled?: boolean;
  /** Keyboard shortcut to display. */
  shortcut?: string;
  /** Whether to use inset styling. */
  inset?: boolean;
}
/**
 * A menu item within a menubar menu.
 */
export const FlutterShadcnMenubarItem = createWebFComponent<FlutterShadcnMenubarItemElement, FlutterShadcnMenubarItemProps>({
  tagName: 'flutter-shadcn-menubar-item',
  displayName: 'FlutterShadcnMenubarItem',
  attributeProps: [
    'disabled',
    'shortcut',
    'inset',
  ],
  attributeMap: {},
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  defaultProps: {},
});
export interface FlutterShadcnMenubarSeparatorProps {
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
export interface FlutterShadcnMenubarSeparatorElement extends WebFElementWithMethods<{
}> {
}
/**
 * A separator line within a menubar menu.
 */
export const FlutterShadcnMenubarSeparator = createWebFComponent<FlutterShadcnMenubarSeparatorElement, FlutterShadcnMenubarSeparatorProps>({
  tagName: 'flutter-shadcn-menubar-separator',
  displayName: 'FlutterShadcnMenubarSeparator',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarLabelProps {
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
export interface FlutterShadcnMenubarLabelElement extends WebFElementWithMethods<{
}> {
}
/**
 * A label/header for grouping menubar items.
 */
export const FlutterShadcnMenubarLabel = createWebFComponent<FlutterShadcnMenubarLabelElement, FlutterShadcnMenubarLabelProps>({
  tagName: 'flutter-shadcn-menubar-label',
  displayName: 'FlutterShadcnMenubarLabel',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarSubProps {
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
export interface FlutterShadcnMenubarSubElement extends WebFElementWithMethods<{
}> {
}
/**
 * A container for nested submenu items within a menubar menu.
 */
export const FlutterShadcnMenubarSub = createWebFComponent<FlutterShadcnMenubarSubElement, FlutterShadcnMenubarSubProps>({
  tagName: 'flutter-shadcn-menubar-sub',
  displayName: 'FlutterShadcnMenubarSub',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarSubTriggerProps {
  /**
   * Whether the submenu trigger is disabled.
   */
  disabled?: boolean;
  /**
   * Whether to use inset styling.
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
export interface FlutterShadcnMenubarSubTriggerElement extends WebFElementWithMethods<{
}> {
  /** Whether the submenu trigger is disabled. */
  disabled?: boolean;
  /** Whether to use inset styling. */
  inset?: boolean;
}
/**
 * The trigger element for a menubar submenu.
 */
export const FlutterShadcnMenubarSubTrigger = createWebFComponent<FlutterShadcnMenubarSubTriggerElement, FlutterShadcnMenubarSubTriggerProps>({
  tagName: 'flutter-shadcn-menubar-sub-trigger',
  displayName: 'FlutterShadcnMenubarSubTrigger',
  attributeProps: [
    'disabled',
    'inset',
  ],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarSubContentProps {
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
export interface FlutterShadcnMenubarSubContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Container for submenu items within a menubar.
 */
export const FlutterShadcnMenubarSubContent = createWebFComponent<FlutterShadcnMenubarSubContentElement, FlutterShadcnMenubarSubContentProps>({
  tagName: 'flutter-shadcn-menubar-sub-content',
  displayName: 'FlutterShadcnMenubarSubContent',
  attributeProps: [],
  attributeMap: {},
  events: [],
  defaultProps: {},
});
export interface FlutterShadcnMenubarCheckboxItemProps {
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
export interface FlutterShadcnMenubarCheckboxItemElement extends WebFElementWithMethods<{
}> {
  /** Whether the item is disabled. */
  disabled?: boolean;
  /** Whether the checkbox is checked. */
  checked?: boolean;
  /** Keyboard shortcut to display. */
  shortcut?: string;
}
/**
 * A menu item with a checkbox indicator in a menubar menu.
 */
export const FlutterShadcnMenubarCheckboxItem = createWebFComponent<FlutterShadcnMenubarCheckboxItemElement, FlutterShadcnMenubarCheckboxItemProps>({
  tagName: 'flutter-shadcn-menubar-checkbox-item',
  displayName: 'FlutterShadcnMenubarCheckboxItem',
  attributeProps: [
    'disabled',
    'checked',
    'shortcut',
  ],
  attributeMap: {},
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  defaultProps: {},
});
export interface FlutterShadcnMenubarRadioGroupProps {
  /**
   * The value of the currently selected radio item.
   */
  value?: string;
  /**
   * Fired when the selected value changes.
   */
  onChange?: (event: CustomEvent<FlutterShadcnMenubarRadioGroupChangeEventDetail>) => void;
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
export interface FlutterShadcnMenubarRadioGroupElement extends WebFElementWithMethods<{
}> {
  /** The value of the currently selected radio item. */
  value?: string;
}
/**
 * A group of radio items where only one can be selected.
 */
export const FlutterShadcnMenubarRadioGroup = createWebFComponent<FlutterShadcnMenubarRadioGroupElement, FlutterShadcnMenubarRadioGroupProps>({
  tagName: 'flutter-shadcn-menubar-radio-group',
  displayName: 'FlutterShadcnMenubarRadioGroup',
  attributeProps: [
    'value',
  ],
  attributeMap: {},
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: CustomEvent<FlutterShadcnMenubarRadioGroupChangeEventDetail>) => void) => (event: Event) => {
        callback(event as CustomEvent<FlutterShadcnMenubarRadioGroupChangeEventDetail>);
      },
    },
  ],
  defaultProps: {},
});
export interface FlutterShadcnMenubarRadioItemProps {
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
export interface FlutterShadcnMenubarRadioItemElement extends WebFElementWithMethods<{
}> {
  /** Whether the item is disabled. */
  disabled?: boolean;
  /** The value of this radio item. */
  value?: string;
  /** Keyboard shortcut to display. */
  shortcut?: string;
}
/**
 * A radio-style menu item within a menubar radio group.
 */
export const FlutterShadcnMenubarRadioItem = createWebFComponent<FlutterShadcnMenubarRadioItemElement, FlutterShadcnMenubarRadioItemProps>({
  tagName: 'flutter-shadcn-menubar-radio-item',
  displayName: 'FlutterShadcnMenubarRadioItem',
  attributeProps: [
    'disabled',
    'value',
    'shortcut',
  ],
  attributeMap: {},
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  defaultProps: {},
});
