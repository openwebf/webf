/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-collapsible>
 *
 * A collapsible section.
 *
 * @example
 * ```html
 * <flutter-shadcn-collapsible open>
 *   <flutter-shadcn-collapsible-trigger>
 *     <span>Toggle</span>
 *   </flutter-shadcn-collapsible-trigger>
 *   <flutter-shadcn-collapsible-content>
 *     Hidden content here
 *   </flutter-shadcn-collapsible-content>
 * </flutter-shadcn-collapsible>
 * ```
 */
interface FlutterShadcnCollapsibleProperties {
  /**
   * Whether the section is expanded.
   */
  open?: boolean;

  /**
   * Disable the collapsible.
   */
  disabled?: boolean;
}

interface FlutterShadcnCollapsibleEvents {
  /** Fired when open state changes. */
  change: Event;
}

interface FlutterShadcnCollapsibleTriggerProperties {}
interface FlutterShadcnCollapsibleTriggerEvents {}

interface FlutterShadcnCollapsibleContentProperties {}
interface FlutterShadcnCollapsibleContentEvents {}
