/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-tabs>
 *
 * A tabbed interface component.
 *
 * @example
 * ```html
 * <flutter-shadcn-tabs value="account">
 *   <flutter-shadcn-tabs-list>
 *     <flutter-shadcn-tabs-trigger value="account">Account</flutter-shadcn-tabs-trigger>
 *     <flutter-shadcn-tabs-trigger value="password">Password</flutter-shadcn-tabs-trigger>
 *   </flutter-shadcn-tabs-list>
 *   <flutter-shadcn-tabs-content value="account">Account content here.</flutter-shadcn-tabs-content>
 *   <flutter-shadcn-tabs-content value="password">Password content here.</flutter-shadcn-tabs-content>
 * </flutter-shadcn-tabs>
 * ```
 */
interface FlutterShadcnTabsProperties {
  /**
   * Currently active tab value.
   */
  value?: string;

  /**
   * Default tab value (uncontrolled mode).
   */
  'default-value'?: string;
}

/**
 * Events emitted by <flutter-shadcn-tabs>
 */
interface FlutterShadcnTabsEvents {
  /** Fired when active tab changes. */
  change: Event;
}

/**
 * Properties for <flutter-shadcn-tabs-list>
 * Container for tab triggers.
 */
interface FlutterShadcnTabsListProperties {}

interface FlutterShadcnTabsListEvents {}

/**
 * Properties for <flutter-shadcn-tabs-trigger>
 * Individual tab trigger button.
 */
interface FlutterShadcnTabsTriggerProperties {
  /**
   * Value identifier for this tab.
   */
  value: string;

  /**
   * Disable this tab.
   */
  disabled?: boolean;
}

interface FlutterShadcnTabsTriggerEvents {}

/**
 * Properties for <flutter-shadcn-tabs-content>
 * Content panel for a tab.
 */
interface FlutterShadcnTabsContentProperties {
  /**
   * Value identifier matching a trigger.
   */
  value: string;
}

interface FlutterShadcnTabsContentEvents {}
