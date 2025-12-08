import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const ValuesUnitsPage: React.FC = () => {
  const baseFont = 16;
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Absolute vs Relative Units</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="flex gap-3 flex-wrap">
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: 100, height: 60 }}>100px</div>
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: '10rem', height: 60 }}>10rem</div>
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: '10em', height: 60, fontSize: 14 }}>10em (fs=14)</div>
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: '20vw', height: 60 }}>20vw</div>
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: '20vh', height: 60 }}>20vh</div>
            </div>
            <div className="text-sm text-fg-secondary mt-2">Assuming base font-size {baseFont}px: 10rem = 160px; 10em depends on element font-size.</div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">calc()</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="flex gap-3 flex-wrap">
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: 'calc(50% - 20px)', height: 60 }}>calc(50% - 20px)</div>
              <div className="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" style={{ width: 'calc(10rem + 10px)', height: 60 }}>calc(10rem + 10px)</div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
