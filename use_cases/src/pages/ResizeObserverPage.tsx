import React, { useRef, useEffect, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

interface ResizeInfo {
  width: number;
  height: number;
  contentBoxSize?: ResizeObserverSize;
  borderBoxSize?: ResizeObserverSize;
  devicePixelContentBoxSize?: ResizeObserverSize;
}

export const ResizeObserverPage: React.FC = () => {
  const [resizeableInfo, setResizeableInfo] = useState<ResizeInfo>({ width: 0, height: 0 });
  const [textareaInfo, setTextareaInfo] = useState<ResizeInfo>({ width: 0, height: 0 });
  const [observerEntries, setObserverEntries] = useState<string[]>([]);
  
  const resizeableRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    const resizeObserver = new ResizeObserver((entries) => {
      const newEntries: string[] = [];
      
      entries.forEach((entry) => {
        const { target, contentRect, contentBoxSize, borderBoxSize, devicePixelContentBoxSize } = entry;
        const resizeInfo: ResizeInfo = {
          width: Math.round(contentRect.width),
          height: Math.round(contentRect.height),
          contentBoxSize: Array.isArray(contentBoxSize) ? contentBoxSize[0] : contentBoxSize,
          borderBoxSize: Array.isArray(borderBoxSize) ? borderBoxSize[0] : borderBoxSize,
          devicePixelContentBoxSize: Array.isArray(devicePixelContentBoxSize) ? devicePixelContentBoxSize[0] : devicePixelContentBoxSize,
        };

        newEntries.push(`${target.className || target.tagName}: ${resizeInfo.width}×${resizeInfo.height}`);

        if (target === resizeableRef.current) {
          setResizeableInfo(resizeInfo);
        } else if (target === textareaRef.current) {
          setTextareaInfo(resizeInfo);
        }
      });

      setObserverEntries(prev => [...newEntries, ...prev].slice(0, 20));
    });

    // Observe multiple elements
    const elements = [resizeableRef.current, textareaRef.current];
    elements.forEach(el => el && resizeObserver.observe(el));

    return () => resizeObserver.disconnect();
  }, []);

  const renderSizeDetails = (info: ResizeInfo, title: string) => (
    <div className="bg-surface border border-line rounded p-4">
      <div className="text-sm font-semibold text-fg-primary mb-2">{title}</div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
        <div className="flex items-center justify-between p-2 bg-white rounded border">
          <span className="text-xs font-medium text-fg-secondary">Content Rect:</span>
          <span className="text-xs font-semibold font-mono text-fg-primary">{info.width} × {info.height}</span>
        </div>
        {info.contentBoxSize && (
          <div className="flex items-center justify-between p-2 bg-white rounded border">
            <span className="text-xs font-medium text-fg-secondary">Content Box:</span>
            <span className="text-xs font-semibold font-mono text-fg-primary">{Math.round(info.contentBoxSize.inlineSize)} × {Math.round(info.contentBoxSize.blockSize)}</span>
          </div>
        )}
        {info.borderBoxSize && (
          <div className="flex items-center justify-between p-2 bg-white rounded border">
            <span className="text-xs font-medium text-fg-secondary">Border Box:</span>
            <span className="text-xs font-semibold font-mono text-fg-primary">{Math.round(info.borderBoxSize.inlineSize)} × {Math.round(info.borderBoxSize.blockSize)}</span>
          </div>
        )}
        {info.devicePixelContentBoxSize && (
          <div className="flex items-center justify-between p-2 bg-white rounded border">
            <span className="text-xs font-medium text-fg-secondary">Device Pixel:</span>
            <span className="text-xs font-semibold font-mono text-fg-primary">{Math.round(info.devicePixelContentBoxSize.inlineSize)} × {Math.round(info.devicePixelContentBoxSize.blockSize)}</span>
          </div>
        )}
      </div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-4xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">ResizeObserver API</h1>
          <div className="flex flex-col gap-6">
            
            {/* Resizeable Container */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Resizeable Container</div>
              <div className="text-sm text-fg-secondary mb-3">Drag the bottom-right corner to resize</div>
              <div
                ref={resizeableRef}
                className="relative min-w-[200px] min-h-[150px] w-[300px] h-[200px] bg-gradient-to-tr from-indigo-500 to-purple-600 rounded resize overflow-hidden flex items-center justify-center text-white mb-4"
              >
                <div className="text-center p-5">
                  <div className="text-lg font-semibold">Current Size: {resizeableInfo.width} × {resizeableInfo.height} px</div>
                  <div className="text-sm opacity-90">Aspect Ratio: {resizeableInfo.width && resizeableInfo.height ? (resizeableInfo.width / resizeableInfo.height).toFixed(2) : '1.00'}</div>
                </div>
              </div>
              {renderSizeDetails(resizeableInfo, 'Resizeable Container Details')}
            </div>

            {/* Resizeable Textarea */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Resizeable Textarea</div>
              <div className="text-sm text-fg-secondary mb-3">Textarea with resize handle - observe dimension changes</div>
              <textarea
                ref={textareaRef}
                className="w-full min-h-[120px] max-h-[400px] resize rounded border-2 border-line p-3 bg-surface focus:border-sky-500 focus:bg-white outline-none mb-4"
                placeholder="Resize me by dragging the corner..."
                defaultValue="This textarea can be resized by the user. The ResizeObserver tracks its dimension changes in real-time."
              />
              {renderSizeDetails(textareaInfo, 'Textarea Details')}
            </div>

            {/* Observer Activity Log */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Observer Activity</div>
              <div className="text-sm text-fg-secondary mb-3">Real-time log of resize events (last 20 entries)</div>
              <div className="max-h-72 overflow-y-auto bg-surface border border-line rounded p-4">
                {observerEntries.map((entry, index) => (
                  <div key={index} className="flex items-center gap-3 py-1.5 border-b border-line text-sm last:border-b-0">
                    <span className="text-fg-secondary font-mono min-w-[80px]">{new Date().toLocaleTimeString()}</span>
                    <span className="text-fg-primary font-medium">{entry}</span>
                  </div>
                ))}
                {observerEntries.length === 0 && (
                  <div className="text-center text-fg-secondary italic py-6">Resize any element above to see activity...</div>
                )}
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};
