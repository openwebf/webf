import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const KeyframesPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">CSS Keyframes Animations</h1>
        <p className="text-sm text-fg-secondary mb-6">Demonstrates CSS @keyframes animations with various properties, timing functions, and effects.</p>

        {/* Basic Transform Animations */}
        <h2 className="text-lg font-medium text-fg-primary mb-3">Transform Animations</h2>
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <div className="text-sm text-fg-secondary mb-4">Basic transform animations using translate, rotate, and scale.</div>
          <div className="flex flex-wrap gap-4">
            {/* Slide */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Slide (translateX)</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg overflow-hidden">
                <div className="w-12 h-12 bg-blue-500 rounded flex items-center justify-center text-white text-2xl animate-[slide_2s_ease-in-out_infinite]">
                  🦁
                </div>
              </div>
            </div>

            {/* Spin */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Spin (rotate)</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-purple-500 rounded flex items-center justify-center text-white text-2xl animate-[spin_2s_linear_infinite]">
                  ⭐
                </div>
              </div>
            </div>

            {/* Pulse */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Pulse (scale)</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center text-white text-2xl animate-pulse">
                  ❤️
                </div>
              </div>
            </div>

            {/* Bounce */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Bounce (translateY)</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-orange-500 rounded-full flex items-center justify-center text-white text-2xl animate-bounce">
                  🏀
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Timing Functions */}
        <h2 className="text-lg font-medium text-fg-primary mb-3">Animation Timing Functions</h2>
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <div className="text-sm text-fg-secondary mb-4">Different timing functions affect animation speed curves.</div>
          <div className="space-y-3">
            <div>
              <div className="flex justify-between items-center mb-1">
                <span className="text-xs text-fg-secondary">linear</span>
                <span className="text-xs text-fg-secondary">Constant speed</span>
              </div>
              <div className="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
                <div className="absolute w-8 h-full bg-blue-500 animate-[slideLinear_3s_linear_infinite]"></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-1">
                <span className="text-xs text-fg-secondary">ease</span>
                <span className="text-xs text-fg-secondary">Slow start and end</span>
              </div>
              <div className="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
                <div className="absolute w-8 h-full bg-purple-500 animate-[slideLinear_3s_ease_infinite]"></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-1">
                <span className="text-xs text-fg-secondary">ease-in</span>
                <span className="text-xs text-fg-secondary">Slow start</span>
              </div>
              <div className="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
                <div className="absolute w-8 h-full bg-green-500 animate-[slideLinear_3s_ease-in_infinite]"></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-1">
                <span className="text-xs text-fg-secondary">ease-out</span>
                <span className="text-xs text-fg-secondary">Slow end</span>
              </div>
              <div className="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
                <div className="absolute w-8 h-full bg-orange-500 animate-[slideLinear_3s_ease-out_infinite]"></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-1">
                <span className="text-xs text-fg-secondary">ease-in-out</span>
                <span className="text-xs text-fg-secondary">Slow start and end</span>
              </div>
              <div className="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
                <div className="absolute w-8 h-full bg-red-500 animate-[slideLinear_3s_ease-in-out_infinite]"></div>
              </div>
            </div>
          </div>
        </div>

        {/* Animation Properties */}
        <h2 className="text-lg font-medium text-fg-primary mb-3">Animation Properties</h2>
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <div className="text-sm text-fg-secondary mb-4">Controlling animation behavior with different properties.</div>
          <div className="flex flex-wrap gap-4">
            {/* Iteration Count */}
            <div className="flex-1 min-w-[180px]">
              <div className="text-xs font-semibold text-fg-primary mb-2">Iteration Count</div>
              <div className="space-y-2">
                <div>
                  <div className="text-xs text-fg-secondary mb-1">infinite</div>
                  <div className="h-12 bg-white border border-line rounded-lg flex items-center justify-center">
                    <div className="w-10 h-10 bg-blue-500 rounded animate-[spin_2s_linear_infinite]"></div>
                  </div>
                </div>
                <div>
                  <div className="text-xs text-fg-secondary mb-1">3 times</div>
                  <div className="h-12 bg-white border border-line rounded-lg flex items-center justify-center">
                    <div className="w-10 h-10 bg-purple-500 rounded animate-[spin_2s_linear_3]"></div>
                  </div>
                </div>
              </div>
            </div>

            {/* Direction */}
            <div className="flex-1 min-w-[180px]">
              <div className="text-xs font-semibold text-fg-primary mb-2">Direction</div>
              <div className="space-y-2">
                <div>
                  <div className="text-xs text-fg-secondary mb-1">normal</div>
                  <div className="h-12 bg-white border border-line rounded-lg overflow-hidden relative">
                    <div className="absolute w-8 h-full bg-green-500 animate-[slideLinear_2s_linear_infinite]"></div>
                  </div>
                </div>
                <div>
                  <div className="text-xs text-fg-secondary mb-1">alternate</div>
                  <div className="h-12 bg-white border border-line rounded-lg overflow-hidden relative">
                    <div className="absolute w-8 h-full bg-orange-500 animate-[slideLinear_2s_linear_infinite_alternate]"></div>
                  </div>
                </div>
              </div>
            </div>

            {/* Fill Mode */}
            <div className="flex-1 min-w-[180px]">
              <div className="text-xs font-semibold text-fg-primary mb-2">Fill Mode</div>
              <div className="space-y-2">
                <div>
                  <div className="text-xs text-fg-secondary mb-1">forwards</div>
                  <div className="h-12 bg-white border border-line rounded-lg flex items-center justify-center">
                    <div className="w-10 h-10 bg-pink-500 rounded animate-[fadeIn_2s_ease_forwards]"></div>
                  </div>
                </div>
                <div>
                  <div className="text-xs text-fg-secondary mb-1">both</div>
                  <div className="h-12 bg-white border border-line rounded-lg flex items-center justify-center">
                    <div className="w-10 h-10 bg-cyan-500 rounded animate-[fadeIn_2s_ease_infinite_both]"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Complex Multi-Step Keyframes */}
        <h2 className="text-lg font-medium text-fg-primary mb-3">Multi-Step Keyframes</h2>
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <div className="text-sm text-fg-secondary mb-4">Animations with multiple keyframe steps for complex effects.</div>
          <div className="flex flex-wrap gap-4">
            {/* Color Cycle */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Color Cycle</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-16 h-16 rounded-lg animate-[colorCycle_4s_linear_infinite]"></div>
              </div>
            </div>

            {/* Shake */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Shake</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-red-500 rounded flex items-center justify-center text-white text-2xl animate-[shake_0.5s_ease-in-out_infinite]">
                  🔔
                </div>
              </div>
            </div>

            {/* Wobble */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Wobble</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-yellow-500 rounded-full flex items-center justify-center text-white text-2xl animate-[wobble_1s_ease-in-out_infinite]">
                  😊
                </div>
              </div>
            </div>

            {/* Flip */}
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Flip (3D)</div>
              <div className="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-indigo-500 rounded flex items-center justify-center text-white text-2xl animate-[flip_2s_ease-in-out_infinite]" style={{ transformStyle: 'preserve-3d' }}>
                  🎴
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Combined Animations */}
        <h2 className="text-lg font-medium text-fg-primary mb-3">Combined Animations</h2>
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <div className="text-sm text-fg-secondary mb-4">Multiple animations applied simultaneously.</div>
          <div className="flex flex-wrap gap-4">
            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Spin + Bounce</div>
              <div className="h-24 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded flex items-center justify-center text-white text-2xl animate-[spin_2s_linear_infinite,bounce_1s_ease-in-out_infinite]">
                  ✨
                </div>
              </div>
            </div>

            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Pulse + Rotate</div>
              <div className="h-24 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center text-white text-2xl animate-[pulse_2s_ease-in-out_infinite,spin_4s_linear_infinite]">
                  💎
                </div>
              </div>
            </div>

            <div className="flex-1 min-w-[140px] text-center">
              <div className="text-xs text-fg-secondary mb-2">Scale + Color</div>
              <div className="h-24 flex items-center justify-center bg-white border border-line rounded-lg">
                <div className="w-12 h-12 rounded-full flex items-center justify-center text-white text-2xl animate-[pulse_1.5s_ease-in-out_infinite,colorCycle_4s_linear_infinite]">
                  🌈
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Custom Keyframes with Inline Styles */}
        <style>{`
          @keyframes slide {
            0%, 100% { transform: translateX(0); }
            50% { transform: translateX(60px); }
          }
          @keyframes slideLinear {
            0% { left: 0; }
            100% { left: calc(100% - 2rem); }
          }
          @keyframes fadeIn {
            from { opacity: 0; transform: scale(0); }
            to { opacity: 1; transform: scale(1); }
          }
          @keyframes colorCycle {
            0% { background-color: #ef4444; }
            25% { background-color: #f59e0b; }
            50% { background-color: #10b981; }
            75% { background-color: #3b82f6; }
            100% { background-color: #ef4444; }
          }
          @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
          }
          @keyframes wobble {
            0%, 100% { transform: rotate(0deg); }
            25% { transform: rotate(-15deg); }
            75% { transform: rotate(15deg); }
          }
          @keyframes flip {
            0% { transform: rotateY(0deg); }
            50% { transform: rotateY(180deg); }
            100% { transform: rotateY(360deg); }
          }
        `}</style>
      </WebFListView>
    </div>
  );
};