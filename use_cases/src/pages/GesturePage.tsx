import React, { useState } from 'react';
import { WebFListView, FlutterGestureDetector } from '@openwebf/react-core-ui';
import styles from './GesturePage.module.css';

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
    const { x, y } = event.detail;
    setGestureState(prev => ({
      ...prev,
      isPanning: true,
      panPosition: { x, y },
      panDelta: { x: 0, y: 0 },
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterPanUpdate = (event: CustomEvent) => {
    console.log('Flutter pan update:', event.detail);
    const { x, y, deltaX, deltaY } = event.detail;
    setGestureState(prev => ({
      ...prev,
      panPosition: { x, y },
      panDelta: { x: deltaX, y: deltaY },
      lastGestureTime: Date.now()
    }));
  };

  const handleFlutterPanEnd = (event: CustomEvent) => {
    console.log('Flutter pan end:', event.detail);
    const { velocityX, velocityY } = event.detail;
    setGestureState(prev => ({
      ...prev,
      isPanning: false,
      panVelocity: { x: velocityX, y: velocityY },
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
    const { scale, rotation, focalPointX, focalPointY } = event.detail;
    setGestureState(prev => ({
      ...prev,
      currentScale: scale,
      currentRotation: rotation,
      focalPoint: { x: focalPointX, y: focalPointY },
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
    <WebFListView className={styles.pageContainer}>
      <h1 className={styles.pageTitle}>Gesture Detection</h1>
      
      {/* Flutter Native Gesture Detection */}
      <div className={styles.gestureSection}>
        <h2 className={styles.sectionTitle}>Flutter Native Gestures</h2>
        <p className={styles.gestureDescription}>
          Demonstrates native Flutter gesture detection using GestureDetector widget. 
          All gestures are handled by Flutter and communicated to the web layer via events.
        </p>
        <div className={styles.gestureDemo}>
          <div className={styles.gestureArea}>
            <FlutterGestureDetector
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
            />
          </div>
          <div className={styles.gestureStatus}>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Tap Count:</span>
              <span className={styles.statusValue}>{gestureState.tapCount}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Double Tap:</span>
              <span className={styles.statusValue}>{gestureState.doubleTapCount}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Long Press:</span>
              <span className={styles.statusValue}>{gestureState.longPressCount}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Is Long Pressing:</span>
              <span className={styles.statusValue}>{gestureState.isLongPressing ? 'Yes' : 'No'}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Is Panning:</span>
              <span className={styles.statusValue}>{gestureState.isPanning ? 'Yes' : 'No'}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Pan Position:</span>
              <span className={styles.statusValue}>
                ({gestureState.panPosition.x.toFixed(1)}, {gestureState.panPosition.y.toFixed(1)})
              </span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Pan Delta:</span>
              <span className={styles.statusValue}>
                ({gestureState.panDelta.x.toFixed(1)}, {gestureState.panDelta.y.toFixed(1)})
              </span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Is Scaling:</span>
              <span className={styles.statusValue}>{gestureState.isScaling ? 'Yes' : 'No'}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Scale:</span>
              <span className={styles.statusValue}>{gestureState.currentScale.toFixed(2)}</span>
            </div>
            <div className={styles.statusItem}>
              <span className={styles.statusLabel}>Rotation:</span>
              <span className={styles.statusValue}>{(gestureState.currentRotation * 180 / Math.PI).toFixed(1)}°</span>
            </div>
          </div>
        </div>
      </div>

      {/* Reset Button */}
      <button className={styles.resetButton} onClick={resetGestureState}>
        Reset All Gestures
      </button>

    </WebFListView>
  );
};