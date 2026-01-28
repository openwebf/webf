/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-image>
 *
 * An image component with loading and error states.
 *
 * @example
 * ```html
 * <flutter-shadcn-image
 *   src="https://example.com/image.jpg"
 *   alt="Example image"
 *   width="200"
 *   height="150"
 * />
 * ```
 */
interface FlutterShadcnImageProperties {
  /**
   * Image source URL.
   */
  src?: string;

  /**
   * Alt text for accessibility.
   */
  alt?: string;

  /**
   * Image width in pixels.
   */
  width?: string;

  /**
   * Image height in pixels.
   */
  height?: string;

  /**
   * How to fit the image.
   * Options: 'contain', 'cover', 'fill', 'none', 'scaleDown'
   * Default: 'cover'
   */
  fit?: string;
}

/**
 * Events emitted by <flutter-shadcn-image>
 */
interface FlutterShadcnImageEvents {
  /** Fired when image loads successfully. */
  load: Event;

  /** Fired when image fails to load. */
  error: Event;
}
