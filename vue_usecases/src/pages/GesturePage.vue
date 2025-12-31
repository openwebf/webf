<script setup lang="ts">
import { reactive } from 'vue';
import type {
  FlutterGestureDetectorEventDetail,
  FlutterGestureDetectorLongPressDetail,
  FlutterGestureDetectorLongPressEndDetail,
  FlutterGestureDetectorPanEndDetail,
  FlutterGestureDetectorPanStartDetail,
  FlutterGestureDetectorPanUpdateDetail,
  FlutterGestureDetectorScaleStartDetail,
  FlutterGestureDetectorScaleUpdateDetail,
  FlutterGestureDetectorScaleEndDetail,
} from '@openwebf/vue-core-ui';

interface GestureState {
  tapCount: number;
  doubleTapCount: number;
  longPressCount: number;
  isLongPressing: boolean;

  isPanning: boolean;
  panPosition: { x: number; y: number };
  panDelta: { x: number; y: number };
  panVelocity: { x: number; y: number };

  isScaling: boolean;
  currentScale: number;
  currentRotation: number;
  focalPoint: { x: number; y: number };

  lastSwipeDirection: string;
  swipeCount: number;

  dragPosition: { x: number; y: number };
  isDragging: boolean;
  webScale: number;
  webRotation: number;

  lastGestureTime: number;
}

function createInitialState(): GestureState {
  return {
    tapCount: 0,
    doubleTapCount: 0,
    longPressCount: 0,
    isLongPressing: false,
    isPanning: false,
    panPosition: { x: 0, y: 0 },
    panDelta: { x: 0, y: 0 },
    panVelocity: { x: 0, y: 0 },
    isScaling: false,
    currentScale: 1.0,
    currentRotation: 0,
    focalPoint: { x: 0, y: 0 },
    lastSwipeDirection: '',
    swipeCount: 0,
    dragPosition: { x: 150, y: 90 },
    isDragging: false,
    webScale: 1.0,
    webRotation: 0,
    lastGestureTime: 0,
  };
}

const gestureState = reactive<GestureState>(createInitialState());

function handleFlutterTap(event: CustomEvent<FlutterGestureDetectorEventDetail>) {
  console.log('Flutter tap:', event.detail);
  gestureState.tapCount += 1;
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterDoubleTap(event: CustomEvent<FlutterGestureDetectorEventDetail>) {
  console.log('Flutter double tap:', event.detail);
  gestureState.doubleTapCount += 1;
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterLongPress(event: CustomEvent<FlutterGestureDetectorLongPressDetail>) {
  console.log('Flutter long press:', event.detail);
  gestureState.longPressCount += 1;
  gestureState.isLongPressing = true;
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterLongPressEnd(event: CustomEvent<FlutterGestureDetectorLongPressEndDetail>) {
  console.log('Flutter long press end:', event.detail);
  gestureState.isLongPressing = false;
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterPanStart(event: CustomEvent<FlutterGestureDetectorPanStartDetail>) {
  console.log('Flutter pan start:', event.detail);
  const { x, y } = event.detail;
  gestureState.isPanning = true;
  gestureState.panPosition = { x, y };
  gestureState.panDelta = { x: 0, y: 0 };
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterPanUpdate(event: CustomEvent<FlutterGestureDetectorPanUpdateDetail>) {
  console.log('Flutter pan update:', event.detail);
  const { x, y, deltaX, deltaY } = event.detail;
  gestureState.panPosition = { x, y };
  gestureState.panDelta = { x: deltaX, y: deltaY };
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterPanEnd(event: CustomEvent<FlutterGestureDetectorPanEndDetail>) {
  console.log('Flutter pan end:', event.detail);
  const { velocityX, velocityY } = event.detail;
  gestureState.isPanning = false;
  gestureState.panVelocity = { x: velocityX, y: velocityY };
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterScaleStart(event: CustomEvent<FlutterGestureDetectorScaleStartDetail>) {
  console.log('Flutter scale start:', event.detail);
  gestureState.isScaling = true;
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterScaleUpdate(event: CustomEvent<FlutterGestureDetectorScaleUpdateDetail>) {
  console.log('Flutter scale update:', event.detail);
  const { scale, rotation, focalPointX, focalPointY } = event.detail;
  gestureState.currentScale = scale;
  gestureState.currentRotation = rotation;
  gestureState.focalPoint = { x: focalPointX, y: focalPointY };
  gestureState.lastGestureTime = Date.now();
}

function handleFlutterScaleEnd(event: CustomEvent<FlutterGestureDetectorScaleEndDetail>) {
  console.log('Flutter scale end:', event.detail);
  gestureState.isScaling = false;
  gestureState.lastGestureTime = Date.now();
}

function resetGestureState() {
  Object.assign(gestureState, createInitialState());
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Gesture Detection</h1>

      <div class="mb-6 p-4 bg-surface-secondary rounded-xl border border-line">
        <h2 class="text-lg font-semibold text-fg-primary mb-4">FlutterGestureDetector</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">
          Demonstrates the native gesture events from <code class="px-1.5 py-0.5 bg-surface rounded text-fg">flutter-gesture-detector</code>.
          Try tap, double tap, long press, pan, pinch, and rotate.
        </p>

        <div class="flex flex-col lg:flex-row gap-4">
          <flutter-gesture-detector
            class="flex-1 min-h-[280px] bg-gradient-to-br from-blue-50 to-blue-100 border border-blue-200 rounded-xl flex items-center justify-center relative cursor-pointer transition-all duration-200 overflow-hidden hover:border-blue-500 hover:shadow-lg"
            @tap="handleFlutterTap"
            @doubletap="handleFlutterDoubleTap"
            @longpress="handleFlutterLongPress"
            @longpressend="handleFlutterLongPressEnd"
            @panstart="handleFlutterPanStart"
            @panupdate="handleFlutterPanUpdate"
            @panend="handleFlutterPanEnd"
            @scalestart="handleFlutterScaleStart"
            @scaleupdate="handleFlutterScaleUpdate"
            @scaleend="handleFlutterScaleEnd"
          >
            <div class="text-center p-6 select-none">
              <div class="text-xl font-bold text-blue-600 mb-3">Touch Here to Test Gestures</div>
              <div class="text-sm text-fg-secondary space-y-1.5 mb-3">
                <div><span class="font-semibold">Tap</span> • <span class="font-semibold">Double Tap</span> • <span class="font-semibold">Long Press</span></div>
                <div><span class="font-semibold">Pan (Drag)</span> • <span class="font-semibold">Pinch</span> • <span class="font-semibold">Rotate</span></div>
              </div>
              <div class="text-xs text-fg-secondary italic">This entire colored area is interactive</div>
            </div>
          </flutter-gesture-detector>

          <div class="flex-1 min-w-[280px] max-w-full p-4 bg-white border border-line rounded-xl space-y-4">
            <div>
              <div class="text-xs font-bold text-fg-primary mb-2 uppercase tracking-wide">Tap Gestures</div>
              <div class="flex gap-2">
                <div class="flex-1 bg-surface-secondary rounded-lg p-2 text-center">
                  <div class="text-2xl font-bold text-blue-600">{{ gestureState.tapCount }}</div>
                  <div class="text-[10px] text-fg-secondary mt-0.5">Tap</div>
                </div>
                <div class="flex-1 bg-surface-secondary rounded-lg p-2 text-center">
                  <div class="text-2xl font-bold text-blue-600">{{ gestureState.doubleTapCount }}</div>
                  <div class="text-[10px] text-fg-secondary mt-0.5">Double</div>
                </div>
                <div class="flex-1 bg-surface-secondary rounded-lg p-2 text-center">
                  <div class="text-2xl font-bold text-blue-600">{{ gestureState.longPressCount }}</div>
                  <div class="text-[10px] text-fg-secondary mt-0.5">Long Press</div>
                </div>
              </div>
              <div class="mt-2 text-xs text-fg-secondary">
                Long press status:
                <span :class="gestureState.isLongPressing ? 'text-green-600 font-semibold' : 'text-gray-400'">
                  {{ gestureState.isLongPressing ? '● Active' : '○ Inactive' }}
                </span>
              </div>
            </div>

            <div>
              <div class="text-xs font-bold text-fg-primary mb-2 uppercase tracking-wide">Pan Gestures</div>
              <div class="space-y-2">
                <div class="bg-surface-secondary rounded-lg p-2">
                  <div class="flex items-center justify-between mb-1">
                    <span class="text-xs text-fg-secondary">Status</span>
                    <span :class="gestureState.isPanning ? 'text-green-600 text-xs font-semibold' : 'text-gray-400 text-xs font-semibold'">
                      {{ gestureState.isPanning ? '● Active' : '○ Inactive' }}
                    </span>
                  </div>
                  <div class="flex items-center justify-between text-xs">
                    <span class="text-fg-secondary">Position</span>
                    <span class="font-mono text-blue-600">({{ gestureState.panPosition.x.toFixed(0) }}, {{ gestureState.panPosition.y.toFixed(0) }})</span>
                  </div>
                  <div class="flex items-center justify-between text-xs mt-1">
                    <span class="text-fg-secondary">Delta</span>
                    <span class="font-mono text-blue-600">({{ gestureState.panDelta.x.toFixed(0) }}, {{ gestureState.panDelta.y.toFixed(0) }})</span>
                  </div>
                  <div class="flex items-center justify-between text-xs mt-1">
                    <span class="text-fg-secondary">Velocity</span>
                    <span class="font-mono text-blue-600">({{ gestureState.panVelocity.x.toFixed(0) }}, {{ gestureState.panVelocity.y.toFixed(0) }})</span>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <div class="text-xs font-bold text-fg-primary mb-2 uppercase tracking-wide">Scale &amp; Rotate</div>
              <div class="space-y-2">
                <div class="bg-surface-secondary rounded-lg p-2">
                  <div class="flex items-center justify-between mb-1">
                    <span class="text-xs text-fg-secondary">Status</span>
                    <span :class="gestureState.isScaling ? 'text-green-600 text-xs font-semibold' : 'text-gray-400 text-xs font-semibold'">
                      {{ gestureState.isScaling ? '● Active' : '○ Inactive' }}
                    </span>
                  </div>
                  <div class="flex items-center justify-between text-xs">
                    <span class="text-fg-secondary">Focal</span>
                    <span class="font-mono text-blue-600">({{ gestureState.focalPoint.x.toFixed(0) }}, {{ gestureState.focalPoint.y.toFixed(0) }})</span>
                  </div>
                  <div class="flex gap-2 mt-2">
                    <div class="flex-1 text-center">
                      <div class="text-xl font-bold text-blue-600">{{ gestureState.currentScale.toFixed(2) }}×</div>
                      <div class="text-[10px] text-fg-secondary">Scale</div>
                    </div>
                    <div class="flex-1 text-center">
                      <div class="text-xl font-bold text-blue-600">{{ ((gestureState.currentRotation * 180) / Math.PI).toFixed(0) }}°</div>
                      <div class="text-[10px] text-fg-secondary">Rotation</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <button
        class="bg-red-600 text-white border-none px-5 py-2.5 rounded-lg cursor-pointer text-sm font-medium transition-all duration-200 mt-4 mb-5 hover:bg-red-700 hover:-translate-y-0.5"
        @click="resetGestureState"
      >
        Reset All Gestures
      </button>
    </webf-list-view>
  </div>
</template>
