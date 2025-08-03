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

interface FlutterGestureDetectorEvents {
  /** Fired when a single tap gesture is detected */
  tap: CustomEvent<FlutterGestureDetectorEventDetail>;

  /** Fired when a double tap gesture is detected */
  doubletap: CustomEvent<FlutterGestureDetectorEventDetail>;

  /** Fired when a long press gesture starts */
  longpress: CustomEvent<FlutterGestureDetectorEventDetail>;

  /** Fired when a long press gesture ends */
  longpressend: CustomEvent<FlutterGestureDetectorEventDetail>;

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