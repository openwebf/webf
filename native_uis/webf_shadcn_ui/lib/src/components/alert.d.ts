/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-alert>
 *
 * An alert component for displaying important messages.
 *
 * @example
 * ```html
 * <flutter-shadcn-alert variant="default">
 *   <flutter-shadcn-alert-title>Heads up!</flutter-shadcn-alert-title>
 *   <flutter-shadcn-alert-description>
 *     You can add components to your app using the CLI.
 *   </flutter-shadcn-alert-description>
 * </flutter-shadcn-alert>
 * ```
 */
interface FlutterShadcnAlertProperties {
  /**
   * Visual variant of the alert.
   * - 'default': Standard informational alert
   * - 'destructive': Red destructive/error alert
   * Default: 'default'
   */
  variant?: string;

  /**
   * Icon name to display in the alert.
   */
  icon?: string;
}

interface FlutterShadcnAlertEvents {}

/**
 * Properties for <flutter-shadcn-alert-title>
 * Title slot for the alert.
 */
interface FlutterShadcnAlertTitleProperties {}

interface FlutterShadcnAlertTitleEvents {}

/**
 * Properties for <flutter-shadcn-alert-description>
 * Description slot for the alert.
 */
interface FlutterShadcnAlertDescriptionProperties {}

interface FlutterShadcnAlertDescriptionEvents {}
