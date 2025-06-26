import React, { ReactNode } from 'react';

export interface WebFTouchAreaProps {
  /**
   * Children elements to render inside the touch area
   */
  children?: ReactNode;

  /**
   * Additional CSS class names
   */
  className?: string;

  /**
   * Inline styles
   */
  style?: React.CSSProperties;

  /**
   * Called when a touch starts
   */
  onTouchStart?: (event: TouchEvent) => void;

  /**
   * Called when a touch ends
   */
  onTouchEnd?: (event: TouchEvent) => void;

  /**
   * Called when a touch is cancelled
   */
  onTouchCancel?: (event: TouchEvent) => void;

  /**
   * Called when a touch moves
   */
  onTouchMove?: (event: TouchEvent) => void;

  /**
   * Called when the component is tapped/clicked
   */
  onTap?: () => void;

  /**
   * Called when the component is long pressed
   */
  onLongPress?: () => void;

  /**
   * Duration in milliseconds to trigger a long press
   * @default 500
   */
  longPressDelay?: number;
}

/**
 * WebFTouchArea - A React component that provides enhanced touch handling
 * 
 * This component wraps content and provides standardized touch event handling
 * across different platforms with support for tap and long press gestures.
 * 
 * @example
 * ```tsx
 * <WebFTouchArea
 *   onTap={() => console.log('Tapped')}
 *   onLongPress={() => console.log('Long pressed')}
 * >
 *   <div>Touch me!</div>
 * </WebFTouchArea>
 * ```
 */
export const WebFTouchArea: React.FC<WebFTouchAreaProps> = ({
  children,
  className,
  style,
  onTouchStart,
  onTouchEnd,
  onTouchCancel,
  onTouchMove,
  onTap,
  onLongPress,
  longPressDelay = 500,
}) => {
  const longPressTimerRef = React.useRef<number | null>(null);
  const touchStartTimeRef = React.useRef<number>(0);
  const movedRef = React.useRef<boolean>(false);

  const clearLongPressTimer = () => {
    if (longPressTimerRef.current) {
      clearTimeout(longPressTimerRef.current);
      longPressTimerRef.current = null;
    }
  };

  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartTimeRef.current = Date.now();
    movedRef.current = false;

    if (onLongPress) {
      longPressTimerRef.current = setTimeout(() => {
        if (!movedRef.current) {
          onLongPress();
        }
      }, longPressDelay);
    }

    if (onTouchStart) {
      onTouchStart(e.nativeEvent);
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    movedRef.current = true;
    clearLongPressTimer();

    if (onTouchMove) {
      onTouchMove(e.nativeEvent);
    }
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    clearLongPressTimer();

    const touchDuration = Date.now() - touchStartTimeRef.current;
    if (!movedRef.current && touchDuration < longPressDelay && onTap) {
      onTap();
    }

    if (onTouchEnd) {
      onTouchEnd(e.nativeEvent);
    }
  };

  const handleTouchCancel = (e: React.TouchEvent) => {
    clearLongPressTimer();

    if (onTouchCancel) {
      onTouchCancel(e.nativeEvent);
    }
  };

  return (
    <div
      className={className}
      style={{
        ...style,
        cursor: 'pointer',
        userSelect: 'none',
        WebkitUserSelect: 'none',
        WebkitTouchCallout: 'none',
      }}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      onTouchCancel={handleTouchCancel}
    >
      {children}
    </div>
  );
};