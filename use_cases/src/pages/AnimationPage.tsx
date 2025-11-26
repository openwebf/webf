import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const AnimationPage: React.FC = () => {
  const [isPlaying, setIsPlaying] = useState<Record<string, boolean>>({});

  const toggleAnimation = (animationType: string) => {
    setIsPlaying((prev) => ({ ...prev, [animationType]: !prev[animationType] }));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">CSS Animations Showcase</h1>
        <p className="text-sm text-fg-secondary mb-6">Interactive examples of CSS animations using transitions and transforms.</p>

        {/* Fade Animation */}
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Fade Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Simple fade in/out animation using opacity</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Slide Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Transform-based sliding animation</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
              onClick={() => toggleAnimation('slide')}
            >
              {isPlaying.slide ? 'Slide Out' : 'Slide In'}
            </button>
          </div>
        </div>

        {/* Scale Animation */}
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Scale Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Scale transformation with smooth transition</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Rotate Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Continuous rotation animation</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
              onClick={() => toggleAnimation('rotate')}
            >
              {isPlaying.rotate ? 'Stop' : 'Rotate'}
            </button>
          </div>
        </div>

        {/* Bounce Animation */}
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Bounce Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Bouncing animation with keyframes</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Pulse Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Pulsing effect with scale and opacity</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
        <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-2">Combined Animation</h2>
          <p className="text-sm text-fg-secondary mb-4 leading-relaxed">Multiple transform properties combined</p>
          <div className="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
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
              onClick={() => toggleAnimation('combined')}
            >
              {isPlaying.combined ? 'Reset' : 'Animate'}
            </button>
          </div>
        </div>

      </WebFListView>
    </div>
  );
};
