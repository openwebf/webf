import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const BGRadialPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen">
      <WebFListView className="px-3 md:px-6 bg-[#f8f9fa] flex flex-col p-5">
          <div className="text-sm text-gray-700 font-medium mb-1">radial-gradient default vs circle</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(red, blue)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle, red, blue)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">size keywords (closest-side, farthest-side, closest-corner, farthest-corner)</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(ellipse closest-side, #3b82f6, #06b6d4, #0ea5e9)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(ellipse farthest-side, #f43f5e, #ef4444, #f97316)' }} />
          </div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle closest-corner, #22c55e, #16a34a, #15803d)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle farthest-corner, #a78bfa, #6366f1, #2563eb)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">positioning (at top-left, custom percentages, right center)</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle at top left, #f59e0b, #f97316, #ef4444)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle at 20% 80%, #10b981, #22d3ee)' }} />
          </div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(ellipse at right center, #e11d48, #fb7185, #fecdd3)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle at 70% 30%, #14b8a6, #0ea5e9, #6366f1)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">explicit radii (px/percent)</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(100px 50px at center, #ef4444, #22c55e)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(60% 40% at 30% 70%, #eab308, #f97316, #ef4444)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">multiple color stops and hard stops</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(circle, #333 0%, #333 50%, #eee 50%, #eee 75%, #333 75%)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'radial-gradient(ellipse, #60a5fa 0 20%, #a78bfa 20% 40%, #f472b6 40% 60%, #fb7185 60% 80%, #f59e0b 80% 100%)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">repeating-radial-gradient</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'repeating-radial-gradient(circle at center, #111827 0 6px, #e5e7eb 6px 12px)' }} />
            <div className="h-20 rounded w-1/2" style={{ backgroundImage: 'repeating-radial-gradient(ellipse at 40% 60%, #16a34a 0 8px, #dcfce7 8px 16px)' }} />
          </div>

          <div className="text-sm text-gray-700 font-medium mt-4 mb-1">layered radial gradients</div>
          <div className="mx-[5px] flex items-center justify-center text-center border border-red-500 w-[calc(100%_-_10px)] h-[100px] gap-[10px]">
            <div
              className="h-20 rounded w-1/2"
              style={{
                backgroundImage: 'radial-gradient(closest-side at 30% 40%, rgba(255,255,255,0.6), rgba(255,255,255,0)), radial-gradient(circle at 70% 60%, #22d3ee, #3b82f6)'
              }}
            />
            <div
              className="h-20 rounded w-1/2"
              style={{
                backgroundImage: 'radial-gradient(40% 60% at 50% 50%, rgba(255,255,255,0.4), rgba(255,255,255,0)), radial-gradient(circle at 20% 80%, #fda4af, #fb7185)'
              }}
            />
          </div>
      </WebFListView>
    </div>
  );
};
