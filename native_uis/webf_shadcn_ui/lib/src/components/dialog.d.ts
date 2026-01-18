/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-dialog>
 *
 * A modal dialog component.
 *
 * @example
 * ```html
 * <flutter-shadcn-dialog open>
 *   <flutter-shadcn-dialog-header>
 *     <flutter-shadcn-dialog-title>Are you sure?</flutter-shadcn-dialog-title>
 *     <flutter-shadcn-dialog-description>
 *       This action cannot be undone.
 *     </flutter-shadcn-dialog-description>
 *   </flutter-shadcn-dialog-header>
 *   <flutter-shadcn-dialog-content>
 *     Dialog content here.
 *   </flutter-shadcn-dialog-content>
 *   <flutter-shadcn-dialog-footer>
 *     <flutter-shadcn-button variant="outline">Cancel</flutter-shadcn-button>
 *     <flutter-shadcn-button>Continue</flutter-shadcn-button>
 *   </flutter-shadcn-dialog-footer>
 * </flutter-shadcn-dialog>
 * ```
 */
interface FlutterShadcnDialogProperties {
  /**
   * Whether the dialog is open.
   */
  open?: boolean;

  /**
   * Close when clicking outside the dialog.
   * Default: true
   */
  'close-on-outside-click'?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-dialog>
 */
interface FlutterShadcnDialogEvents {
  /** Fired when dialog opens. */
  open: Event;

  /** Fired when dialog closes. */
  close: Event;
}

/**
 * Properties for <flutter-shadcn-dialog-header>
 * Header slot for dialog.
 */
interface FlutterShadcnDialogHeaderProperties {}

interface FlutterShadcnDialogHeaderEvents {}

/**
 * Properties for <flutter-shadcn-dialog-title>
 * Title within dialog header.
 */
interface FlutterShadcnDialogTitleProperties {}

interface FlutterShadcnDialogTitleEvents {}

/**
 * Properties for <flutter-shadcn-dialog-description>
 * Description within dialog header.
 */
interface FlutterShadcnDialogDescriptionProperties {}

interface FlutterShadcnDialogDescriptionEvents {}

/**
 * Properties for <flutter-shadcn-dialog-content>
 * Main content slot for dialog.
 */
interface FlutterShadcnDialogContentProperties {}

interface FlutterShadcnDialogContentEvents {}

/**
 * Properties for <flutter-shadcn-dialog-footer>
 * Footer slot for dialog actions.
 */
interface FlutterShadcnDialogFooterProperties {}

interface FlutterShadcnDialogFooterEvents {}
