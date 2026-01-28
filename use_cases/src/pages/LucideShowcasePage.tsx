import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const LucideShowcasePage: React.FC = () => {
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
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <div className="w-full flex justify-center items-center">
          <div className="bg-gradient-to-tr from-orange-500 to-amber-400 p-6 rounded-2xl text-white shadow">
            <h1 className="text-[28px] font-bold mb-2 drop-shadow">Lucide Icons</h1>
            <p className="text-[16px]/[1.5] opacity-90">Beautiful & consistent icons for WebF applications</p>
          </div>
        </div>

        <div className="mt-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-orange-500">Icon Components</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <Item label="Icons Gallery" desc="Browse 1600+ icons with search and categories" to="/lucide/icons" />
          </div>

          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-orange-500">Features</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl p-4 border border-line">
            <ul className="space-y-3 text-[14px] text-fg-secondary">
              <li className="flex items-start gap-2">
                <span className="text-orange-500 font-bold">1600+</span>
                <span>Open source icons in a single package</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-orange-500 font-bold">6</span>
                <span>Stroke width variants (100-600) for each icon</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-500">CSS</span>
                <span>Use Tailwind classes for size and color</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-blue-500">A11y</span>
                <span>Accessibility labels for screen readers</span>
              </li>
            </ul>
          </div>

          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-orange-500">Quick Example</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl p-4 border border-line">
            <div className="p-4 bg-gray-900 text-gray-100 rounded overflow-x-auto text-sm">
              <pre>{`import { FlutterLucideIcon, LucideIcons } from '@openwebf/react-lucide-icons';

// Basic usage
<FlutterLucideIcon name={LucideIcons.rocket} />

// With size and color
<FlutterLucideIcon
  name={LucideIcons.heart}
  className="text-4xl text-red-500"
/>

// With stroke width variant
<FlutterLucideIcon
  name={LucideIcons.activity}
  strokeWidth={400}
/>`}</pre>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
