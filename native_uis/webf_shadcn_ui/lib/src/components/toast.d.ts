/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-toast>
 *
 * A toast notification component.
 *
 * @example
 * ```html
 * <flutter-shadcn-toast variant="default" title="Success" description="Your changes have been saved." />
 * ```
 */
interface FlutterShadcnToastProperties {
  /**
   * Visual variant of the toast.
   * - 'default': Standard toast
   * - 'destructive': Red error toast
   * Default: 'default'
   */
  variant?: string;

  /**
   * Title of the toast.
   */
  title?: string;

  /**
   * Description text.
   */
  description?: string;

  /**
   * Duration in milliseconds before auto-dismiss.
   * Set to 0 to disable auto-dismiss.
   * Default: 5000
   */
  duration?: string;

  /**
   * Show close button.
   */
  closable?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-toast>
 */
interface FlutterShadcnToastEvents {
  /** Fired when toast is dismissed. */
  close: Event;
}
