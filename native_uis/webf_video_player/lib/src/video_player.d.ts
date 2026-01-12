/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 *
 * HTML5-compatible video player element for WebF.
 * Backed by Flutter's `video_player` package.
 *
 * Element: <webf-video-player>
 */

/**
 * Video error information matching HTML5 MediaError.
 */
interface VideoError {
  /**
   * Error code:
   * - 1: MEDIA_ERR_ABORTED
   * - 2: MEDIA_ERR_NETWORK
   * - 3: MEDIA_ERR_DECODE
   * - 4: MEDIA_ERR_SRC_NOT_SUPPORTED
   */
  code: int;
  /** Human-readable error message. */
  message: string;
}

/**
 * Time range information for buffered/seekable regions.
 */
interface TimeRangeInfo {
  /** Number of ranges. */
  length: int;
  /** Array of range objects with start and end times in seconds. */
  ranges: { start: double; end: double }[];
}

/**
 * Properties for <webf-video-player>.
 * Designed for HTML5 video element compatibility.
 */
interface WebFVideoPlayerProperties {
  /**
   * Video source URL.
   * Supports http://, https://, file://, and asset:// protocols.
   * For Flutter assets, use asset:// prefix (e.g., "asset://videos/intro.mp4").
   */
  src?: string;

  /**
   * Poster image URL displayed before video plays.
   * Shown when video is not yet loaded or before first play.
   */
  poster?: string;

  /**
   * Whether to start playing automatically when loaded.
   * Note: Mobile platforms may require user interaction first.
   * Default: false
   */
  autoplay?: boolean;

  /**
   * Whether to show native playback controls.
   * When true, displays play/pause, seek bar, volume, and time display.
   * Default: true
   */
  controls?: boolean;

  /**
   * Whether the video should loop continuously.
   * Default: false
   */
  loop?: boolean;

  /**
   * Whether the audio is muted.
   * Default: false
   */
  muted?: boolean;

  /**
   * Audio volume level (0.0 to 1.0).
   * Default: 1.0
   */
  volume?: double;

  /**
   * Playback speed rate.
   * 1.0 = normal speed, 0.5 = half speed, 2.0 = double speed.
   * Supported values: 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
   * Default: 1.0
   */
  playbackRate?: double;

  /**
   * Current playback position in seconds.
   * Can be set to seek to a specific time.
   */
  currentTime?: double;

  /**
   * How the video should be resized to fit its container.
   * - 'contain': Fit within container, preserving aspect ratio (letterbox)
   * - 'cover': Fill container, preserving aspect ratio (may crop)
   * - 'fill': Stretch to fill container (may distort)
   * - 'none': Natural size, no resizing
   * Default: 'contain'
   */
  objectFit?: string;

  /**
   * Preload behavior hint.
   * - 'none': Don't preload anything
   * - 'metadata': Only load metadata (duration, dimensions)
   * - 'auto': Preload the entire video if possible
   * Default: 'metadata'
   */
  preload?: string;

  /**
   * Whether to play video inline (iOS specific).
   * When true, plays inline instead of fullscreen on iOS.
   * Default: true
   */
  playsInline?: boolean;

  // ============ Read-only properties ============

  /**
   * Total duration of the video in seconds.
   * Returns NaN if duration is unknown.
   * Read-only.
   */
  readonly duration?: double;

  /**
   * Whether the video is currently paused.
   * Read-only.
   */
  readonly paused?: boolean;

  /**
   * Whether playback has ended.
   * Read-only.
   */
  readonly ended?: boolean;

  /**
   * Whether the video is currently seeking.
   * Read-only.
   */
  readonly seeking?: boolean;

  /**
   * Current ready state (0-4).
   * 0: HAVE_NOTHING, 1: HAVE_METADATA, 2: HAVE_CURRENT_DATA,
   * 3: HAVE_FUTURE_DATA, 4: HAVE_ENOUGH_DATA
   * Read-only.
   */
  readonly readyState?: int;

  /**
   * Current network state (0-3).
   * 0: NETWORK_EMPTY, 1: NETWORK_IDLE, 2: NETWORK_LOADING, 3: NETWORK_NO_SOURCE
   * Read-only.
   */
  readonly networkState?: int;

  /**
   * Natural width of the video in pixels.
   * Read-only.
   */
  readonly videoWidth?: int;

  /**
   * Natural height of the video in pixels.
   * Read-only.
   */
  readonly videoHeight?: int;

  /**
   * Whether the video is currently buffering.
   * Read-only.
   */
  readonly buffering?: boolean;
}

/**
 * Methods for <webf-video-player>.
 */
interface WebFVideoPlayerMethods {
  /**
   * Start or resume video playback.
   */
  play(): void;

  /**
   * Pause video playback.
   */
  pause(): void;

  /**
   * Load or reload the video source.
   * Useful after changing the src attribute.
   */
  load(): void;

  /**
   * Check if the video can play a given MIME type.
   * Returns '', 'maybe', or 'probably'.
   */
  canPlayType(type: string): string;
}

/**
 * Events for <webf-video-player>.
 * Compatible with HTML5 HTMLMediaElement events.
 */
interface WebFVideoPlayerEvents {
  // ============ Loading Events ============

  /**
   * Fired when the browser starts loading the video.
   */
  loadstart: Event;

  /**
   * Fired when an error occurred during loading.
   * detail = { code: number, message: string }
   */
  error: CustomEvent<VideoError>;

  /**
   * Fired when metadata (duration, dimensions) is loaded.
   * detail = { duration: number, videoWidth: number, videoHeight: number }
   */
  loadedmetadata: CustomEvent<{ duration: double; videoWidth: int; videoHeight: int }>;

  /**
   * Fired when the first frame of media is loaded.
   */
  loadeddata: Event;

  /**
   * Fired when the browser can play, but may need to buffer.
   */
  canplay: Event;

  /**
   * Fired when the browser can play through without buffering.
   */
  canplaythrough: Event;

  // ============ Playback Events ============

  /**
   * Fired when playback is ready to start after pause/stall.
   */
  playing: Event;

  /**
   * Fired when playback has stopped due to lack of data.
   */
  waiting: Event;

  /**
   * Fired when seeking operation starts.
   */
  seeking: Event;

  /**
   * Fired when seeking operation completes.
   */
  seeked: Event;

  /**
   * Fired when playback has ended.
   */
  ended: Event;

  /**
   * Fired when the duration attribute changes.
   * detail = { duration: number }
   */
  durationchange: CustomEvent<{ duration: double }>;

  /**
   * Fired periodically during playback.
   * detail = { currentTime: number, duration: number }
   */
  timeupdate: CustomEvent<{ currentTime: double; duration: double }>;

  /**
   * Fired when playback starts or play() is called.
   */
  play: Event;

  /**
   * Fired when playback is paused.
   */
  pause: Event;

  /**
   * Fired when playbackRate changes.
   * detail = { playbackRate: number }
   */
  ratechange: CustomEvent<{ playbackRate: double }>;

  /**
   * Fired when volume or muted state changes.
   * detail = { volume: number, muted: boolean }
   */
  volumechange: CustomEvent<{ volume: double; muted: boolean }>;

  // ============ Buffering Events ============

  /**
   * Fired when buffered data changes (download progress).
   */
  progress: Event;
}
