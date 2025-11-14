import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const SizingPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Sizing</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Width / Height</h2>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 120, height: 60 }}>120x60px</div>
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 180, height: 80 }}>180x80px</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Min / Max</h2>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: '30%', minWidth: 120 }}>30% min 120px</div>
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: '50%', maxWidth: 200 }}>50% max 200px</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-2">box-sizing</h2>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 120, padding: 16, borderWidth: 8, boxSizing: 'border-box' }}>border-box</div>
            </div>
            <div className="text-sm text-fg-secondary mt-2">Both boxes set width: 120px; note overall size difference.</div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Percent sizing and containing block</h2>
            <div className="text-sm text-fg-secondary mb-2">Percent width/height resolve against the containing block's size (height requires a definite parent height).</div>
            <div className="grid md:grid-cols-2 gap-4">
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-sm text-fg-secondary mb-1">Percent width</div>
                <div className="border border-line rounded p-2 w-[240px] bg-surface">
                  <div className="bg-sky-200 border border-line rounded p-1 mb-2" style={{ width: '50%' }}>50% of 240px</div>
                  <div className="bg-sky-200 border border-line rounded p-1" style={{ width: '75%' }}>75% of 240px</div>
                </div>
              </div>
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-sm text-fg-secondary mb-1">Percent height (parent 160px)</div>
                <div className="border border-line rounded p-2 bg-surface" style={{ height: 160 }}>
                  <div className="bg-emerald-200 border border-line rounded" style={{ height: '50%' }}>50% height</div>
                </div>
                <div className="text-xs text-fg-secondary mt-1">If parent height is auto, percent height acts like auto.</div>
              </div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Viewport units</h2>
            <div className="text-sm text-fg-secondary mb-2">Size relative to viewport. Useful for full-screen sections.</div>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-violet-200 border border-line rounded p-2 text-fg-secondary" style={{ width: '50vw', height: 48 }}>50vw width</div>
              <div className="bg-violet-200 border border-line rounded p-2 text-fg-secondary" style={{ width: 140, height: '20vh' }}>20vh height</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Aspect ratio</h2>
            <div className="text-sm text-fg-secondary mb-2">Constrain width/height proportion without extra wrappers.</div>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-indigo-200 border border-line rounded p-2 text-fg-secondary flex items-center justify-center" style={{ width: 120, aspectRatio: '1 / 1' }}>1:1</div>
              <div className="bg-indigo-200 border border-line rounded p-2 text-fg-secondary flex items-center justify-center" style={{ width: 160, aspectRatio: '16 / 9' }}>16:9</div>
              <div className="bg-indigo-200 border border-line rounded p-2 text-fg-secondary flex items-center justify-center" style={{ height: 100, aspectRatio: '3 / 4' }}>3:4</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Max-width with 100% width</h2>
            <div className="text-sm text-fg-secondary mb-2">Max constraints cap flexible widths.</div>
            <div className="border border-dashed border-line rounded p-2 w-[280px] bg-surface">
              <div className="bg-rose-100 border border-line rounded p-2 text-fg-secondary" style={{ width: '100%', maxWidth: 200 }}>width: 100%; max-width: 200px</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Clamp() responsive size</h2>
            <div className="text-sm text-fg-secondary mb-2">Clamp sets a min, preferred, and max in one value.</div>
            <div className="border border-dashed border-line rounded p-2 bg-surface">
              <div className="bg-lime-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 'clamp(140px, 50%, 280px)' }}>width: clamp(140px, 50%, 280px)</div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
