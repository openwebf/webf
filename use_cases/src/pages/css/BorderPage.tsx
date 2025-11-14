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

export const BorderPage: React.FC = () => {
  // Shorthand border examples (width style color)
  const borderStringStyles: string[] = [
    'thin solid #222',
    'medium dashed #1f2937',
    // 'thick double red',
    // 'thin dotted blue',
    '10px solid orange',
    'medium solid #0000ff',
    // '5px groove rgba(0,255,0,0.6)',
    // '10rpx ridge hsl(89,43%,51%)',
    // 'thick outset hsla(89,43%,51%,0.3)',
    // '16px inset #ab0',
    '0 none transparent',
    '10px hidden red',
  ];

  // Per-side border shorthands
  const perSideCases: { style: CSSProps; label: string }[] = [
    { style: { borderTop: '8px solid #f97316' }, label: 'border-top solid' },
    { style: { borderRight: '8px dashed #111827' }, label: 'border-right dashed' },
    { style: { borderBottom: '8px double #16a34a' }, label: 'border-bottom double' },
    { style: { borderLeft: '8px solid #0ea5e9' }, label: 'border-left solid' },
  ];

  // Multi-value per-side properties
  const sideStyleColorCases: { style: CSSProps; label: string }[] = [
    // {
    //   style: {
    //     borderWidth: '6px',
    //     borderStyle: 'dotted dashed solid double',
    //     borderColor: '#f59e0b #10b981 #ef4444 #3b82f6',
    //   },
    //   label: 'style/color per side',
    // },
    {
      style: {
        borderWidth: '2px 4px 8px 12px',
        borderStyle: 'solid',
        borderColor: '#374151',
      },
      label: 'width per side',
    },
    {
      style: {
        borderWidth: '10px',
        borderStyle: 'solid',
        borderColor: 'transparent transparent #ef4444 transparent',
      },
      label: 'only bottom visible',
    },
  ];

  // Mixed/advanced single-property cases
  const mixedCases: { style: CSSProps; label: string }[] = [
    { style: { border: '4px dashed currentColor', color: '#8b5cf6' }, label: 'currentColor + dashed' },
    { style: { border: '4px solid rgba(0,0,0,0.25)' }, label: 'rgba(0,0,0,0.25)' },
    // { style: { border: '0.5em dotted teal' }, label: '0.5em dotted teal' },
  ];

  const radiusVariants = [
    '15px',
    '10px 30px 60px 35px',
    '50px 0 0 50px',
    '20px 40px / 10px 30px',
    '8px',
  ];

  return (
    <div id="main" className="min-h-screen">
      <WebFListView className="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
          <div className="w-full flex justify-center items-center">
            <div className="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
              <h1 className="text-[22px] font-bold mb-1 drop-shadow">Border</h1>
              <p className="text-[14px]/[1.5] opacity-90">Styles, widths, colors, and per-side control</p>
            </div>
          </div>

          <SectionHeader title="Shorthand borders" />
          <div className="flex flex-wrap gap-4 items-start">
            {borderStringStyles.map((s, i) => (
              <DemoBox key={`b-${i}`} label={s} style={{ border: s }} />
            ))}
          </div>

          <SectionHeader title="Shorthand + rounded corners" />
          <div className="flex flex-wrap gap-4 items-start">
            {borderStringStyles.map((s, i) => (
              <DemoBox key={`br-${i}`} label={`${s} | r=${radiusVariants[i % radiusVariants.length]}`} style={{ border: s, borderRadius: radiusVariants[i % radiusVariants.length] }} />
            ))}
          </div>

          <SectionHeader title="Per-side borders" />
          <div className="flex flex-wrap gap-4 items-start">
            {perSideCases.map((c, i) => (
              <DemoBox key={`ps-${i}`} label={c.label} style={c.style} />
            ))}
          </div>

          <SectionHeader title="Multi-value sides" />
          <div className="flex flex-wrap gap-4 items-start">
            {sideStyleColorCases.map((c, i) => (
              <DemoBox key={`mv-${i}`} label={c.label} style={c.style} />
            ))}
          </div>

          <SectionHeader title="Mixed and special" />
          <div className="flex flex-wrap gap-4 items-start">
            {mixedCases.map((c, i) => (
              <DemoBox key={`mx-${i}`} label={c.label} style={c.style} />
            ))}
          </div>
      </WebFListView>
    </div>
  );
};
