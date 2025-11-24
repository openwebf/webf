import React, {useState} from 'react';
import {WebFListView, FlutterGestureDetector} from '@openwebf/react-core-ui';

interface GestureState {
  // Tap gestures
  tapCount: number;
  doubleTapCount: number;
  longPressCount: number;
  isLongPressing: boolean;

  // Pan gestures
  isPanning: boolean;
  panPosition: { x: number; y: number };
  panDelta: { x: number; y: number };
  panVelocity: { x: number; y: number };

  // Scale gestures
  isScaling: boolean;
  currentScale: number;
  currentRotation: number;
  focalPoint: { x: number; y: number };

  // Swipe gestures
  lastSwipeDirection: string;
  swipeCount: number;

  // Web-based gestures
  dragPosition: { x: number; y: number };
  isDragging: boolean;
  webScale: number;
  webRotation: number;

  // Last gesture timestamp
  lastGestureTime: number;
}

const initialState: GestureState = {
  tapCount: 0,
  doubleTapCount: 0,
  longPressCount: 0,
  isLongPressing: false,
  isPanning: false,
  panPosition: {x: 0, y: 0},
  panDelta: {x: 0, y: 0},
  panVelocity: {x: 0, y: 0},
  isScaling: false,
  currentScale: 1.0,
  currentRotation: 0,
  focalPoint: {x: 0, y: 0},
  lastSwipeDirection: '',
  swipeCount: 0,
  dragPosition: {x: 150, y: 90},
  isDragging: false,
  webScale: 1.0,
  webRotation: 0,
  lastGestureTime: 0
};

export const GesturePage: React.FC = () => {
  const [gestureState, setGestureState] = useState<GestureState>(initialState);

  // Flutter gesture handlers
  const handleFlutterTap = (event: CustomEvent) => {
    console.log('Flutter tap:', event.detail);
    setGestureState(prev => ({
      ...prev,
      tapCount: prev.tapCount + 1,
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterDoubleTap = (event: CustomEvent) => {
    console.log('Flutter double tap:', event.detail);
    setGestureState(prev => ({
      ...prev,
      doubleTapCount: prev.doubleTapCount + 1,
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterLongPress = (event: CustomEvent) => {
    console.log('Flutter long press:', event.detail);
    setGestureState(prev => ({
      ...prev,
      longPressCount: prev.longPressCount + 1,
      isLongPressing: true,
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterLongPressEnd = (event: CustomEvent) => {
    console.log('Flutter long press end:', event.detail);
    setGestureState(prev => ({
      ...prev,
      isLongPressing: false,
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterPanStart = (event: CustomEvent) => {
    console.log('Flutter pan start:', event.detail);
    const {x, y} = event.detail;
    setGestureState(prev => ({
      ...prev,
      isPanning: true,
      panPosition: {x, y},
      panDelta: {x: 0, y: 0},
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterPanUpdate = (event: CustomEvent) => {
    console.log('Flutter pan update:', event.detail);
    const {x, y, deltaX, deltaY} = event.detail;
    setGestureState(prev => ({
      ...prev,
      panPosition: {x, y},
      panDelta: {x: deltaX, y: deltaY},
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterPanEnd = (event: CustomEvent) => {
    console.log('Flutter pan end:', event.detail);
    const {velocityX, velocityY} = event.detail;
    setGestureState(prev => ({
      ...prev,
      isPanning: false,
      panVelocity: {x: velocityX, y: velocityY},
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterScaleStart = (event: CustomEvent) => {
    console.log('Flutter scale start:', event.detail);
    setGestureState(prev => ({
      ...prev,
      isScaling: true,
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterScaleUpdate = (event: CustomEvent) => {
    console.log('Flutter scale update:', event.detail);
    const {scale, rotation, focalPointX, focalPointY} = event.detail;
    setGestureState(prev => ({
      ...prev,
      currentScale: scale,
      currentRotation: rotation,
      focalPoint: {x: focalPointX, y: focalPointY},
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterScaleEnd = (event: CustomEvent) => {
    console.log('Flutter scale end:', event.detail);
    setGestureState(prev => ({
      ...prev,
      isScaling: false,
      lastGestureTime: Date.now()
    }));
  };

  const resetGestureState = () => {
    setGestureState(initialState);
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">Gesture Detection</h1>

        {/* Flutter Native Gesture Detection */}
        <div className="mb-6 p-4 bg-surface-secondary rounded-xl border border-line">
          <h2 className="text-lg font-semibold text-fg-primary mb-4">FlutterGestureDetector Component</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">
            Demonstrates the <code className="px-1.5 py-0.5 bg-surface rounded text-blue-600 font-mono text-xs">FlutterGestureDetector</code> component from <code className="px-1.5 py-0.5 bg-surface rounded text-blue-600 font-mono text-xs">@openwebf/react-core-ui</code>.
            This component wraps Flutter's native GestureDetector widget, enabling rich gesture interactions including tap, double tap, long press, pan, pinch-to-scale, and rotation gestures.
          </p>
          <div className="flex gap-4 items-stretch flex-wrap">
            <FlutterGestureDetector
              className="flex-1 min-w-[300px] max-w-full bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 border-2 border-blue-300 rounded-xl flex items-center justify-center relative cursor-pointer transition-all duration-200 overflow-hidden hover:border-blue-500 hover:shadow-lg"
              onTap={handleFlutterTap}
              onDoubletap={handleFlutterDoubleTap}
              onLongpress={handleFlutterLongPress}
              onLongpressend={handleFlutterLongPressEnd}
              onPanstart={handleFlutterPanStart}
              onPanupdate={handleFlutterPanUpdate}
              onPanend={handleFlutterPanEnd}
              onScalestart={handleFlutterScaleStart}
              onScaleupdate={handleFlutterScaleUpdate}
              onScaleend={handleFlutterScaleEnd}
            >
              <div className="text-center p-6 select-none">
                <div className="text-xl font-bold text-blue-600 mb-3">👆 Touch Here to Test Gestures</div>
                <div className="text-sm text-fg-secondary space-y-1.5 mb-3">
                  <div><span className="font-semibold">Tap</span> • <span className="font-semibold">Double Tap</span> • <span className="font-semibold">Long Press</span></div>
                  <div><span className="font-semibold">Pan (Drag)</span> • <span className="font-semibold">Pinch</span> • <span className="font-semibold">Rotate</span></div>
                </div>
                <div className="text-xs text-fg-secondary italic">This entire colored area is interactive</div>
              </div>
            </FlutterGestureDetector>
            <div className="flex-1 min-w-[280px] max-w-full p-4 bg-white border border-line rounded-xl space-y-4">
              {/* Tap Gestures */}
              <div>
                <div className="text-xs font-bold text-fg-primary mb-2 uppercase tracking-wide">Tap Gestures</div>
                <div className="flex gap-2">
                  <div className="flex-1 bg-surface-secondary rounded-lg p-2 text-center">
                    <div className="text-2xl font-bold text-blue-600">{gestureState.tapCount}</div>
                    <div className="text-[10px] text-fg-secondary mt-0.5">Tap</div>
                  </div>
                  <div className="flex-1 bg-surface-secondary rounded-lg p-2 text-center">
                    <div className="text-2xl font-bold text-blue-600">{gestureState.doubleTapCount}</div>
                    <div className="text-[10px] text-fg-secondary mt-0.5">Double</div>
                  </div>
                  <div className="flex-1 bg-surface-secondary rounded-lg p-2 text-center">
                    <div className="text-2xl font-bold text-blue-600">{gestureState.longPressCount}</div>
                    <div className="text-[10px] text-fg-secondary mt-0.5">Long Press</div>
                  </div>
                </div>
              </div>

              {/* Pan Gestures */}
              <div>
                <div className="text-xs font-bold text-fg-primary mb-2 uppercase tracking-wide">Pan Gestures</div>
                <div className="space-y-2">
                  <div className="bg-surface-secondary rounded-lg p-2">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs text-fg-secondary">Status</span>
                      <span className={`text-xs font-semibold ${gestureState.isPanning ? 'text-green-600' : 'text-gray-400'}`}>
                        {gestureState.isPanning ? '● Active' : '○ Inactive'}
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-fg-secondary">Position</span>
                      <span className="font-mono text-blue-600">
                        ({gestureState.panPosition.x.toFixed(0)}, {gestureState.panPosition.y.toFixed(0)})
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-xs mt-1">
                      <span className="text-fg-secondary">Delta</span>
                      <span className="font-mono text-blue-600">
                        ({gestureState.panDelta.x.toFixed(0)}, {gestureState.panDelta.y.toFixed(0)})
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Scale Gestures */}
              <div>
                <div className="text-xs font-bold text-fg-primary mb-2 uppercase tracking-wide">Scale & Rotate</div>
                <div className="space-y-2">
                  <div className="bg-surface-secondary rounded-lg p-2">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs text-fg-secondary">Status</span>
                      <span className={`text-xs font-semibold ${gestureState.isScaling ? 'text-green-600' : 'text-gray-400'}`}>
                        {gestureState.isScaling ? '● Active' : '○ Inactive'}
                      </span>
                    </div>
                    <div className="flex gap-2 mt-2">
                      <div className="flex-1 text-center">
                        <div className="text-xl font-bold text-blue-600">{gestureState.currentScale.toFixed(2)}×</div>
                        <div className="text-[10px] text-fg-secondary">Scale</div>
                      </div>
                      <div className="flex-1 text-center">
                        <div className="text-xl font-bold text-blue-600">{(gestureState.currentRotation * 180 / Math.PI).toFixed(0)}°</div>
                        <div className="text-[10px] text-fg-secondary">Rotation</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Reset Button */}
        <button
          className="bg-red-600 text-white border-none px-5 py-2.5 rounded-lg cursor-pointer text-sm font-medium transition-all duration-200 mt-4 mb-5 hover:bg-red-700 hover:-translate-y-0.5"
          onClick={resetGestureState}
        >
          Reset All Gestures
        </button>

      </WebFListView>
    </div>
  );
};
