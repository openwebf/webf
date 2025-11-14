import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const BGGradientPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen">
      <WebFListView className="px-3 md:px-6 bg-[#f8f9fa] flex flex-col p-5">
          <div className="text-sm text-gray-700 font-medium mb-1">linear-gradient(red, yellow)</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div
              className="h-20 rounded w-1/2"
              style={{ backgroundImage: 'linear-gradient(red, yellow)' }}
            />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">linear-gradient with multiple stops</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div
              className="h-20 rounded w-1/2"
              style={{ backgroundImage: 'linear-gradient(green 40%, yellow 30%, blue 70%)' }}
            />
            <div
              className="h-20 rounded w-1/2"
              style={{ backgroundImage: 'linear-gradient(green 40%, yellow 40%, blue 70%)' }}
            />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">radial-gradient basics</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div
              className="h-20 rounded w-1/2"
              style={{ backgroundImage: 'radial-gradient(red, green)' }}
            />
            <div
              className="h-20 rounded w-1/2"
              style={{ backgroundImage: 'radial-gradient(circle at 100%, #333, #333 50%, #eee 75%, #333 75%)' }}
            />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">linear-gradient angles</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'linear-gradient(45deg, #f43f5e, #3b82f6)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'linear-gradient(135deg, #22c55e, #eab308)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">transparent stops</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'linear-gradient(to right, rgba(59,130,246,0.8), transparent)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'linear-gradient(to bottom, rgba(244,63,94,0.8), rgba(244,63,94,0))' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">repeating-linear-gradient</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'repeating-linear-gradient(90deg, #111827 0 8px, #e5e7eb 8px 16px)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'repeating-linear-gradient(45deg, #f59e0b 0 10px, #fde68a 10px 20px)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">radial shapes, positions and sizes</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle closest-side at top left, #3b82f6, #06b6d4)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(ellipse farthest-corner at 30% 70%, #f43f5e, #ef4444, #f97316)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">repeating-radial-gradient</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'repeating-radial-gradient(circle at center, #e11d48 0 6px, #fee2e2 6px 12px)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'repeating-radial-gradient(ellipse at 40% 60%, #16a34a 0 8px, #dcfce7 8px 16px)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">conic-gradient</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'conic-gradient(from 0deg at 50% 50%, red, yellow, lime, aqua, blue, magenta, red)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'conic-gradient(from 90deg at right center, #fde047, #f97316, #ef4444, #a855f7, #3b82f6, #22c55e, #fde047)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">layered gradients (stripes over linear)</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div
              className="h-20 rounded w-1/2"
              style={{
                backgroundImage: 'repeating-linear-gradient(90deg, rgba(255,255,255,0.5) 0 6px, rgba(255,255,255,0.0) 6px 12px), linear-gradient(135deg, #60a5fa, #22d3ee)'
              }}
            />
            <div
              className="h-20 rounded w-1/2"
              style={{
                backgroundImage: 'repeating-linear-gradient(45deg, rgba(0,0,0,0.15) 0 8px, rgba(0,0,0,0) 8px 16px), linear-gradient(180deg, #fda4af, #fdba74)'
              }}
            />
          </div>
      </WebFListView>
    </div>
  );
};
