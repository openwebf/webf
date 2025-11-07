import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const CSSShowcasePage: React.FC = () => {
  const navigateTo = (path: string) => WebFRouter.pushState({}, path);

  const Item = (props: { label: string; desc: string; to?: string }) => (
    <div
      className={`flex items-center p-4 border-b border-[#f0f0f0] cursor-pointer transition-colors hover:bg-surface-hover ${props.to ? '' : 'pointer-events-none opacity-60'}`}
      onClick={props.to ? () => navigateTo(props.to!) : undefined}
    >
      <div className="flex-1">
        <div className="text-[16px] font-semibold text-[#2c3e50] mb-1">{props.label}</div>
        <div className="text-[14px] text-[#7f8c8d] leading-snug">{props.desc}</div>
      </div>
      <div className="text-[16px] text-[#bdc3c7] font-bold">&gt;</div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-4xl mx-auto py-6">
          <div className="w-full flex justify-center items-center">
            <div className="bg-gradient-to-tr from-indigo-500 to-purple-600 p-6 rounded-2xl text-white shadow">
              <h1 className="text-[28px] font-bold mb-2 drop-shadow">CSS Showcase</h1>
              <p className="text-[16px]/[1.5] opacity-90">Organized by CSS spec areas covered in WebF integration tests</p>
            </div>
          </div>

          <div className="mt-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-sky-500">Layout & Box Model</h2>
            <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
              <Item label="Flexbox" desc="One-dimensional layout with alignment controls" to="/css/flex-layout" />
              <Item label="Display / Flow / Box" desc="Block/inline, formatting context, flow" to="/css/display-flow" />
              <Item label="Sizing" desc="Width/height/min/max, box-sizing" to="/css/sizing" />
              <Item label="Inline & Inline Formatting" desc="Baselines, line boxes, alignment" to="/css/inline-formatting" />
            </div>

            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-sky-500">Backgrounds, Borders & Overflow</h2>
            <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
              <Item label="Background" desc="Color, repeat, position and size" to="/css/bg" />
              <Item label="Background Gradient" desc="Linear gradients" to="/css/bg-gradient" />
              <Item label="Background Radial" desc="Radial gradients" to="/css/bg-radial" />
              <Item label="Background Image" desc="Images as backgrounds" to="/css/bg-image" />
              <Item label="Border" desc="Styles, widths and colors" to="/css/border" />
              <Item label="Border Radius" desc="Rounded corners" to="/css/border-radius" />
              <Item label="Box Shadow" desc="Shadow and depth effects" to="/css/box-shadow" />
              <Item label="Overflow" desc="Hidden, scroll and auto handling" to="/css/overflow" />
            </div>

            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-sky-500">Transforms & Transitions</h2>
            <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
              <Item label="Transforms" desc="Translate, scale, rotate, skew" to="/css/transforms" />
              <Item label="Transitions" desc="Smooth property changes" to="/css/transitions" />
              <Item label="Animations (Keyframes)" desc="Timeline-based animations" to="/css/keyframes" />
              <Item label="Clip Path" desc="Custom shapes and clipping" to="/css/clip-path" />
              <Item label="Filter Effects" desc="Blur, brightness, contrast and more" to="/css/filter" />
            </div>

            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-sky-500">Positioning, Text/Color, Fonts & Images</h2>
            <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
              <Item label="Positioned Layout" desc="relative, absolute, sticky, fixed" to="/css/position" />
              <Item label="Typography" desc="Text layout, overflow and decoration" to="/typography" />
              <Item label="Fonts (@font-face)" desc="Custom web fonts" to="/fontface" />
              <Item label="Images" desc="Layouts and effects" to="/image" />
              <Item label="SVG via <img>" desc="SVG image rendering" to="/svg-image" />
            </div>

            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-sky-500">Selectors, Values & Variables, Media</h2>
            <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
              <Item label="Selectors" desc="Attribute, pseudo, combinators" to="/css/selectors" />
              <Item label="Values & Variables" desc="CSS variables and units" to="/theme-toggle" />
              <Item label="Values & Units" desc="px, em, rem, vw, vh, calc()" to="/css/values-units" />
              <Item label="Media Queries" desc="Responsive design patterns" to="/responsive" />
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
