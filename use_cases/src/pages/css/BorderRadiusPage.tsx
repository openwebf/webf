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

// asset used to demonstrate clipping with border-radius
const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;

const BorderRadiusPage: React.FC = () => {
  const basic: string[] = ['4px', '8px', '16px', '24px', '50%', '9999px'];

  const fourValue: string[] = [
    '4px 8px 12px 16px',
    '8px 50px 30px 5px',
    '15px 50px 30px 5px',
    '1em 2em 4em 4em',
    '100px 30px', // two values => TL/BR and TR/BL
  ];

  const elliptical: string[] = [
    '2em / 5em',
    '2em 1em 4em / 0.5em 3em',
    '1em 2em 4em 4em / 1em 2em 2em 8em',
    '100px 30px / 10px',
    '50% / 20%'
  ];

  const perCorner: { label: string; style: CSSProps }[] = [
    { label: 'TL 24px', style: { borderTopLeftRadius: '24px' } },
    { label: 'TR 24px', style: { borderTopRightRadius: '24px' } },
    { label: 'BR 24px', style: { borderBottomRightRadius: '24px' } },
    { label: 'BL 24px', style: { borderBottomLeftRadius: '24px' } },
    { label: 'TL/BR 30px', style: { borderTopLeftRadius: '30px', borderBottomRightRadius: '30px' } },
    { label: 'TR/BL 30px', style: { borderTopRightRadius: '30px', borderBottomLeftRadius: '30px' } },
  ];

  const circleAndPills: { label: string; className: string; style: CSSProps }[] = [
    { label: 'Circle (50%)', className: 'w-[120px] h-[120px]', style: { borderRadius: '50%' } },
    { label: 'Pill (9999px)', className: 'w-[220px] h-[60px]', style: { borderRadius: '9999px' } },
    { label: 'Pill (50%)', className: 'w-[220px] h-[60px]', style: { borderRadius: '50%' } },
  ];

  const borderMix: { label: string; style: CSSProps }[] = [
    { label: 'solid 6px + 12px radius', style: { border: '6px solid #374151', borderRadius: '12px' } },
    { label: 'diff widths + color', style: { borderWidth: '2px 4px 8px 12px', borderStyle: 'solid', borderColor: '#ef4444', borderRadius: '20px' } },
    { label: 'per-corner + per-side', style: { borderStyle: 'solid', borderWidth: '6px', borderColor: '#f59e0b #10b981 #ef4444 #3b82f6', borderRadius: '10px 30px 60px 35px' } },
  ];

  const backgroundClip: { label: string; style: CSSProps; className?: string }[] = [
    { label: 'image + 24px radius', className: 'w-[220px] h-[120px]', style: { borderRadius: '24px', backgroundImage: `url(${flower})`, backgroundSize: 'cover', backgroundPosition: 'center' } },
    { label: 'gradient + elliptical', className: 'w-[220px] h-[120px]', style: { borderRadius: '40px 10px / 20px 50px', backgroundImage: 'linear-gradient(135deg, #60a5fa, #f472b6)' } },
  ];

  return (
    <div id="main" className="min-h-screen">
      <WebFListView className="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
          <div className="w-full flex justify-center items-center">
            <div className="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
              <h1 className="text-[22px] font-bold mb-1 drop-shadow">Border Radius</h1>
              <p className="text-[14px]/[1.5] opacity-90">Rounded corners, elliptical radii, and per-corner control</p>
            </div>
          </div>

          <SectionHeader title="Basic radii" />
          <div className="flex flex-wrap gap-4 items-start">
            {basic.map((r, i) => (
              <DemoBox key={`b-${i}`} label={r} style={{ borderRadius: r, border: '6px solid #9ca3af' }} />
            ))}
          </div>

          <SectionHeader title="Four-value/Two-value" />
          <div className="flex flex-wrap gap-4 items-start">
            {fourValue.map((r, i) => (
              <DemoBox key={`fv-${i}`} label={r} style={{ borderRadius: r, border: '6px solid #4b5563' }} />
            ))}
          </div>

          <SectionHeader title="Elliptical radii (with /)" />
          <div className="flex flex-wrap gap-4 items-start">
            {elliptical.map((r, i) => (
              <DemoBox key={`el-${i}`} label={r} style={{ borderRadius: r, border: '6px solid #10b981' }} />
            ))}
          </div>

          <SectionHeader title="Per-corner properties" />
          <div className="flex flex-wrap gap-4 items-start">
            {perCorner.map((o, i) => (
              <DemoBox key={`pc-${i}`} label={o.label} style={{ ...o.style, border: '6px solid #f59e0b' }} />
            ))}
          </div>

          <SectionHeader title="Pills and circle" />
          <div className="flex flex-wrap gap-4 items-start">
            {circleAndPills.map((o, i) => (
              <DemoBox key={`cp-${i}`} label={o.label} className={o.className} style={{ ...o.style, border: '6px solid #ef4444' }} />
            ))}
          </div>

          <SectionHeader title="With borders" />
          <div className="flex flex-wrap gap-4 items-start">
            {borderMix.map((o, i) => (
              <DemoBox key={`bm-${i}`} label={o.label} style={o.style} />
            ))}
          </div>

          <SectionHeader title="Background clipping" />
          <div className="flex flex-wrap gap-4 items-start">
            {backgroundClip.map((o, i) => (
              <DemoBox key={`bg-${i}`} label={o.label} className={o.className} style={o.style} />
            ))}
          </div>
      </WebFListView>
    </div>
  );
};
export default BorderRadiusPage
