/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-breadcrumb>
 *
 * A breadcrumb navigation component.
 *
 * @example
 * ```html
 * <flutter-shadcn-breadcrumb>
 *   <flutter-shadcn-breadcrumb-list>
 *     <flutter-shadcn-breadcrumb-item>
 *       <flutter-shadcn-breadcrumb-link href="/">Home</flutter-shadcn-breadcrumb-link>
 *     </flutter-shadcn-breadcrumb-item>
 *     <flutter-shadcn-breadcrumb-separator />
 *     <flutter-shadcn-breadcrumb-item>
 *       <flutter-shadcn-breadcrumb-page>Current</flutter-shadcn-breadcrumb-page>
 *     </flutter-shadcn-breadcrumb-item>
 *   </flutter-shadcn-breadcrumb-list>
 * </flutter-shadcn-breadcrumb>
 * ```
 */
interface FlutterShadcnBreadcrumbProperties {}

interface FlutterShadcnBreadcrumbEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-list>
 * Container for breadcrumb items.
 */
interface FlutterShadcnBreadcrumbListProperties {}

interface FlutterShadcnBreadcrumbListEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-item>
 * Individual breadcrumb item.
 */
interface FlutterShadcnBreadcrumbItemProperties {}

interface FlutterShadcnBreadcrumbItemEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-link>
 * Clickable breadcrumb link.
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
 * Current page indicator (non-clickable).
 */
interface FlutterShadcnBreadcrumbPageProperties {}

interface FlutterShadcnBreadcrumbPageEvents {}

/**
 * Properties for <flutter-shadcn-breadcrumb-separator>
 * Separator between breadcrumb items.
 */
interface FlutterShadcnBreadcrumbSeparatorProperties {}

interface FlutterShadcnBreadcrumbSeparatorEvents {}
