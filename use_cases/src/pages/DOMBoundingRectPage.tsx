import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

interface RectData {
  x: number;
  y: number;
  width: number;
  height: number;
  top: number;
  right: number;
  bottom: number;
  left: number;
}

export const DOMBoundingRectPage: React.FC = () => {
  const [currentRect, setCurrentRect] = useState<RectData | null>(null);
  const [currentElement, setCurrentElement] = useState<string>('');

  // Target element refs
  const boxRef = useRef<HTMLDivElement>(null);
  const textRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);

  // Dynamic positioning state
  const [boxPosition, setBoxPosition] = useState({ x: 50, y: 120 });

  // Constants to control demo layout heights
  const WRAP_H = 180; // further reduced for compact layout
  const BOX_H = 64;
  const MAX_TOP = WRAP_H - BOX_H - 10; // keep box within view
  const MIN_TOP = 32;

  const measureElement = (ref: React.RefObject<HTMLElement | null>, elementName: string) => {
    if (ref?.current) {
      const rect = ref.current.getBoundingClientRect();
      setCurrentRect({
        x: Math.round(rect.x * 100) / 100,
        y: Math.round(rect.y * 100) / 100,
        width: Math.round(rect.width * 100) / 100,
        height: Math.round(rect.height * 100) / 100,
        top: Math.round(rect.top * 100) / 100,
        right: Math.round(rect.right * 100) / 100,
        bottom: Math.round(rect.bottom * 100) / 100,
        left: Math.round(rect.left * 100) / 100
      });
      setCurrentElement(elementName);
    }
  };

  const moveBox = (direction: string) => {
    setBoxPosition(prev => {
      const step = 30;
      switch (direction) {
        case 'up': return { ...prev, y: Math.max(MIN_TOP, prev.y - step) };
        case 'down': return { ...prev, y: Math.min(MAX_TOP, prev.y + step) };
        case 'left': return { ...prev, x: Math.max(0, prev.x - step) };
        case 'right': return { ...prev, x: Math.min(300, prev.x + step) };
        default: return prev;
      }
    });
  };

  // Show initial measurement for better first-glance visibility
  useEffect(() => {
    if (boxRef.current) {
      measureElement(boxRef as unknown as React.RefObject<HTMLElement>, 'Moving Box');
    }
  }, []);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <div className="flex flex-col gap-6">
            {/* Current Measurement moved to the top for immediate visibility */}
            <div className="bg-surface-secondary border border-line rounded-xl p-3">
              <div className="text-lg font-medium text-fg-primary">Current Measurement</div>
              <div className="text-sm text-fg-secondary mb-3">Latest getBoundingClientRect() result</div>
              {currentRect ? (
                <div className="bg-surface border border-line rounded p-3">
                  <div className="flex items-center justify-between mb-2 pb-1 border-b border-line">
                    <span className="text-base font-semibold text-fg-primary">{currentElement}</span>
                  </div>
                  <div>
                    <div className="flex flex-wrap items-stretch gap-1.5">
                      {([
                        ['X', currentRect.x],
                        ['Y', currentRect.y],
                        ['Width', currentRect.width],
                        ['Height', currentRect.height],
                        ['Top', currentRect.top],
                        ['Right', currentRect.right],
                        ['Bottom', currentRect.bottom],
                        ['Left', currentRect.left],
                      ] as const).map(([label, value]) => (
                        <div key={label} className="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                          <span className="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">{label}:</span>
                          <span className="text-xs font-semibold font-mono text-fg-primary">{value}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center text-fg-secondary italic py-6">Click on an element below to see its measurements</div>
              )}
            </div>

            {/* Interactive Elements */}
            <div className="bg-surface-secondary border border-line rounded-xl p-3">
              <div className="text-lg font-medium text-fg-primary">Click Elements to Measure</div>
              <div className="text-sm text-fg-secondary mb-3">Click on any element below to see its getBoundingClientRect() result</div>
              <div className="relative h-[180px] border-2 border-line rounded bg-surface overflow-hidden flex">
                {/* Moving Box */}
                <div className="flex-1 relative p-4">
                  <div className="mb-1.5">
                    <span className="block text-xs font-semibold text-fg-primary mb-1">Moving Box</span>
                    <div className="flex items-center gap-1">
                      <button className="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" onClick={() => moveBox('up')}>↑</button>
                      <button className="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" onClick={() => moveBox('down')}>↓</button>
                      <button className="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" onClick={() => moveBox('left')}>←</button>
                      <button className="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" onClick={() => moveBox('right')}>→</button>
                    </div>
                  </div>
                  <div
                    ref={boxRef}
                    className="absolute w-[110px] h-[64px] bg-gradient-to-tr from-indigo-500 to-purple-600 rounded text-white font-semibold text-center shadow cursor-pointer transition-transform hover:scale-[1.02] flex items-center justify-center"
                    style={{
                      left: boxPosition.x,
                      top: boxPosition.y
                    }}
                    onClick={() => measureElement(boxRef, 'Moving Box')}
                  >
                    <div className="px-1.5 text-[11px]">Click to measure</div>
                  </div>
                </div>

                {/* Other Elements */}
                <div className="flex-1 flex flex-col p-4 border-l border-line">
                  <div
                    ref={textRef}
                    className="p-2.5 bg-white border-2 border-line rounded text-sm leading-tight cursor-pointer transition hover:border-sky-600 hover:shadow"
                    onClick={() => measureElement(textRef, 'Text Content')}
                  >
                    Click to measure this text element
                  </div>

                  <img
                    ref={imageRef}
                    src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIwIiBoZWlnaHQ9IjgwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iNjAiIGZpbGw9IiM0Q0FGNTB0Ii8+PHRleHQgeD0iNjAiIHk9IjQwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSI+SW1hZ2U8L3RleHQ+PC9zdmc+"
                    alt="Sample"
                    className="block max-w-[100px] rounded cursor-pointer transition hover:scale-105 mt-3"
                    onClick={() => measureElement(imageRef, 'Sample Image')}
                  />
                </div>
              </div>
            </div>

            {/* Current Measurement moved to top */}

          </div>
      </WebFListView>
    </div>
  );
};
