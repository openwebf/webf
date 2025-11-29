import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

const SectionTitle: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <h2 className="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">{children}</h2>
);

const Card: React.FC<{ children: React.ReactNode; className?: string }> = ({ children, className = '' }) => (
  <div className={`bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4 ${className}`}>
    {children}
  </div>
);

const Label: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <span className="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">
    {children}
  </span>
);

export const PositionPage: React.FC = () => {
  const [showFixed, setShowFixed] = useState(false);

  return (
    <div className="w-full h-full bg-gray-50">
      <WebFListView className="p-5 flex flex-col gap-6 w-full box-border pb-20">
        
        {/* Static Positioning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>1. Static (Default)</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-2">
              Elements appear in the normal document flow. Top, right, bottom, left, and z-index properties have no effect.
            </p>
            <div className="flex flex-col gap-2 border border-gray-100 p-2 rounded bg-gray-50">
              <div className="bg-blue-100 p-3 rounded text-blue-800 font-medium">Item 1 (Static)</div>
              <div className="bg-blue-100 p-3 rounded text-blue-800 font-medium">Item 2 (Static)</div>
              <div className="bg-blue-100 p-3 rounded text-blue-800 font-medium">Item 3 (Static)</div>
            </div>
            <Label>position: static</Label>
          </Card>
        </div>

        {/* Relative Positioning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>2. Relative</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-2">
              Positioned relative to its normal position. Other elements are not affected by the gap left.
            </p>
            <div className="flex flex-col gap-2 border border-gray-100 p-2 rounded bg-gray-50">
              <div className="bg-emerald-100 p-3 rounded text-emerald-800 opacity-50">Item 1</div>
              <div className="bg-emerald-500 p-3 rounded text-white shadow-lg relative left-8 top-2 z-10">
                Item 2 (Relative) <br/> <span className="text-xs opacity-90">left: 2rem, top: 0.5rem</span>
              </div>
              <div className="bg-emerald-100 p-3 rounded text-emerald-800 opacity-50">Item 3</div>
            </div>
            <Label>position: relative</Label>
          </Card>
        </div>

        {/* Absolute Positioning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>3. Absolute</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-2">
              Removed from normal flow. Positioned relative to the nearest positioned ancestor (non-static).
            </p>
            <div className="relative h-48 bg-slate-100 rounded border border-dashed border-slate-300 overflow-hidden">
              <div className="absolute top-0 left-0 p-2 bg-purple-500 text-white text-xs rounded-br">
                top:0 left:0
              </div>
              <div className="absolute top-4 right-4 w-12 h-12 bg-purple-400 rounded-full flex items-center justify-center text-white text-xs shadow-md">
                TR
              </div>
              <div className="absolute bottom-4 left-4 w-12 h-12 bg-purple-400 rounded-full flex items-center justify-center text-white text-xs shadow-md">
                BL
              </div>
              <div className="absolute bottom-0 right-0 p-2 bg-purple-600 text-white text-xs rounded-tl">
                bottom:0 right:0
              </div>
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-purple-700 text-white px-4 py-2 rounded shadow-xl">
                Centered
              </div>
            </div>
            <div className="flex gap-2">
              <Label>position: absolute</Label>
              <Label>position: relative (parent)</Label>
            </div>
          </Card>
        </div>

        {/* Sticky Positioning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>4. Sticky</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-2">
              Toggles between relative and fixed depending on scroll position.
            </p>
            <div className="h-48 overflow-auto border border-gray-200 rounded bg-white relative shadow-inner">
              <div className="bg-gray-50 p-2">Scroll me...</div>
              <div className="sticky top-0 bg-amber-400 text-amber-900 p-2 font-bold shadow-md z-10 flex justify-between items-center">
                <span>Sticky Header 1</span>
                <span className="text-xs font-normal bg-amber-200 px-1 rounded">top: 0</span>
              </div>
              <div className="p-4 space-y-2 text-sm text-gray-500">
                <p>Content block 1...</p>
                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
                <p>Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
              </div>
               <div className="sticky top-10 bg-amber-300 text-amber-800 p-2 font-bold shadow-md z-10 flex justify-between items-center">
                <span>Sticky Header 2</span>
                <span className="text-xs font-normal bg-amber-100 px-1 rounded">top: 2.5rem</span>
              </div>
              <div className="p-4 space-y-2 text-sm text-gray-500">
                <p>Content block 2...</p>
                <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</p>
                <p>Duis aute irure dolor in reprehenderit in voluptate velit esse.</p>
                <p>Cillum dolore eu fugiat nulla pariatur.</p>
                <p>Excepteur sint occaecat cupidatat non proident.</p>
              </div>
            </div>
            <Label>position: sticky</Label>
          </Card>
        </div>

        {/* Fixed Positioning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>5. Fixed</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-2">
              Positioned relative to the viewport. It stays in the same place even if the page is scrolled.
            </p>
            <button
              onClick={() => setShowFixed(!showFixed)}
              className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700 active:bg-indigo-800 transition-colors self-start"
            >
              {showFixed ? 'Hide Fixed Element' : 'Show Fixed Element'}
            </button>
            <Label>position: fixed</Label>
          </Card>
        </div>

        {showFixed && (
          <div className="fixed bottom-10 right-5 bg-indigo-600 text-white px-4 py-3 rounded-full shadow-2xl z-50 flex items-center gap-2 animate-bounce">
            <span className="text-xl">📌</span>
            <div className="flex flex-col">
              <span className="font-bold text-sm">Fixed Position</span>
              <span className="text-[10px] opacity-80">bottom: 2.5rem, right: 1.25rem</span>
            </div>
          </div>
        )}

      </WebFListView>
    </div>
  );
};