import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

const SectionHeader: React.FC<{ title: string }>= ({ title }) => (
  <div className="mt-5 font-semibold text-[#2c3e50]">{title}</div>
);

export const TransitionsPage: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [slow, setSlow] = useState(false);

  // Basics
  const [b1, setB1] = useState(false);
  const [o1, setO1] = useState(false);
  const [btn1, setBtn1] = useState(false);

  // Timing functions
  const [t1, setT1] = useState(false);
  const [t2, setT2] = useState(false);
  const [t3, setT3] = useState(false);
  const [t4, setT4] = useState(false);
  const [t5, setT5] = useState(false);

  // Durations and delays
  const [d1, setD1] = useState(false);
  const [d2, setD2] = useState(false);
  const [d3, setD3] = useState(false);
  const [d4, setD4] = useState(false);

  // Specific properties vs all
  const [p1, setP1] = useState(false);
  const [p2, setP2] = useState(false);
  const [p3, setP3] = useState(false);

  // Width transition
  const [wWide, setWWide] = useState(false);

  // Group/child translation
  const [g1, setG1] = useState(false);

  // Filters and shadow
  const [f1, setF1] = useState(false);
  const [s1, setS1] = useState(false);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
          <div className="w-full flex justify-center items-center">
            <div className="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
              <h1 className="text-[22px] font-bold mb-1 drop-shadow">Transitions</h1>
              <p className="text-[14px]/[1.5] opacity-90">Properties, durations, easing, delays, groups and stateful toggles</p>
            </div>
          </div>

          <SectionHeader title="Basics (transform + color)" />
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setB1(v => !v)} className={[ 'w-20 h-20 bg-blue-300 rounded transition-[transform,background-color] duration-300 ease-in-out cursor-pointer', b1 ? '-translate-y-2 scale-105 bg-blue-400' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">Click square to toggle transform and bg-color.</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setO1(v => !v)} className={[ 'w-20 h-20 bg-emerald-300 rounded transition-opacity duration-500 ease-in-out cursor-pointer', o1 ? 'opacity-50' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">Click square to toggle opacity (500ms).</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <button onClick={() => setBtn1(v => !v)} className={[ 'px-3 py-2 rounded border border-line transition-colors duration-200', btn1 ? 'bg-red-400' : 'bg-surface' ].join(' ')}>Click me</button>
              <div className="text-sm text-fg-secondary mt-2">Click button to toggle colors.</div>
            </div>
          </div>

          <SectionHeader title="Timing functions" />
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setT1(v => !v)} className={[ 'w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-linear cursor-pointer', t1 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">ease-linear (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setT2(v => !v)} className={[ 'w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-in cursor-pointer', t2 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">ease-in (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setT3(v => !v)} className={[ 'w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-out cursor-pointer', t3 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">ease-out (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setT4(v => !v)} className={[ 'w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-in-out cursor-pointer', t4 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">ease-in-out (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setT5(v => !v)} className={[ 'w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-[cubic-bezier(0.68,-0.55,0.27,1.55)] cursor-pointer', t5 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">cubic-bezier(0.68,-0.55,0.27,1.55) (click)</div>
            </div>
          </div>

          <SectionHeader title="Durations and delays" />
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setD1(v => !v)} className={[ 'w-20 h-20 bg-amber-300 rounded transition-transform duration-150 cursor-pointer', d1 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">duration-150 (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setD2(v => !v)} className={[ 'w-20 h-20 bg-amber-300 rounded transition-transform duration-500 cursor-pointer', d2 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">duration-500 (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setD3(v => !v)} className={[ 'w-20 h-20 bg-amber-300 rounded transition-transform duration-1000 cursor-pointer', d3 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">duration-1000 (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setD4(v => !v)} className={[ 'w-20 h-20 bg-amber-300 rounded transition-transform duration-700 delay-500 cursor-pointer', d4 ? 'translate-x-6' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">delay-500 + duration-700 (click)</div>
            </div>
          </div>

          <SectionHeader title="Specific properties vs all" />
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setP1(v => !v)} className={[ 'w-20 h-20 bg-cyan-300 rounded transition-transform duration-500 cursor-pointer', p1 ? 'translate-y-4' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">Only transform transitions (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setP2(v => !v)} className={[ 'w-20 h-20 rounded transition-colors duration-500 cursor-pointer', p2 ? 'bg-cyan-400' : 'bg-cyan-300' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">Only color transitions (click)</div>
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setP3(v => !v)} className={[ 'w-20 h-20 bg-cyan-300 rounded transition duration-500 cursor-pointer', p3 ? '-translate-y-2 bg-cyan-400' : '' ].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">All (transform + color) (click)</div>
            </div>
          </div>

          <SectionHeader title="Width/height transitions" />
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[420px]">
              <div className="text-sm text-fg-secondary mb-2">Click bar to animate width</div>
              <div onClick={() => setWWide(v => !v)} className={[ 'h-5 bg-sky-300 rounded transition-[width] duration-500 ease-in-out cursor-pointer', wWide ? 'w-64' : 'w-24' ].join(' ')} />
            </div>
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[420px]">
              <div className="text-sm text-fg-secondary mb-2">Accordion: max-height + opacity</div>
              <div className="rounded border border-line p-3">
                <div className="flex items-center justify-between">
                  <div className="font-medium">Panel</div>
                  <button onClick={() => setOpen(v => !v)} className="px-2 py-1 text-xs rounded border border-line bg-surface hover:bg-surface-hover transition-colors">{open ? 'Close' : 'Open'}</button>
                </div>
                <div className={[
                  'overflow-hidden transition-[max-height,opacity] duration-500 ease-in-out',
                  open ? 'max-h-40 opacity-100 mt-2' : 'max-h-0 opacity-0'
                ].join(' ')}>
                  <div className="text-sm text-fg-secondary">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus quis.</div>
                </div>
              </div>
            </div>
          </div>

          {/*<SectionHeader title="Click / focus / active" />*/}
          {/*<div className="flex gap-4 flex-wrap">*/}
          {/*  <div onClick={() => setG1(v => !v)} className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px] cursor-pointer">*/}
          {/*    <div className={['w-20 h-20 bg-purple-300 rounded transition-transform duration-500', g1 ? 'translate-y-3' : ''].join(' ')} />*/}
          {/*    <div className="text-sm text-fg-secondary mt-2">Click card to move child</div>*/}
          {/*  </div>*/}
          {/*  <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">*/}
          {/*    <input placeholder="Focus me" className="w-full px-2 py-2 rounded border border-line bg-surface transition-colors focus:bg-surface-hover focus:border-sky-400 outline-none" />*/}
          {/*    <div className="text-sm text-fg-secondary mt-2">Input transitions on focus</div>*/}
          {/*  </div>*/}
          {/*  <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">*/}
          {/*    <button onClick={() => setSlow(s => !s)} className={[ 'px-3 py-2 rounded border border-line bg-surface transition-[transform,box-shadow] ease-in-out', slow ? 'duration-700' : 'duration-200', 'active:translate-y-[1px] active:shadow-inner' ].join(' ')}>*/}
          {/*      Toggle speed (click)*/}
          {/*    </button>*/}
          {/*    <div className="text-sm text-fg-secondary mt-2">Active state with box-shadow + speed toggle</div>*/}
          {/*  </div>*/}
          {/*</div>*/}

          <SectionHeader title="Filter / shadow transitions" />
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div onClick={() => setS1(v => !v)} className={['w-24 h-24 bg-white rounded transition-shadow duration-500 cursor-pointer', s1 ? 'shadow-xl' : ''].join(' ')} />
              <div className="text-sm text-fg-secondary mt-2">shadow transition (click)</div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
