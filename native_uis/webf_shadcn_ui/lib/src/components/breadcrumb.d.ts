/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-breadcrumb>
 *
 * A breadcrumb navigation component that displays the current page location
 * within a navigational hierarchy.
 *
 * @example
 * ```html
 * <flutter-shadcn-breadcrumb>
 *   <flutter-shadcn-breadcrumb-item>
 *     <flutter-shadcn-breadcrumb-link>Home</flutter-shadcn-breadcrumb-link>
 *   </flutter-shadcn-breadcrumb-item>
 *   <flutter-shadcn-breadcrumb-item>
 *     <flutter-shadcn-breadcrumb-link>Components</flutter-shadcn-breadcrumb-link>
 *   </flutter-shadcn-breadcrumb-item>
 *   <flutter-shadcn-breadcrumb-item>
 *     <flutter-shadcn-breadcrumb-page>Breadcrumb</flutter-shadcn-breadcrumb-page>
 *   </flutter-shadcn-breadcrumb-item>
 * </flutter-shadcn-breadcrumb>
 * ```
 */
interface FlutterShadcnBreadcrumbProperties {
  /**
   * Spacing between breadcrumb items.
   * @default 10
   */
  spacing?: number;

  /**
   * Custom separator between items.
   * Predefined values: 'slash', '/', 'arrow', '>', 'dash', '-', 'dot', '.', 'chevron'
   * Or any custom string to use as separator text.
   * @default chevron icon
   */
  separator?: 'slash' | 'arrow' | 'dash' | 'dot' | 'chevron' | string;
}

interface FlutterShadcnBreadcrumbEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-list>
 * Container for breadcrumb items (for backwards compatibility).
 */
interface FlutterShadcnBreadcrumbListProperties {}

interface FlutterShadcnBreadcrumbListEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-item>
 * Individual breadcrumb item container.
 */
interface FlutterShadcnBreadcrumbItemProperties {}

interface FlutterShadcnBreadcrumbItemEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-link>
 * Clickable breadcrumb link with hover effects.
 */
interface FlutterShadcnBreadcrumbLinkProperties {
  /**
   * Link destination URL.
   */
  href?: string;
}

/**
 * Events emitted by <flutter-shadcn-breadcrumb-link>
 */
interface FlutterShadcnBreadcrumbLinkEvents {
  /** Fired when link is clicked. */
  click: Event;
}

/**
 * Properties for <flutter-shadcn-breadcrumb-page>
 * Current page indicator (non-clickable, highlighted text).
 */
interface FlutterShadcnBreadcrumbPageProperties {}

interface FlutterShadcnBreadcrumbPageEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-separator>
 * Separator between breadcrumb items (chevron icon by default).
 */
interface FlutterShadcnBreadcrumbSeparatorProperties {
  /**
   * Size of the separator icon.
   * @default 14
   */
  size?: number;
}

interface FlutterShadcnBreadcrumbSeparatorEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-ellipsis>
 * Ellipsis indicator for collapsed/hidden breadcrumb sections.
 *
 * @example
 * ```html
 * <flutter-shadcn-breadcrumb-item>
 *   <flutter-shadcn-breadcrumb-ellipsis />
 * </flutter-shadcn-breadcrumb-item>
 * ```
 */
interface FlutterShadcnBreadcrumbEllipsisProperties {
  /**
   * Size of the ellipsis icon.
   * @default 16
   */
  size?: number;
}

interface FlutterShadcnBreadcrumbEllipsisEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-dropdown>
 * Dropdown menu for showing collapsed breadcrumb items.
 *
 * @example
 * ```html
 * <flutter-shadcn-breadcrumb-dropdown>
 *   <flutter-shadcn-breadcrumb-ellipsis />
 *   <flutter-shadcn-breadcrumb-dropdown-item>Documentation</flutter-shadcn-breadcrumb-dropdown-item>
 *   <flutter-shadcn-breadcrumb-dropdown-item>Themes</flutter-shadcn-breadcrumb-dropdown-item>
 * </flutter-shadcn-breadcrumb-dropdown>
 * ```
 */
interface FlutterShadcnBreadcrumbDropdownProperties {
  /**
   * Whether to show the dropdown arrow icon.
   * @default true
   */
  showArrow?: boolean;
}

interface FlutterShadcnBreadcrumbDropdownEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-dropdown-item>
 * Individual item in a breadcrumb dropdown menu.
 */
interface FlutterShadcnBreadcrumbDropdownItemProperties {}

/**
 * Events emitted by <flutter-shadcn-breadcrumb-dropdown-item>
 */
interface FlutterShadcnBreadcrumbDropdownItemEvents {
  /** Fired when dropdown item is clicked. */
  click: Event;
}
