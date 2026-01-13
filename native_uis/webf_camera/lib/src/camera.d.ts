/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Camera facing direction
 */
type CameraFacing = 'front' | 'back' | 'external';

/**
 * Resolution preset for camera capture
 */
type ResolutionPreset = 'low' | 'medium' | 'high' | 'veryHigh' | 'ultraHigh' | 'max';

/**
 * Flash mode for photo/video capture
 */
type FlashMode = 'off' | 'auto' | 'always' | 'torch';

/**
 * Focus mode
 */
type FocusMode = 'auto' | 'locked';

/**
 * Exposure mode
 */
type ExposureMode = 'auto' | 'locked';

/**
 * Camera information
 */
interface CameraInfo {
  name: string;
  lensDirection: CameraFacing;
  sensorOrientation: int;
}

/**
 * Camera ready event detail
 */
interface CameraReadyDetail {
  cameras: CameraInfo[];
  currentCamera: CameraInfo;
  minZoom: double;
  maxZoom: double;
  minExposureOffset: double;
  maxExposureOffset: double;
}

/**
 * Camera error event detail
 */
interface CameraErrorDetail {
  error: string;
  code?: string;
}

/**
 * Photo capture result
 */
interface CameraCaptureResult {
  path: string;
  width: int;
  height: int;
  size: int;
}

/**
 * Video recording result
 */
interface CameraVideoResult {
  path: string;
  duration: double;
}

/**
 * Camera switched event detail
 */
interface CameraSwitchedDetail {
  facing: CameraFacing;
  camera: CameraInfo;
}

/**
 * Properties for <flutter-camera>
 * Native camera component wrapping Flutter's camera package.
 */
interface FlutterCameraProperties {
  /**
   * Camera facing direction.
   * @default 'back'
   */
  facing?: string;

  /**
   * Resolution preset.
   * @default 'high'
   */
  resolution?: string;

  /**
   * Flash mode.
   * @default 'auto'
   */
  'flash-mode'?: string;

  /**
   * Enable audio recording for video.
   * @default true
   */
  'enable-audio'?: boolean;

  /**
   * Auto-initialize camera on mount.
   * @default true
   */
  'auto-init'?: boolean;

  /**
   * Current zoom level.
   */
  zoom?: double;

  /**
   * Current exposure offset.
   */
  'exposure-offset'?: double;

  /**
   * Focus mode.
   * @default 'auto'
   */
  'focus-mode'?: string;

  /**
   * Exposure mode.
   * @default 'auto'
   */
  'exposure-mode'?: string;
}

interface FlutterCameraMethods {
  /** Initialize the camera. */
  initialize(): Promise<void>;

  /** Dispose camera resources. */
  dispose(): Promise<void>;

  /** Take a photo. Returns capture result with path, dimensions, and size. */
  takePicture(): Promise<CameraCaptureResult>;

  /** Start video recording. */
  startVideoRecording(): Promise<void>;

  /** Stop video recording. Returns video result with path and duration. */
  stopVideoRecording(): Promise<CameraVideoResult>;

  /** Pause video recording (iOS only). */
  pauseVideoRecording(): Promise<void>;

  /** Resume video recording (iOS only). */
  resumeVideoRecording(): Promise<void>;

  /** Switch between front and back cameras. */
  switchCamera(): Promise<void>;

  /** Set flash mode. */
  setFlashMode(mode: string): Promise<void>;

  /** Set zoom level (1.0 to maxZoom). */
  setZoomLevel(zoom: double): Promise<void>;

  /** Set exposure offset. */
  setExposureOffset(offset: double): Promise<double>;

  /** Set focus point (normalized 0-1 coordinates). */
  setFocusPoint(x: double, y: double): Promise<void>;

  /** Set exposure point (normalized 0-1 coordinates). */
  setExposurePoint(x: double, y: double): Promise<void>;

  /** Lock capture orientation. */
  lockCaptureOrientation(orientation?: string): Promise<void>;

  /** Unlock capture orientation. */
  unlockCaptureOrientation(): Promise<void>;

  /** Get available cameras. */
  getAvailableCameras(): Promise<CameraInfo[]>;

  /** Get minimum zoom level. */
  getMinZoomLevel(): double;

  /** Get maximum zoom level. */
  getMaxZoomLevel(): double;

  /** Get minimum exposure offset. */
  getMinExposureOffset(): double;

  /** Get maximum exposure offset. */
  getMaxExposureOffset(): double;
}

interface FlutterCameraEvents {
  /** Camera initialized successfully. */
  cameraready: CustomEvent<CameraReadyDetail>;

  /** Camera initialization failed. */
  camerafailed: CustomEvent<CameraErrorDetail>;

  /** Photo captured successfully. */
  photocaptured: CustomEvent<CameraCaptureResult>;

  /** Photo capture failed. */
  capturefailed: CustomEvent<CameraErrorDetail>;

  /** Video recording started. */
  recordingstarted: CustomEvent<void>;

  /** Video recording stopped. */
  recordingstopped: CustomEvent<CameraVideoResult>;

  /** Video recording failed. */
  recordingfailed: CustomEvent<CameraErrorDetail>;

  /** Camera switched. */
  cameraswitched: CustomEvent<CameraSwitchedDetail>;

  /** Zoom level changed. */
  zoomchanged: CustomEvent<{ zoom: double }>;

  /** Focus point set. */
  focusset: CustomEvent<{ x: double; y: double }>;

  /** Camera disposed. */
  cameradisposed: CustomEvent<void>;
}
