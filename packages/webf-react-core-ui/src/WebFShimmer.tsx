import React, { ReactNode } from 'react';
import { createWebFComponent } from './utils/createWebFComponent';

export interface WebFShimmerProps {
  /**
   * Children elements to apply shimmer effect to
   */
  children?: ReactNode;

  /**
   * Additional CSS class names
   */
  className?: string;

  /**
   * Inline styles
   */
  style?: React.CSSProperties;
}

/**
 * WebFShimmer - A React component that wraps the WebF native Shimmer element
 * 
 * This component renders as a custom HTML element (`<flutter-shimmer>`) that is 
 * handled by the WebF framework and provides native Flutter shimmer effects.
 * 
 * @example
 * ```tsx
 * <WebFShimmer>
 *   <div>Content with shimmer effect</div>
 * </WebFShimmer>
 * ```
 */
export const WebFShimmer = createWebFComponent<HTMLElement, WebFShimmerProps>({
  tagName: 'flutter-shimmer',
  displayName: 'WebFShimmer',
});

export interface WebFShimmerAvatarProps {
  /**
   * Width of the avatar
   * @default 40
   */
  width?: number;

  /**
   * Height of the avatar
   * @default 40
   */
  height?: number;

  /**
   * Additional CSS class names
   */
  className?: string;

  /**
   * Inline styles
   */
  style?: React.CSSProperties;
}

/**
 * WebFShimmerAvatar - A React component that wraps the WebF native ShimmerAvatar element
 * 
 * @example
 * ```tsx
 * <WebFShimmerAvatar width={60} height={60} />
 * ```
 */
// For WebFShimmerAvatar, we need to handle width/height as part of style directly
const WebFShimmerAvatarBase = createWebFComponent<HTMLElement, WebFShimmerAvatarProps>({
  tagName: 'flutter-shimmer-avatar',
  displayName: 'WebFShimmerAvatar',
  defaultProps: {
    width: 40,
    height: 40,
  },
});

export const WebFShimmerAvatar: React.FC<WebFShimmerAvatarProps> = ({ width = 40, height = 40, className, style, ...props }) => {
  return <WebFShimmerAvatarBase 
    {...props}
    className={className}
    style={{
      width,
      height,
      ...style,
    }}
  />;
};

export interface WebFShimmerTextProps {
  /**
   * Height of the text shimmer
   * @default 16
   */
  height?: number;

  /**
   * Additional CSS class names
   */
  className?: string;

  /**
   * Inline styles
   */
  style?: React.CSSProperties;
}

/**
 * WebFShimmerText - A React component that wraps the WebF native ShimmerText element
 * 
 * @example
 * ```tsx
 * <WebFShimmerText height={20} />
 * ```
 */
// For WebFShimmerText, we need to handle height as part of style directly
const WebFShimmerTextBase = createWebFComponent<HTMLElement, WebFShimmerTextProps>({
  tagName: 'flutter-shimmer-text',
  displayName: 'WebFShimmerText',
  defaultProps: {
    height: 16,
  },
});

export const WebFShimmerText: React.FC<WebFShimmerTextProps> = ({ height = 16, className, style, ...props }) => {
  return <WebFShimmerTextBase 
    {...props}
    className={className}
    style={{
      height,
      ...style,
    }}
  />;
};

export interface WebFShimmerButtonProps {
  /**
   * Width of the button shimmer
   * @default 80
   */
  width?: number;

  /**
   * Height of the button shimmer
   * @default 32
   */
  height?: number;

  /**
   * Border radius
   * @default 4
   */
  radius?: number;

  /**
   * Additional CSS class names
   */
  className?: string;

  /**
   * Inline styles
   */
  style?: React.CSSProperties;
}

/**
 * WebFShimmerButton - A React component that wraps the WebF native ShimmerButton element
 * 
 * @example
 * ```tsx
 * <WebFShimmerButton width={120} height={40} radius={8} />
 * ```
 */
// For WebFShimmerButton, we need both attributes and styles
const WebFShimmerButtonBase = createWebFComponent<HTMLElement, WebFShimmerButtonProps>({
  tagName: 'flutter-shimmer-button',
  displayName: 'WebFShimmerButton',
  defaultProps: {
    width: 80,
    height: 32,
    radius: 4,
  },
  attributeProps: ['width', 'height', 'radius'],
});

export const WebFShimmerButton: React.FC<WebFShimmerButtonProps> = ({ width = 80, height = 32, radius = 4, className, style, ...props }) => {
  return <WebFShimmerButtonBase 
    {...props}
    width={width}
    height={height}
    radius={radius}
    className={className}
    style={{
      width,
      height,
      ...style,
    }}
  />;
};