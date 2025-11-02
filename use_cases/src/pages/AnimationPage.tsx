import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const AnimationPage: React.FC = () => {
  const [isPlaying, setIsPlaying] = useState<Record<string, boolean>>({});

  const toggleAnimation = (animationType: string) => {
    setIsPlaying((prev) => ({ ...prev, [animationType]: !prev[animationType] }));
  };

  return (
    <div id="main">
      <WebFListView className="min-h-screen w-full bg-surface p-0">
        <div className="min-h-screen p-5 md:p-6 bg-surface">
          <div className="text-2xl font-bold text-fg-primary mb-6 text-center">CSS Animations Showcase</div>
          <div className="flex flex-col gap-8">
            {/* Fade Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Fade Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Simple fade in/out animation using opacity</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br from-indigo-500 to-purple-600',
                    'transition-opacity duration-500 ease-in-out',
                    isPlaying.fade ? 'opacity-100' : 'opacity-30',
                  ].join(' ')}
                >
                  Fade
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => toggleAnimation('fade')}
                >
                  {isPlaying.fade ? 'Fade Out' : 'Fade In'}
                </button>
              </div>
            </div>

            {/* Slide Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Slide Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Transform-based sliding animation</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br from-indigo-500 to-purple-600',
                    'transition-transform duration-500 ease-out',
                    isPlaying.slide ? 'translate-x-0' : '-translate-x-12',
                  ].join(' ')}
                >
                  Slide
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => {
                    console.log('clicked');
                    toggleAnimation('slide');
                  }}
                >
                  {isPlaying.slide ? 'Slide Out' : 'Slide In'}
                </button>
              </div>
            </div>

            {/* Scale Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Scale Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Scale transformation with smooth transition</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br from-indigo-500 to-purple-600',
                    'transition-transform duration-300 ease-out',
                    isPlaying.scale ? 'scale-110' : 'scale-90',
                  ].join(' ')}
                >
                  Scale
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => toggleAnimation('scale')}
                >
                  {isPlaying.scale ? 'Scale Down' : 'Scale Up'}
                </button>
              </div>
            </div>

            {/* Rotate Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Rotate Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Continuous rotation animation</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br from-indigo-500 to-purple-600',
                    isPlaying.rotate ? 'animate-spin-slow' : '',
                  ].join(' ')}
                >
                  Rotate
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => {
                    console.log('rotate');
                    toggleAnimation('rotate');
                  }}
                >
                  {isPlaying.rotate ? 'Stop' : 'Rotate'}
                </button>
              </div>
            </div>

            {/* Bounce Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Bounce Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Bouncing animation with keyframes</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br from-indigo-500 to-purple-600',
                    isPlaying.bounce ? 'animate-bounce-fast' : '',
                  ].join(' ')}
                >
                  Bounce
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => toggleAnimation('bounce')}
                >
                  {isPlaying.bounce ? 'Stop' : 'Bounce'}
                </button>
              </div>
            </div>

            {/* Pulse Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Pulse Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Pulsing effect with scale and opacity</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br from-indigo-500 to-purple-600',
                    isPlaying.pulse ? 'animate-pulse-scale' : '',
                  ].join(' ')}
                >
                  Pulse
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => toggleAnimation('pulse')}
                >
                  {isPlaying.pulse ? 'Stop' : 'Pulse'}
                </button>
              </div>
            </div>

            {/* Combined Animation */}
            <div className="bg-surface rounded-xl p-6 shadow-md border border-line">
              <div className="text-lg font-semibold text-fg-primary mb-2">Combined Animation</div>
              <div className="text-sm text-fg-secondary mb-5 leading-relaxed">Multiple transform properties combined</div>
              <div className="flex flex-col md:flex-row items-center gap-6 p-5 bg-surface-secondary rounded-lg border-2 border-dashed border-line">
                <div
                  className={[
                    'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
                    'bg-gradient-to-br',
                    isPlaying.combined
                      ? 'translate-x-8 scale-110 rotate-[15deg] from-rose-500 to-teal-400 transition-all duration-700 ease-out'
                      : 'from-indigo-500 to-purple-600',
                  ].join(' ')}
                >
                  Combined
                </div>
                <button
                  className="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
                  onClick={() => {
                    console.log('toggle animation');
                    toggleAnimation('combined');
                  }}
                >
                  {isPlaying.combined ? 'Reset' : 'Animate'}
                </button>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};
