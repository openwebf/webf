<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
// Type-only import for type augmentation - no runtime JS in Vue package
import type { FlutterCameraElement } from '@openwebf/vue-camera';

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

const cameraRef = ref<FlutterCameraElement | null>(null);
const isCameraReady = ref(false);
const isRecording = ref(false);
const flashMode = ref('auto');
const zoomLevel = ref(1.0);
const minZoom = ref(1.0);
const maxZoom = ref(1.0);
const capturedImage = ref('');
const recordedVideo = ref('');
const statusMessage = ref('');
const errorMessage = ref('');
const cameraInfo = ref<CameraReadyDetail | null>(null);
const isProcessing = reactive<Record<string, boolean>>({});

// Computed classes for buttons
const captureButtonClass = computed(() => {
  const base = 'text-white border-none py-3 px-6 rounded-lg text-sm font-medium cursor-pointer transition-all duration-200 mb-2';
  if (isProcessing.capture) {
    return `${base} bg-yellow-500 animate-pulse`;
  }
  return `${base} bg-blue-500 hover:bg-blue-700 hover:-translate-y-0.5 disabled:bg-gray-500 disabled:cursor-not-allowed disabled:transform-none`;
});

const recordButtonClass = computed(() => {
  const base = 'text-white border-none py-3 px-6 rounded-lg text-sm font-medium cursor-pointer transition-all duration-200 mb-2';
  if (isRecording.value) {
    return `${base} bg-red-600`;
  }
  return `${base} bg-blue-500 hover:bg-blue-700 hover:-translate-y-0.5 disabled:bg-gray-500 disabled:cursor-not-allowed disabled:transform-none`;
});

const secondaryButtonClass = 'text-white border-none py-3 px-6 rounded-lg text-sm font-medium cursor-pointer transition-all duration-200 mb-2 bg-gray-500 hover:bg-gray-600 hover:-translate-y-0.5 disabled:bg-gray-500 disabled:cursor-not-allowed disabled:transform-none';

function handleCameraReady(e: CustomEvent<CameraReadyDetail>) {
  isCameraReady.value = true;
  cameraInfo.value = e.detail;
  minZoom.value = e.detail.minZoom;
  maxZoom.value = e.detail.maxZoom;
  statusMessage.value = 'Camera ready!';
  errorMessage.value = '';
}

function handleCameraFailed(e: CustomEvent<CameraErrorDetail>) {
  isCameraReady.value = false;
  errorMessage.value = `Camera failed: ${e.detail.error} (${e.detail.code || 'unknown'})`;
}

function handlePhotoCaptured(e: CustomEvent<CameraCaptureResult>) {
  capturedImage.value = `file://${e.detail.path}`;
  statusMessage.value = `Photo captured: ${e.detail.width}x${e.detail.height}`;
  isProcessing.capture = false;
}

function handleCaptureFailed(e: CustomEvent<CameraErrorDetail>) {
  errorMessage.value = `Capture failed: ${e.detail.error}`;
  isProcessing.capture = false;
}

function handleRecordingStarted() {
  isRecording.value = true;
  statusMessage.value = 'Recording started...';
  isProcessing.record = false;
}

function handleRecordingStopped(e: CustomEvent<CameraVideoResult>) {
  isRecording.value = false;
  recordedVideo.value = `file://${e.detail.path}`;
  statusMessage.value = `Recording saved`;
  isProcessing.record = false;
}

function handleRecordingFailed(e: CustomEvent<CameraErrorDetail>) {
  isRecording.value = false;
  errorMessage.value = `Recording failed: ${e.detail.error}`;
  isProcessing.record = false;
}

function handleCameraSwitched(e: CustomEvent<CameraSwitchedDetail>) {
  statusMessage.value = `Switched to ${e.detail.facing} camera`;
  isProcessing.switch = false;
}

function handleZoomChanged(e: CustomEvent<{ zoom: number }>) {
  zoomLevel.value = e.detail.zoom;
}

function takePicture() {
  if (!cameraRef.value || !isCameraReady.value) return;
  isProcessing.capture = true;
  try {
    cameraRef.value.takePicture();
  } catch (error) {
    errorMessage.value = `Error: ${error instanceof Error ? error.message : 'Unknown error'}`;
    isProcessing.capture = false;
  }
}

function toggleRecording() {
  if (!cameraRef.value || !isCameraReady.value) return;
  isProcessing.record = true;
  try {
    if (isRecording.value) {
      cameraRef.value.stopVideoRecording();
    } else {
      cameraRef.value.startVideoRecording();
    }
  } catch (error) {
    errorMessage.value = `Error: ${error instanceof Error ? error.message : 'Unknown error'}`;
    isProcessing.record = false;
  }
}

function switchCamera() {
  if (!cameraRef.value || !isCameraReady.value) return;
  isProcessing.switch = true;
  try {
    cameraRef.value.switchCamera();
  } catch (error) {
    errorMessage.value = `Error: ${error instanceof Error ? error.message : 'Unknown error'}`;
    isProcessing.switch = false;
  }
}

function cycleFlashMode() {
  if (!cameraRef.value || !isCameraReady.value) return;
  const modes: string[] = ['auto', 'off', 'always', 'torch'];
  const currentIndex = modes.indexOf(flashMode.value);
  const nextMode = modes[(currentIndex + 1) % modes.length] as string;
  try {
    cameraRef.value.setFlashMode(nextMode);
    flashMode.value = nextMode;
    statusMessage.value = `Flash: ${nextMode}`;
  } catch (error) {
    errorMessage.value = `Error: ${error instanceof Error ? error.message : 'Unknown error'}`;
  }
}

function handleZoomChange(e: Event) {
  if (!cameraRef.value || !isCameraReady.value) return;
  const newZoom = parseFloat((e.target as HTMLInputElement).value);
  try {
    cameraRef.value.setZoomLevel(newZoom);
  } catch (error) {
    errorMessage.value = `Error: ${error instanceof Error ? error.message : 'Unknown error'}`;
  }
}

function getFlashIcon() {
  switch (flashMode.value) {
    case 'off':
      return '&#9899;'; // Black circle
    case 'auto':
      return '&#9889;'; // Lightning
    case 'always':
      return '&#128161;'; // Lightbulb
    case 'torch':
      return '&#128294;'; // Flashlight
    default:
      return '&#9889;';
  }
}
</script>

<template>
  <div id="main">
    <webf-list-view class="flex-1 p-0 m-0">
      <div class="p-5 bg-gray-100 min-h-screen max-w-5xl mx-auto">
        <div class="text-2xl font-bold text-gray-800 mb-6 text-center">WebF Camera</div>
        <div class="flex flex-col">
          <!-- Camera Preview -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200 mb-8">
            <div class="text-lg font-semibold text-gray-800 mb-2">Camera Preview</div>
            <div class="text-sm text-gray-600 mb-5 leading-relaxed">
              Native camera integration with photo capture, video recording, flash control, and zoom
            </div>
            <div class="bg-gray-50 rounded-lg p-5 border border-gray-200">
              <!-- Camera Element -->
              <div class="w-full h-[300px] rounded-xl overflow-hidden mb-4 bg-black relative">
                <flutter-camera
                  ref="cameraRef"
                  facing="back"
                  resolution="high"
                  :flash-mode="flashMode"
                  auto-init
                  enable-audio
                  :style="{ width: '100%', height: '100%' }"
                  @cameraready="handleCameraReady"
                  @camerafailed="handleCameraFailed"
                  @photocaptured="handlePhotoCaptured"
                  @capturefailed="handleCaptureFailed"
                  @recordingstarted="handleRecordingStarted"
                  @recordingstopped="handleRecordingStopped"
                  @recordingfailed="handleRecordingFailed"
                  @cameraswitched="handleCameraSwitched"
                  @zoomchanged="handleZoomChanged"
                />
                <div v-if="!isCameraReady" class="absolute inset-0 flex flex-col items-center justify-center bg-black/80 text-white gap-3">
                  <div class="text-5xl">&#128247;</div>
                  <div>Initializing camera...</div>
                </div>
              </div>

              <!-- Camera Controls -->
              <div class="flex flex-wrap mb-4 gap-2">
                <button
                  :class="captureButtonClass"
                  :disabled="!isCameraReady || isProcessing.capture"
                  @click="takePicture"
                >
                  {{ isProcessing.capture ? '&#128248; Capturing...' : '&#128248; Take Photo' }}
                </button>
                <button
                  :class="recordButtonClass"
                  :disabled="!isCameraReady || isProcessing.record"
                  @click="toggleRecording"
                >
                  {{ isRecording ? '&#9209;&#65039; Stop Recording' : '&#127916; Record Video' }}
                </button>
                <button
                  :class="secondaryButtonClass"
                  :disabled="!isCameraReady || isProcessing.switch"
                  @click="switchCamera"
                >
                  &#128260; Switch
                </button>
                <button
                  :class="secondaryButtonClass"
                  :disabled="!isCameraReady"
                  @click="cycleFlashMode"
                >
                  <span v-html="getFlashIcon()"></span> Flash: {{ flashMode }}
                </button>
              </div>

              <!-- Zoom Control -->
              <div v-if="isCameraReady && maxZoom > minZoom" class="mb-4">
                <div class="mb-2 font-medium text-gray-800">Zoom: {{ zoomLevel.toFixed(1) }}x</div>
                <input
                  type="range"
                  :min="minZoom"
                  :max="maxZoom"
                  step="0.1"
                  :value="zoomLevel"
                  class="w-full h-2 rounded bg-gray-300 outline-none cursor-pointer"
                  @input="handleZoomChange"
                />
              </div>

              <!-- Status Messages -->
              <div v-if="statusMessage || errorMessage" class="bg-white rounded-lg p-4 border border-gray-300 mt-4">
                <template v-if="statusMessage">
                  <div class="text-sm font-semibold text-gray-800 mb-2">Status:</div>
                  <div class="text-sm leading-relaxed break-words font-mono bg-gray-50 p-2 rounded whitespace-pre-wrap text-green-600">{{ statusMessage }}</div>
                </template>
                <template v-if="errorMessage">
                  <div class="text-sm font-semibold text-gray-800 mb-2">Error:</div>
                  <div class="text-sm leading-relaxed break-words font-mono bg-gray-50 p-2 rounded whitespace-pre-wrap text-red-600">{{ errorMessage }}</div>
                </template>
              </div>

              <!-- Camera Info -->
              <div v-if="cameraInfo" class="bg-white rounded-lg p-4 border border-gray-300 mt-3">
                <div class="text-sm font-semibold text-gray-800 mb-2">Camera Info:</div>
                <div class="text-sm text-gray-600 leading-relaxed break-words font-mono bg-gray-50 p-2 rounded whitespace-pre-wrap">
                  Current: {{ cameraInfo.currentCamera.lensDirection }}
                  <br />
                  Cameras: {{ cameraInfo.cameras.length }}
                  <br />
                  Zoom: {{ cameraInfo.minZoom.toFixed(1) }}x - {{ cameraInfo.maxZoom.toFixed(1) }}x
                  <br />
                  Exposure: {{ cameraInfo.minExposureOffset.toFixed(1) }} - {{ cameraInfo.maxExposureOffset.toFixed(1) }}
                </div>
              </div>
            </div>
          </div>

          <!-- Captured Photo Preview -->
          <div v-if="capturedImage" class="bg-white rounded-xl p-6 shadow-md border border-gray-200 mb-8">
            <div class="text-lg font-semibold text-gray-800 mb-2">Captured Photo</div>
            <div class="text-sm text-gray-600 mb-5 leading-relaxed">Last photo taken with the camera</div>
            <div class="mt-3 rounded-lg overflow-hidden shadow-md bg-gray-50 p-2">
              <img :src="capturedImage" alt="Captured" class="w-full h-auto block rounded max-h-[400px] object-contain" />
            </div>
          </div>

          <!-- Recorded Video Info -->
          <div v-if="recordedVideo" class="bg-white rounded-xl p-6 shadow-md border border-gray-200 mb-8">
            <div class="text-lg font-semibold text-gray-800 mb-2">Recorded Video</div>
            <div class="text-sm text-gray-600 mb-5 leading-relaxed">Video saved to device</div>
            <div class="bg-white rounded-lg p-4 border border-gray-300 mt-4">
              <div class="text-sm font-semibold text-gray-800 mb-2">File Path:</div>
              <div class="text-sm text-gray-600 leading-relaxed break-words font-mono bg-gray-50 p-2 rounded whitespace-pre-wrap">{{ recordedVideo }}</div>
            </div>
          </div>

          <!-- Usage Guide -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200 mb-8">
            <div class="text-lg font-semibold text-gray-800 mb-2">Usage Guide</div>
            <div class="text-sm text-gray-600 mb-5 leading-relaxed">How to integrate the camera component in your WebF Vue app</div>
            <div class="flex flex-col gap-4">
              <div class="bg-gray-900 rounded-lg overflow-hidden">
                <div class="bg-gray-700 text-white py-2 px-3 text-xs font-semibold">1. Install the packages (Dart)</div>
                <pre class="text-gray-300 p-3 text-xs leading-relaxed overflow-x-auto m-0 font-mono">import 'package:webf_camera/webf_camera.dart';

void main() {
  installWebFCamera();
  runApp(MyApp());
}</pre>
              </div>
              <div class="bg-gray-900 rounded-lg overflow-hidden">
                <div class="bg-gray-700 text-white py-2 px-3 text-xs font-semibold">2. Use in Vue (type-only import)</div>
                <pre class="text-gray-300 p-3 text-xs leading-relaxed overflow-x-auto m-0 font-mono">&lt;script setup lang="ts"&gt;
import { ref } from 'vue';
import type { FlutterCameraElement } from '@openwebf/vue-camera';

const cameraRef = ref&lt;FlutterCameraElement | null&gt;(null);

function handleCameraReady(e: CustomEvent) {
  console.log('Camera ready:', e.detail);
}
&lt;/script&gt;

&lt;template&gt;
  &lt;flutter-camera
    ref="cameraRef"
    facing="back"
    resolution="high"
    flash-mode="auto"
    auto-init
    enable-audio
    @cameraready="handleCameraReady"
    @photocaptured="(e) =&gt; console.log('Photo:', e.detail.path)"
  /&gt;
&lt;/template&gt;</pre>
              </div>
              <div class="bg-gray-900 rounded-lg overflow-hidden">
                <div class="bg-gray-700 text-white py-2 px-3 text-xs font-semibold">3. Call methods via ref</div>
                <pre class="text-gray-300 p-3 text-xs leading-relaxed overflow-x-auto m-0 font-mono">// Take a photo
cameraRef.value?.takePicture();

// Record video
cameraRef.value?.startVideoRecording();
cameraRef.value?.stopVideoRecording();

// Switch camera
cameraRef.value?.switchCamera();

// Control flash
cameraRef.value?.setFlashMode('torch');

// Zoom
cameraRef.value?.setZoomLevel(2.0);</pre>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
