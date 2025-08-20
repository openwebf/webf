import React, { useRef, useEffect, useState, ReactElement } from 'react';

export interface WebFLazyRenderProps {
  /**
   * The content to render when the element becomes visible
   */
  children: React.ReactNode | (() => React.ReactNode);
  
  /**
   * Placeholder content to show before the element is on screen
   * @default null
   */
  placeholder?: React.ReactNode;
  
  /**
   * CSS class name for the container div
   */
  className?: string;
  
  /**
   * CSS styles for the container div
   */
  style?: React.CSSProperties;
  
  /**
   * Callback fired when the element becomes visible
   */
  onVisible?: () => void;
}

/**
 * WebFLazyRender - A component that lazily renders its children when they become visible on screen
 * 
 * This component uses WebF's "onscreen" DOM event to detect when an element becomes visible
 * in the viewport and only then renders its children. Once rendered, the content remains
 * rendered even if it goes off-screen again.
 * 
 * @example
 * ```tsx
 * <WebFLazyRender
 *   placeholder={<div>Loading...</div>}
 *   onVisible={() => console.log('Component is now visible!')}
 * >
 *   <ExpensiveComponent />
 * </WebFLazyRender>
 * ```
 * 
 * @example
 * ```tsx
 * // With render function
 * <WebFLazyRender>
 *   {() => <ComponentWithData data={fetchData()} />}
 * </WebFLazyRender>
 * ```
 */
export const WebFLazyRender: React.FC<WebFLazyRenderProps> = ({
  children,
  placeholder = null,
  className,
  style,
  onVisible,
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = containerRef.current;
    if (!element) return;

    const handleOnScreen = () => {
      if (!isVisible) {
        setIsVisible(true);
        
        if (onVisible) {
          onVisible();
        }
      }
    };

    // Listen for WebF's onscreen event
    element.addEventListener('onscreen', handleOnScreen);

    // Check if element is already on screen
    // This is a workaround in case the element is already visible when mounted
    // We'll trigger a check after a short delay
    const checkInitialVisibility = setTimeout(() => {
      // Trigger visibility check by dispatching a custom event
      // WebF should handle this and fire onscreen if the element is visible
      element.dispatchEvent(new Event('checkvisibility'));
    }, 100);

    return () => {
      element.removeEventListener('onscreen', handleOnScreen);
      clearTimeout(checkInitialVisibility);
    };
  }, [isVisible, onVisible]);

  const renderContent = () => {
    if (!isVisible) {
      return placeholder;
    }

    // Support both direct children and render function pattern
    return typeof children === 'function' ? children() : children;
  };

  return (
    <div
      ref={containerRef}
      className={className}
      style={style}
    >
      {renderContent()}
    </div>
  );
};

// Export as default as well for convenience
export default WebFLazyRender;