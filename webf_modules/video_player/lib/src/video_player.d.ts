interface FlutterVideoPlayerProperties {
  src?: string;
  autoplay?: boolean;  // HTML5 boolean attribute
  muted?: boolean;     // HTML5 boolean attribute
  loop?: boolean;      // HTML5 boolean attribute
  volume?: number;     // HTML5 standard: 0.0-1.0 range, read/write
  playbackRate?: number;  // HTML5 standard: camelCase, read/write
  currentTime?: number;   // HTML5 standard: read/write for seeking
  readonly duration?: number;
  readonly paused?: boolean;
  readonly ended?: boolean;
}

interface FlutterVideoPlayerMethods {
  play(): void;   // HTML5 standard method
  pause(): void;  // HTML5 standard method
  load(): void;   // HTML5 standard method - reload video
}

interface FlutterVideoPlayerEvents {
  play: CustomEvent;
  pause: CustomEvent;
  ended: CustomEvent;
  timeupdate: CustomEvent<{
    currentTime: number;
    duration: number;
  }>;
  loadedmetadata: CustomEvent<{
    duration: number;
    videoWidth: number;
    videoHeight: number;
  }>;
  error: CustomEvent<string>;
}

interface FlutterVideoProgressProperties {
  // No specific properties
}

interface FlutterVideoProgressMethods {
  // No specific methods
}

interface FlutterVideoProgressEvents {
  // No specific events
}