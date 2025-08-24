import React, { useRef, useEffect } from 'react';
import { ComparisonResult } from '../types';

interface SliderViewProps {
  comparison: ComparisonResult;
  index: number;
}

const SliderView: React.FC<SliderViewProps> = ({ comparison, index }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const overlayRef = useRef<HTMLDivElement>(null);
  const handleRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const container = containerRef.current;
    const overlay = overlayRef.current;
    const handle = handleRef.current;
    
    if (!container || !overlay || !handle) return;

    let isDragging = false;

    const startDrag = (e: MouseEvent | TouchEvent) => {
      isDragging = true;
      e.preventDefault();
    };

    const drag = (e: MouseEvent | TouchEvent) => {
      if (!isDragging) return;
      
      const rect = container.getBoundingClientRect();
      const x = 'clientX' in e ? e.clientX : e.touches[0].clientX;
      const relativeX = x - rect.left;
      const percentage = Math.max(0, Math.min(100, (relativeX / rect.width) * 100));
      
      overlay.style.width = (100 - percentage) + '%';
      handle.style.right = (100 - percentage) + '%';
    };

    const stopDrag = () => {
      isDragging = false;
    };

    container.addEventListener('mousedown', startDrag);
    handle.addEventListener('mousedown', startDrag);
    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', stopDrag);
    
    container.addEventListener('touchstart', startDrag);
    document.addEventListener('touchmove', drag);
    document.addEventListener('touchend', stopDrag);

    return () => {
      container.removeEventListener('mousedown', startDrag);
      handle.removeEventListener('mousedown', startDrag);
      document.removeEventListener('mousemove', drag);
      document.removeEventListener('mouseup', stopDrag);
      
      container.removeEventListener('touchstart', startDrag);
      document.removeEventListener('touchmove', drag);
      document.removeEventListener('touchend', stopDrag);
    };
  }, []);

  return (
    <div className="images">
      <div className="image-container" style={{ gridColumn: '1 / -1' }}>
        <div className="image-label">WebF (left) vs Chrome (right) - Drag to compare</div>
        <div className="slider-container" ref={containerRef} data-index={index}>
          <img src={comparison.webfSnapshot} alt="WebF Snapshot" className="slider-image" />
          <div className="slider-overlay" ref={overlayRef} style={{ width: '50%' }}>
            <img src={comparison.chromeSnapshot} alt="Chrome Snapshot" />
          </div>
          <div className="slider-handle" ref={handleRef}></div>
        </div>
      </div>
    </div>
  );
};

export default SliderView;