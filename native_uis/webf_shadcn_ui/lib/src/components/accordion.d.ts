/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-accordion>
 *
 * A collapsible accordion component.
 *
 * @example
 * ```html
 * <flutter-shadcn-accordion type="single">
 *   <flutter-shadcn-accordion-item value="item-1">
 *     <flutter-shadcn-accordion-trigger>Is it accessible?</flutter-shadcn-accordion-trigger>
 *     <flutter-shadcn-accordion-content>Yes. It adheres to the WAI-ARIA design pattern.</flutter-shadcn-accordion-content>
 *   </flutter-shadcn-accordion-item>
 * </flutter-shadcn-accordion>
 * ```
 */
interface FlutterShadcnAccordionProperties {
  /**
   * Selection type.
   * - 'single': Only one item can be expanded
   * - 'multiple': Multiple items can be expanded
   * Default: 'single'
   */
  type?: string;

  /**
   * Currently expanded item(s) value(s).
   * For single type: string, for multiple type: comma-separated string
   */
  value?: string;

  /**
   * Allow collapsing all items in single mode.
   * Default: true
   */
  collapsible?: boolean;
}

interface FlutterShadcnAccordionEvents {
  change: Event;
}

interface FlutterShadcnAccordionItemProperties {
  value: string;
  disabled?: boolean;
}

interface FlutterShadcnAccordionItemEvents {}

interface FlutterShadcnAccordionTriggerProperties {}
interface FlutterShadcnAccordionTriggerEvents {}

interface FlutterShadcnAccordionContentProperties {}
interface FlutterShadcnAccordionContentEvents {}
