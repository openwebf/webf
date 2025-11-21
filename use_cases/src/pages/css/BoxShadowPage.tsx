import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

type CSSProps = React.CSSProperties;

const SectionHeader: React.FC<{ title: string }>= ({ title }) => (
  <div className="mt-5 font-semibold text-[#2c3e50]">{title}</div>
);

const DemoBox: React.FC<{ label: string; style?: CSSProps; className?: string }>= ({ label, style, className }) => (
  <div className="flex flex-col mt-3">
    <div className="text-sm text-[#374151]">{label}</div>
    <div className={[
      'mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm',
      className ?? ''
    ].join(' ')}>
      <div
        className="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100"
        style={style}
      >
        {label}
      </div>
    </div>
  </div>
);

// asset used to visualize inset/outset shadows over imagery
const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;

export const BoxShadowPage: React.FC = () => {
  const basics: { label: string; style: CSSProps }[] = [
    { label: '6px -6px teal', style: { boxShadow: '6px -6px teal' } },
    { label: '10px 5px 5px black', style: { boxShadow: '10px 5px 5px black' } },
    { label: '5px 5px 10px 10px rgba(255,0,255,.5)', style: { boxShadow: '5px 5px 10px 10px rgba(255,0,255,.5)' } },
    { label: '0.5em 1em gold', style: { boxShadow: '0.5em 1em gold' } },
  ];

  const spreads: { label: string; style: CSSProps }[] = [
    { label: '0 0 0 6px #60a5fa', style: { boxShadow: '0 0 0 6px #60a5fa' } },
    { label: '0 0 10px -3px rgba(0,0,0,.5)', style: { boxShadow: '0 0 10px -3px rgba(0,0,0,.5)' } },
    { label: '0 8px 24px -6px rgba(0,0,0,.3)', style: { boxShadow: '0 8px 24px -6px rgba(0,0,0,.3)' } },
  ];

  const insetVsOutset: { label: string; style: CSSProps }[] = [
    { label: 'inset 6px -6px teal', style: { boxShadow: 'inset 6px -6px teal', borderRadius: '10px' } },
    { label: 'inset 10px 5px 5px black', style: { boxShadow: 'inset 10px 5px 5px black', borderRadius: '10px' } },
    { label: 'inset 5px 5px 10px 10px rgba(255,0,255,.5)', style: { boxShadow: 'inset 5px 5px 10px 10px rgba(255,0,255,.5)', borderRadius: '10px' } },
  ];

  const multiple: { label: string; style: CSSProps }[] = [
    { label: '3px 3px red, 6px 6px olive', style: { boxShadow: '3px 3px red, 6px 6px olive' } },
    { label: '3px 3px red, -1em 0 0.4em blue', style: { boxShadow: '3px 3px red, -1em 0 0.4em blue' } },
    { label: 'outset + inset', style: { boxShadow: '20px 20px 20px 10px rgba(255,0,255,.5), inset 5px 15px 20px 10px rgba(0,255,255,.5)', borderRadius: '24px' } },
    { label: 'diag + inset', style: { boxShadow: '20px -10px 20px 10px rgba(0,255,255,.5), inset 5px 15px 20px 10px rgba(255,0,255,.5)', borderRadius: '24px' } },
  ];

  const elevation: { label: string; style: CSSProps }[] = [
    { label: 'elev-1', style: { boxShadow: '0 1px 2px rgba(0,0,0,0.08), 0 1px 1px rgba(0,0,0,0.06)' } },
    { label: 'elev-2', style: { boxShadow: '0 2px 4px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.06)' } },
    { label: 'elev-3', style: { boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)' } },
    { label: 'elev-4', style: { boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)' } },
  ];

  const rings: { label: string; style: CSSProps }[] = [
    { label: 'ring 3px sky', style: { boxShadow: '0 0 0 3px rgba(56,189,248,0.7)', borderRadius: '8px' } },
    { label: 'focus + ring', style: { boxShadow: '0 0 0 2px #fff, 0 0 0 4px #3b82f6', borderRadius: '8px' } },
    { label: 'currentColor ring', style: { color: '#8b5cf6', boxShadow: '0 0 0 6px currentColor', borderRadius: '8px' } },
  ];

  const withBg: { label: string; style: CSSProps; className?: string }[] = [
    { label: 'img + inset', className: 'w-[220px] h-[120px]', style: { boxShadow: 'inset 0 0 20px rgba(0,0,0,0.35)', borderRadius: '16px', backgroundImage: `url(${flower})`, backgroundSize: 'cover', backgroundPosition: 'center' } },
    { label: 'gradient + glow', className: 'w-[220px] h-[120px]', style: { boxShadow: '0 0 24px 0 rgba(59,130,246,0.5)', borderRadius: '16px', backgroundImage: 'linear-gradient(135deg, #60a5fa, #f472b6)' } },
  ];

  return (
    <div id="main" className="min-h-screen">
      <WebFListView className="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
          <div className="w-full flex justify-center items-center">
            <div className="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
              <h1 className="text-[22px] font-bold mb-1 drop-shadow">Box Shadow</h1>
              <p className="text-[14px]/[1.5] opacity-90">Offsets, blur, spread, inset/outset, and multiple layers</p>
            </div>
          </div>

          <SectionHeader title="Basic offsets and blur" />
          <div className="flex flex-wrap gap-4 items-start">
            {basics.map((o, i) => (
              <DemoBox key={`b-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Spread and negative spread" />
          <div className="flex flex-wrap gap-4 items-start">
            {spreads.map((o, i) => (
              <DemoBox key={`s-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Inset shadows" />
          <div className="flex flex-wrap gap-4 items-start">
            {insetVsOutset.map((o, i) => (
              <DemoBox key={`i-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Multiple shadows" />
          <div className="flex flex-wrap gap-4 items-start">
            {multiple.map((o, i) => (
              <DemoBox key={`m-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Elevation presets" />
          <div className="flex flex-wrap gap-4 items-start">
            {elevation.map((o, i) => (
              <DemoBox key={`e-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Rings via spread" />
          <div className="flex flex-wrap gap-4 items-start">
            {rings.map((o, i) => (
              <DemoBox key={`r-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Background with inset/outset" />
          <div className="flex flex-wrap gap-4 items-start">
            {withBg.map((o, i) => (
              <DemoBox key={`bg-${i}`} label={o.label} className={o.className} style={o.style} />
            ))}
          </div>
      </WebFListView>
    </div>
  );
};
