import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface FlutterGestureDetectorMethods {
}
interface FlutterGestureDetectorEventDetail {
  timestamp: number;
}
interface FlutterGestureDetectorPanStartDetail {
  x: number;
  y: number;
  timestamp: number;
}
interface FlutterGestureDetectorPanUpdateDetail {
  x: number;
  y: number;
  deltaX: number;
  deltaY: number;
  timestamp: number;
}
interface FlutterGestureDetectorPanEndDetail {
  deltaX: number;
  deltaY: number;
  timestamp: number;
}
interface FlutterGestureDetectorScaleStartDetail {
  scale: number;
  timestamp: number;
}
interface FlutterGestureDetectorScaleUpdateDetail {
  scale: number;
  rotation: number;
  focalPointX: number;
  focalPointY: number;
  timestamp: number;
}
interface FlutterGestureDetectorScaleEndDetail {
  scale: number;
  rotation: number;
  timestamp: number;
}
export interface FlutterGestureDetectorProps {
  /**
   * Fired when a single tap gesture is detected
   */
  onTap?: (event: CustomEvent<FlutterGestureDetectorEventDetail>) => void;
  /**
   * Fired when a double tap gesture is detected
   */
  onDoubletap?: (event: CustomEvent<FlutterGestureDetectorEventDetail>) => void;
  /**
   * Fired when a long press gesture starts
   */
  onLongpress?: (event: CustomEvent<FlutterGestureDetectorEventDetail>) => void;
  /**
   * Fired when a long press gesture ends
   */
  onLongpressend?: (event: CustomEvent<FlutterGestureDetectorEventDetail>) => void;
  /**
   * Fired when a pan gesture starts
   */
  onPanstart?: (event: CustomEvent<FlutterGestureDetectorPanStartDetail>) => void;
  /**
   * Fired continuously during a pan gesture
   */
  onPanupdate?: (event: CustomEvent<FlutterGestureDetectorPanUpdateDetail>) => void;
  /**
   * Fired when a pan gesture ends
   */
  onPanend?: (event: CustomEvent<FlutterGestureDetectorPanEndDetail>) => void;
  /**
   * Fired when a scale gesture starts
   */
  onScalestart?: (event: CustomEvent<FlutterGestureDetectorScaleStartDetail>) => void;
  /**
   * Fired continuously during a scale gesture
   */
  onScaleupdate?: (event: CustomEvent<FlutterGestureDetectorScaleUpdateDetail>) => void;
  /**
   * Fired when a scale gesture ends
   */
  onScaleend?: (event: CustomEvent<FlutterGestureDetectorScaleEndDetail>) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterGestureDetectorElement extends WebFElementWithMethods<{
}> {}
/**
 * A custom Flutter gesture detector element that captures and handles various touch gestures
This element provides a comprehensive gesture detection system that can handle
tap, double-tap, long press, pan, and scale (pinch/zoom) gestures. It renders
a visual container with gesture feedback and dispatches detailed gesture events.
The element supports these JavaScript events:
- 'tap': Single tap gesture
- 'doubletap': Double tap gesture  
- 'longpress': Long press start
- 'longpressend': Long press end
- 'panstart': Pan gesture start
- 'panupdate': Pan gesture update (during dragging)
- 'panend': Pan gesture end
- 'scalestart': Scale gesture start (pinch/zoom)
- 'scaleupdate': Scale gesture update (during scaling)
- 'scaleend': Scale gesture end
 * 
 * @example
 * ```tsx
 * 
 * <FlutterGestureDetector
 *   // Add props here
 * >
 *   Content
 * </FlutterGestureDetector>
 * ```
 */
export const FlutterGestureDetector = createWebFComponent<FlutterGestureDetectorElement, FlutterGestureDetectorProps>({
  tagName: 'flutter-gesture-detector',
  displayName: 'FlutterGestureDetector',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onTap',
      eventName: 'tap',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorEventDetail>));
      },
    },
    {
      propName: 'onDoubletap',
      eventName: 'doubletap',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorEventDetail>));
      },
    },
    {
      propName: 'onLongpress',
      eventName: 'longpress',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorEventDetail>));
      },
    },
    {
      propName: 'onLongpressend',
      eventName: 'longpressend',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorEventDetail>));
      },
    },
    {
      propName: 'onPanstart',
      eventName: 'panstart',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorPanStartDetail>));
      },
    },
    {
      propName: 'onPanupdate',
      eventName: 'panupdate',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorPanUpdateDetail>));
      },
    },
    {
      propName: 'onPanend',
      eventName: 'panend',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorPanEndDetail>));
      },
    },
    {
      propName: 'onScalestart',
      eventName: 'scalestart',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorScaleStartDetail>));
      },
    },
    {
      propName: 'onScaleupdate',
      eventName: 'scaleupdate',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorScaleUpdateDetail>));
      },
    },
    {
      propName: 'onScaleend',
      eventName: 'scaleend',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<FlutterGestureDetectorScaleEndDetail>));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});