import React, { ReactNode } from 'react';
import { createWebFComponent } from './utils/createWebFComponent';

export interface WebFTouchAreaProps {
  /**
   * Children elements to render inside the touch area
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

  /**
   * Called when a touch starts
   */
  onTouchStart?: (event: TouchEvent) => void;

  /**
   * Called when a touch ends
   */
  onTouchEnd?: (event: TouchEvent) => void;

  /**
   * Called when a touch is cancelled
   */
  onTouchCancel?: (event: TouchEvent) => void;

  /**
   * Called when a touch moves
   */
  onTouchMove?: (event: TouchEvent) => void;
}

/**
 * WebFTouchArea - A React component that provides enhanced touch handling
 * 
 * This component wraps content and provides standardized touch event handling
 * across different platforms.
 * 
 * @example
 * ```tsx
 * <WebFTouchArea
 *   onTouchStart={(e) => console.log('Touch started', e)}
 *   onTouchEnd={(e) => console.log('Touch ended', e)}
 * >
 *   <div>Touch me!</div>
 * </WebFTouchArea>
 * ```
 */
export const WebFTouchArea = createWebFComponent<HTMLElement, WebFTouchAreaProps>({
  tagName: 'webf-toucharea',
  displayName: 'WebFTouchArea',
  
  events: [
    {
      propName: 'onTouchStart',
      eventName: 'touchstart',
      handler: (callback) => (event) => {
        callback((event as TouchEvent));
      },
    },
    {
      propName: 'onTouchEnd',
      eventName: 'touchend',
      handler: (callback) => (event) => {
        callback((event as TouchEvent));
      },
    },
    {
      propName: 'onTouchCancel',
      eventName: 'touchcancel',
      handler: (callback) => (event) => {
        callback((event as TouchEvent));
      },
    },
    {
      propName: 'onTouchMove',
      eventName: 'touchmove',
      handler: (callback) => (event) => {
        callback((event as TouchEvent));
      },
    },
  ],
});