/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-sheet>
 *
 * A slide-out panel component.
 *
 * @example
 * ```html
 * <flutter-shadcn-sheet side="right" open>
 *   <flutter-shadcn-sheet-header>
 *     <flutter-shadcn-sheet-title>Settings</flutter-shadcn-sheet-title>
 *   </flutter-shadcn-sheet-header>
 *   <flutter-shadcn-sheet-content>
 *     Sheet content here.
 *   </flutter-shadcn-sheet-content>
 * </flutter-shadcn-sheet>
 * ```
 */
interface FlutterShadcnSheetProperties {
  /**
   * Whether the sheet is open.
   */
  open?: boolean;

  /**
   * Side from which the sheet appears.
   * Options: 'top', 'bottom', 'left', 'right'
   * Default: 'right'
   */
  side?: string;

  /**
   * Close when clicking outside.
   * Default: true
   */
  'close-on-outside-click'?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-sheet>
 */
interface FlutterShadcnSheetEvents {
  /** Fired when sheet opens. */
  open: Event;

  /** Fired when sheet closes. */
  close: Event;
}

/**
 * Properties for <flutter-shadcn-sheet-header>
 * Header slot for sheet.
 */
interface FlutterShadcnSheetHeaderProperties {}

interface FlutterShadcnSheetHeaderEvents {}

/**
 * Properties for <flutter-shadcn-sheet-title>
 * Title within sheet header.
 */
interface FlutterShadcnSheetTitleProperties {}

interface FlutterShadcnSheetTitleEvents {}

/**
 * Properties for <flutter-shadcn-sheet-description>
 * Description within sheet header.
 */
interface FlutterShadcnSheetDescriptionProperties {}

interface FlutterShadcnSheetDescriptionEvents {}

/**
 * Properties for <flutter-shadcn-sheet-content>
 * Main content slot for sheet.
 */
interface FlutterShadcnSheetContentProperties {}

interface FlutterShadcnSheetContentEvents {}

/**
 * Properties for <flutter-shadcn-sheet-footer>
 * Footer slot for sheet.
 */
interface FlutterShadcnSheetFooterProperties {}

interface FlutterShadcnSheetFooterEvents {}
