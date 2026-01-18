/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-avatar>
 *
 * An avatar component for displaying user images or initials.
 *
 * @example
 * ```html
 * <flutter-shadcn-avatar src="https://example.com/avatar.jpg" alt="John Doe" />
 * <flutter-shadcn-avatar fallback="JD" />
 * ```
 */
interface FlutterShadcnAvatarProperties {
  /**
   * URL of the avatar image.
   */
  src?: string;

  /**
   * Alt text for the image.
   */
  alt?: string;

  /**
   * Fallback text/initials when image fails to load or is not provided.
   */
  fallback?: string;

  /**
   * Size of the avatar in pixels.
   * Default: 40
   */
  size?: string;
}

interface FlutterShadcnAvatarEvents {}
