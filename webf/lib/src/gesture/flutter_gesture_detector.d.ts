/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * A custom Flutter gesture detector element that captures and handles various touch gestures
 *
 * This element provides a comprehensive gesture detection system that can handle
 * tap, double-tap, long press, pan, and scale (pinch/zoom) gestures. It renders
 * a visual container with gesture feedback and dispatches detailed gesture events.
 *
 * The element supports these JavaScript events:
 * - 'tap': Single tap gesture
 * - 'doubletap': Double tap gesture
 * - 'longpress': Long press start
 * - 'longpressend': Long press end
 * - 'panstart': Pan gesture start
 * - 'panupdate': Pan gesture update (during dragging)
 * - 'panend': Pan gesture end
 * - 'scalestart': Scale gesture start (pinch/zoom)
 * - 'scaleupdate': Scale gesture update (during scaling)
 * - 'scaleend': Scale gesture end
 */
interface FlutterGestureDetectorProperties {
  // This element currently doesn't have configurable properties
  // All gesture detection is automatic
}

interface FlutterGestureDetectorMethods {
  // This element currently doesn't expose any public methods
  // All functionality is event-driven
}

interface FlutterGestureDetectorEventDetail {
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}

interface FlutterGestureDetectorLongPressDetail {
  /** Global X coordinate where long press starts */
  globalX: number;
  /** Global Y coordinate where long press starts */
  globalY: number;
  /** Local X coordinate relative to element */
  localX: number;
  /** Local Y coordinate relative to element */
  localY: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}
interface FlutterGestureDetectorLongPressEndDetail extends FlutterGestureDetectorLongPressDetail {
  /** X velocity (px/s) at release */
  velocityX: number;
  /** Y velocity (px/s) at release */
  velocityY: number;
}

interface FlutterGestureDetectorPanStartDetail {
  /** Global X of gesture focal point */
  x: number;
  /** Global Y of gesture focal point */
  y: number;
  /** Local X of gesture focal point */
  localX: number;
  /** Local Y of gesture focal point */
  localY: number;
  /** Number of active pointers contributing to the gesture */
  pointerCount: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}
interface FlutterGestureDetectorPanUpdateDetail {
  /** Global X of gesture focal point */
  x: number;
  /** Global Y of gesture focal point */
  y: number;
  /** Local X of gesture focal point */
  localX: number;
  /** Local Y of gesture focal point */
  localY: number;
  /** Delta X since last update (global) */
  deltaX: number;
  /** Delta Y since last update (global) */
  deltaY: number;
  /** Delta X since last update (local) */
  localDeltaX: number;
  /** Delta Y since last update (local) */
  localDeltaY: number;
  /** Number of active pointers contributing to the gesture */
  pointerCount: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}

interface FlutterGestureDetectorPanEndDetail {
  /** X velocity (px/s) at release */
  velocityX: number;
  /** Y velocity (px/s) at release */
  velocityY: number;
  /** Accumulated X delta over the gesture (global) */
  totalDeltaX: number;
  /** Accumulated Y delta over the gesture (global) */
  totalDeltaY: number;
  /** Number of active pointers when gesture ended */
  pointerCount: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}

interface FlutterGestureDetectorScaleStartDetail {
  /** Global X of scale focal point */
  focalPointX: number;
  /** Global Y of scale focal point */
  focalPointY: number;
  /** Local X of scale focal point */
  localFocalPointX: number;
  /** Local Y of scale focal point */
  localFocalPointY: number;
  /** Number of active pointers contributing to the scale */
  pointerCount: number;
  /** Source pointer event timestamp in microseconds (if available) */
  sourceTimeStampMicros?: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}

interface FlutterGestureDetectorScaleUpdateDetail {
  /** Scale factor since start (>= 0) */
  scale: number;
  /** Horizontal axis scale factor (>= 0) */
  horizontalScale: number;
  /** Vertical axis scale factor (>= 0) */
  verticalScale: number;
  /** Rotation in radians since start */
  rotation: number;
  /** Global X of scale focal point */
  focalPointX: number;
  /** Global Y of scale focal point */
  focalPointY: number;
  /** Local X of scale focal point */
  localFocalPointX: number;
  /** Local Y of scale focal point */
  localFocalPointY: number;
  /** Global X delta of focal point since last update */
  focalPointDeltaX: number;
  /** Global Y delta of focal point since last update */
  focalPointDeltaY: number;
  /** Current number of active pointers */
  pointerCount: number;
  /** Source pointer event timestamp in microseconds (if available) */
  sourceTimeStampMicros?: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}

interface FlutterGestureDetectorScaleEndDetail {
  /** X velocity (px/s) of last pointer */
  velocityX: number;
  /** Y velocity (px/s) of last pointer */
  velocityY: number;
  /** Final scale velocity (factor per second) */
  scaleVelocity: number;
  /** Number of active pointers when gesture ended */
  pointerCount: number;
  /** Milliseconds since epoch when the event dispatches */
  timestamp: number;
}

interface FlutterGestureDetectorEvents {
  /** Fired when a single tap gesture is detected */
  tap: CustomEvent<FlutterGestureDetectorEventDetail>;

  /** Fired when a double tap gesture is detected */
  doubletap: CustomEvent<FlutterGestureDetectorEventDetail>;

  /** Fired when a long press gesture starts */
  longpress: CustomEvent<FlutterGestureDetectorLongPressDetail>;

  /** Fired when a long press gesture ends */
  longpressend: CustomEvent<FlutterGestureDetectorLongPressEndDetail>;

  /** Fired when a pan gesture starts */
  panstart: CustomEvent<FlutterGestureDetectorPanStartDetail>;

  /** Fired continuously during a pan gesture */
  panupdate: CustomEvent<FlutterGestureDetectorPanUpdateDetail>;

  /** Fired when a pan gesture ends */
  panend: CustomEvent<FlutterGestureDetectorPanEndDetail>;

  /** Fired when a scale gesture starts */
  scalestart: CustomEvent<FlutterGestureDetectorScaleStartDetail>;

  /** Fired continuously during a scale gesture */
  scaleupdate: CustomEvent<FlutterGestureDetectorScaleUpdateDetail>;

  /** Fired when a scale gesture ends */
  scaleend: CustomEvent<FlutterGestureDetectorScaleEndDetail>;
}
