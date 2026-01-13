import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCamera, FlutterCameraElement } from '@openwebf/react-camera';
import styles from './NativeInteractionPage.module.css';

// Type definitions for camera events
interface CameraReadyDetail {
  cameras: { name: string; lensDirection: string; sensorOrientation: number }[];
  currentCamera: { name: string; lensDirection: string; sensorOrientation: number };
  minZoom: number;
  maxZoom: number;
  minExposureOffset: number;
  maxExposureOffset: number;
}

interface CameraCaptureResult {
  path: string;
  width: number;
  height: number;
  size: number;
}

interface CameraVideoResult {
  path: string;
  duration: number;
}

interface CameraErrorDetail {
  error: string;
  code?: string;
}

interface CameraSwitchedDetail {
  facing: string;
  camera: { name: string; lensDirection: string; sensorOrientation: number };
}

export const WebFCameraPage: React.FC = () => {
  const cameraRef = useRef<FlutterCameraElement>(null);
  const [isCameraReady, setIsCameraReady] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [flashMode, setFlashMode] = useState('auto');
  const [zoomLevel, setZoomLevel] = useState(1.0);
  const [minZoom, setMinZoom] = useState(1.0);
  const [maxZoom, setMaxZoom] = useState(1.0);
  const [capturedImage, setCapturedImage] = useState<string>('');
  const [recordedVideo, setRecordedVideo] = useState<string>('');
  const [statusMessage, setStatusMessage] = useState<string>('');
  const [errorMessage, setErrorMessage] = useState<string>('');
  const [cameraInfo, setCameraInfo] = useState<CameraReadyDetail | null>(null);
  const [isProcessing, setIsProcessing] = useState<{[key: string]: boolean}>({});

  const handleCameraReady = (e: CustomEvent<CameraReadyDetail>) => {
    setIsCameraReady(true);
    setCameraInfo(e.detail);
    setMinZoom(e.detail.minZoom);
    setMaxZoom(e.detail.maxZoom);
    setStatusMessage('Camera ready!');
    setErrorMessage('');
  };

  const handleCameraFailed = (e: CustomEvent<CameraErrorDetail>) => {
    setIsCameraReady(false);
    setErrorMessage(`Camera failed: ${e.detail.error} (${e.detail.code || 'unknown'})`);
  };

  const handlePhotoCaptured = (e: CustomEvent<CameraCaptureResult>) => {
    setCapturedImage(`file://${e.detail.path}`);
    setStatusMessage(`Photo captured: ${e.detail.width}x${e.detail.height}`);
    setIsProcessing(prev => ({ ...prev, capture: false }));
  };

  const handleCaptureFailed = (e: CustomEvent<CameraErrorDetail>) => {
    setErrorMessage(`Capture failed: ${e.detail.error}`);
    setIsProcessing(prev => ({ ...prev, capture: false }));
  };

  const handleRecordingStarted = () => {
    setIsRecording(true);
    setStatusMessage('Recording started...');
    setIsProcessing(prev => ({ ...prev, record: false }));
  };

  const handleRecordingStopped = (e: CustomEvent<CameraVideoResult>) => {
    setIsRecording(false);
    setRecordedVideo(`file://${e.detail.path}`);
    setStatusMessage(`Recording saved`);
    setIsProcessing(prev => ({ ...prev, record: false }));
  };

  const handleRecordingFailed = (e: CustomEvent<CameraErrorDetail>) => {
    setIsRecording(false);
    setErrorMessage(`Recording failed: ${e.detail.error}`);
    setIsProcessing(prev => ({ ...prev, record: false }));
  };

  const handleCameraSwitched = (e: CustomEvent<CameraSwitchedDetail>) => {
    setStatusMessage(`Switched to ${e.detail.facing} camera`);
    setIsProcessing(prev => ({ ...prev, switch: false }));
  };

  const handleZoomChanged = (e: CustomEvent<{ zoom: number }>) => {
    setZoomLevel(e.detail.zoom);
  };

  const takePicture = async () => {
    if (!cameraRef.current || !isCameraReady) return;
    setIsProcessing(prev => ({ ...prev, capture: true }));
    try {
      cameraRef.current.takePicture();
    } catch (error) {
      setErrorMessage(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      setIsProcessing(prev => ({ ...prev, capture: false }));
    }
  };

  const toggleRecording = async () => {
    if (!cameraRef.current || !isCameraReady) return;
    setIsProcessing(prev => ({ ...prev, record: true }));
    try {
      if (isRecording) {
        cameraRef.current.stopVideoRecording();
      } else {
        cameraRef.current.startVideoRecording();
      }
    } catch (error) {
      setErrorMessage(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      setIsProcessing(prev => ({ ...prev, record: false }));
    }
  };

  const switchCamera = async () => {
    if (!cameraRef.current || !isCameraReady) return;
    setIsProcessing(prev => ({ ...prev, switch: true }));
    try {
      cameraRef.current.switchCamera();
    } catch (error) {
      setErrorMessage(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      setIsProcessing(prev => ({ ...prev, switch: false }));
    }
  };

  const cycleFlashMode = async () => {
    if (!cameraRef.current || !isCameraReady) return;
    const modes = ['auto', 'off', 'always', 'torch'];
    const currentIndex = modes.indexOf(flashMode);
    const nextMode = modes[(currentIndex + 1) % modes.length];
    try {
      cameraRef.current.setFlashMode(nextMode);
      setFlashMode(nextMode);
      setStatusMessage(`Flash: ${nextMode}`);
    } catch (error) {
      setErrorMessage(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  };

  const handleZoomChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!cameraRef.current || !isCameraReady) return;
    const newZoom = parseFloat(e.target.value);
    try {
      cameraRef.current.setZoomLevel(newZoom);
    } catch (error) {
      setErrorMessage(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  };

  const getFlashIcon = () => {
    switch (flashMode) {
      case 'off': return '⚫';
      case 'auto': return '⚡';
      case 'always': return '💡';
      case 'torch': return '🔦';
      default: return '⚡';
    }
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>WebF Camera</div>
          <div className={styles.componentBlock}>

            {/* Camera Preview */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Camera Preview</div>
              <div className={styles.itemDesc}>
                Native camera integration with photo capture, video recording, flash control, and zoom
              </div>
              <div className={styles.actionContainer}>
                {/* Camera Element */}
                <div style={{
                  width: '100%',
                  height: '300px',
                  borderRadius: '12px',
                  overflow: 'hidden',
                  marginBottom: '16px',
                  backgroundColor: '#000',
                  position: 'relative'
                }}>
                  <FlutterCamera
                    ref={cameraRef}
                    facing="back"
                    resolution="high"
                    flashMode={flashMode}
                    autoInit={true}
                    enableAudio={true}
                    style={{ width: '100%', height: '100%' }}
                    onCameraready={handleCameraReady}
                    onCamerafailed={handleCameraFailed}
                    onPhotocaptured={handlePhotoCaptured}
                    onCapturefailed={handleCaptureFailed}
                    onRecordingstarted={handleRecordingStarted}
                    onRecordingstopped={handleRecordingStopped}
                    onRecordingfailed={handleRecordingFailed}
                    onCameraswitched={handleCameraSwitched}
                    onZoomchanged={handleZoomChanged}
                  />
                  {!isCameraReady && (
                    <div style={{
                      position: 'absolute',
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      backgroundColor: 'rgba(0,0,0,0.8)',
                      color: 'white',
                      flexDirection: 'column',
                      gap: '12px'
                    }}>
                      <div style={{ fontSize: '48px' }}>📷</div>
                      <div>Initializing camera...</div>
                    </div>
                  )}
                </div>

                {/* Camera Controls */}
                <div className={styles.buttonGroup}>
                  <button
                    className={`${styles.actionButton} ${isProcessing.capture ? styles.processing : ''}`}
                    onClick={takePicture}
                    disabled={!isCameraReady || isProcessing.capture}
                  >
                    {isProcessing.capture ? '📸 Capturing...' : '📸 Take Photo'}
                  </button>
                  <button
                    className={`${styles.actionButton} ${isRecording ? styles.processing : ''}`}
                    onClick={toggleRecording}
                    disabled={!isCameraReady || isProcessing.record}
                    style={isRecording ? { backgroundColor: '#dc3545' } : {}}
                  >
                    {isRecording ? '⏹️ Stop Recording' : '🎬 Record Video'}
                  </button>
                  <button
                    className={`${styles.actionButton} ${styles.secondaryButton}`}
                    onClick={switchCamera}
                    disabled={!isCameraReady || isProcessing.switch}
                  >
                    🔄 Switch
                  </button>
                  <button
                    className={`${styles.actionButton} ${styles.secondaryButton}`}
                    onClick={cycleFlashMode}
                    disabled={!isCameraReady}
                  >
                    {getFlashIcon()} Flash: {flashMode}
                  </button>
                </div>

                {/* Zoom Control */}
                {isCameraReady && maxZoom > minZoom && (
                  <div style={{ marginBottom: '16px' }}>
                    <div style={{ marginBottom: '8px', fontWeight: '500' }}>
                      Zoom: {zoomLevel.toFixed(1)}x
                    </div>
                    <input
                      type="range"
                      min={minZoom}
                      max={maxZoom}
                      step="0.1"
                      value={zoomLevel}
                      onChange={handleZoomChange}
                      style={{ width: '100%' }}
                    />
                  </div>
                )}

                {/* Status Messages */}
                {(statusMessage || errorMessage) && (
                  <div className={styles.resultContainer}>
                    {statusMessage && (
                      <>
                        <div className={styles.resultLabel}>Status:</div>
                        <div className={styles.resultText} style={{ color: '#28a745' }}>{statusMessage}</div>
                      </>
                    )}
                    {errorMessage && (
                      <>
                        <div className={styles.resultLabel}>Error:</div>
                        <div className={styles.resultText} style={{ color: '#dc3545' }}>{errorMessage}</div>
                      </>
                    )}
                  </div>
                )}

                {/* Camera Info */}
                {cameraInfo && (
                  <div className={styles.resultContainer} style={{ marginTop: '12px' }}>
                    <div className={styles.resultLabel}>Camera Info:</div>
                    <div className={styles.resultText}>
{`Current: ${cameraInfo.currentCamera.lensDirection}
Cameras: ${cameraInfo.cameras.length}
Zoom: ${cameraInfo.minZoom.toFixed(1)}x - ${cameraInfo.maxZoom.toFixed(1)}x
Exposure: ${cameraInfo.minExposureOffset.toFixed(1)} - ${cameraInfo.maxExposureOffset.toFixed(1)}`}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Captured Photo Preview */}
            {capturedImage && (
              <div className={styles.componentItem}>
                <div className={styles.itemLabel}>Captured Photo</div>
                <div className={styles.itemDesc}>Last photo taken with the camera</div>
                <div className={styles.imagePreview}>
                  <img
                    src={capturedImage}
                    alt="Captured"
                    className={styles.previewImage}
                  />
                </div>
              </div>
            )}

            {/* Recorded Video Info */}
            {recordedVideo && (
              <div className={styles.componentItem}>
                <div className={styles.itemLabel}>Recorded Video</div>
                <div className={styles.itemDesc}>Video saved to device</div>
                <div className={styles.resultContainer}>
                  <div className={styles.resultLabel}>File Path:</div>
                  <div className={styles.resultText}>{recordedVideo}</div>
                </div>
              </div>
            )}

            {/* Usage Guide */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Usage Guide</div>
              <div className={styles.itemDesc}>How to integrate the camera component in your WebF app</div>
              <div className={styles.guideContainer}>
                <div className={styles.codeBlock}>
                  <div className={styles.codeTitle}>1. Install the packages (Dart)</div>
                  <pre className={styles.codeContent}>{`import 'package:webf_camera/webf_camera.dart';

void main() {
  installWebFCamera();
  runApp(MyApp());
}`}</pre>
                </div>
                <div className={styles.codeBlock}>
                  <div className={styles.codeTitle}>2. Use in React</div>
                  <pre className={styles.codeContent}>{`import { FlutterCamera, FlutterCameraElement } from '@openwebf/react-camera';

const cameraRef = useRef<FlutterCameraElement>(null);

<FlutterCamera
  ref={cameraRef}
  facing="back"
  resolution="high"
  flashMode="auto"
  autoInit={true}
  enableAudio={true}
  onCameraready={(e) => console.log('Ready:', e.detail)}
  onPhotocaptured={(e) => console.log('Photo:', e.detail.path)}
/>`}</pre>
                </div>
                <div className={styles.codeBlock}>
                  <div className={styles.codeTitle}>3. Call methods via ref</div>
                  <pre className={styles.codeContent}>{`// Take a photo
cameraRef.current?.takePicture();

// Record video
cameraRef.current?.startVideoRecording();
cameraRef.current?.stopVideoRecording();

// Switch camera
cameraRef.current?.switchCamera();

// Control flash
cameraRef.current?.setFlashMode('torch');

// Zoom
cameraRef.current?.setZoomLevel(2.0);`}</pre>
                </div>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};
