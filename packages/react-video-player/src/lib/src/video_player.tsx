import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterVideoPlayerMethods {
  play(): void;
  pause(): void;
  load(): void;
}
interface FlutterVideoProgressMethods {
}
export interface FlutterVideoPlayerProps {
  /**
   * src property
   * @default undefined
   */
  src?: string;
  /**
   * autoplay property
   * @default undefined
   */
  autoplay?: boolean;
  /**
   * muted property
   * @default undefined
   */
  muted?: boolean;
  /**
   * loop property
   * @default undefined
   */
  loop?: boolean;
  /**
   * controls property
   * @default undefined
   */
  controls?: boolean;
  /**
   * volume property
   * @default undefined
   */
  volume?: number;
  /**
   * playbackRate property
   * @default undefined
   */
  playbackRate?: number;
  /**
   * currentTime property
   * @default undefined
   */
  currentTime?: number;
  /**
   * duration property
   * @default undefined
   */
  duration?: number;
  /**
   * paused property
   * @default undefined
   */
  paused?: boolean;
  /**
   * ended property
   * @default undefined
   */
  ended?: boolean;
  /**
   * play event handler
   */
  onPlay?: (event: CustomEvent) => void;
  /**
   * pause event handler
   */
  onPause?: (event: CustomEvent) => void;
  /**
   * ended event handler
   */
  onEnded?: (event: CustomEvent) => void;
  /**
   * timeupdate event handler
   */
  onTimeupdate?: (event: CustomEvent) => void;
  /**
   * loadedmetadata event handler
   */
  onLoadedmetadata?: (event: CustomEvent) => void;
  /**
   * error event handler
   */
  onError?: (event: CustomEvent) => void;
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
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<FlutterVideoPlayerElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterVideoPlayerElement extends WebFElementWithMethods<{
  play(): void;
  pause(): void;
  load(): void;
}> {}
/**
 * FlutterVideoPlayer - WebF FlutterVideoPlayer component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterVideoPlayerElement>(null);
 * 
 * <FlutterVideoPlayer
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterVideoPlayer>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterVideoPlayer = createWebFComponent<FlutterVideoPlayerElement, FlutterVideoPlayerProps>({
  tagName: 'flutter-video-player',
  displayName: 'FlutterVideoPlayer',
  // Map props to attributes
  attributeProps: [
    'src',
    'autoplay',
    'muted',
    'loop',
    'controls',
    'volume',
    'playbackRate',
    'currentTime',
    'duration',
    'paused',
    'ended',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    playbackRate: 'playback-rate',
    currentTime: 'current-time',
  },
  // Event handlers
  events: [
    {
      propName: 'onPlay',
      eventName: 'play',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onPause',
      eventName: 'pause',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onEnded',
      eventName: 'ended',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onTimeupdate',
      eventName: 'timeupdate',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onLoadedmetadata',
      eventName: 'loadedmetadata',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onError',
      eventName: 'error',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterVideoProgressProps {
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
export interface FlutterVideoProgressElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterVideoProgress - WebF FlutterVideoProgress component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterVideoProgress
 *   // Add props here
 * >
 *   Content
 * </FlutterVideoProgress>
 * ```
 */
export const FlutterVideoProgress = createWebFComponent<FlutterVideoProgressElement, FlutterVideoProgressProps>({
  tagName: 'flutter-video-progress',
  displayName: 'FlutterVideoProgress',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});