import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const TailwindShowcasePage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <p className="text-fg-secondary mb-6">Demonstrates Tailwind utilities and tokenized theme support running on WebF.</p>

          {/* Design Tokens */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Design Tokens</h2>
            <div className="flex flex-wrap gap-3">
              <div className="rounded-lg p-3 border border-line bg-surface w-full sm:w-1/2 md:w-1/4">
                <div className="h-10 w-full rounded bg-fg/10" />
                <div className="mt-2 text-sm text-fg-secondary">text-fg</div>
              </div>
              <div className="rounded-lg p-3 border border-line bg-surface w-full sm:w-1/2 md:w-1/4">
                <div className="h-10 w-full rounded bg-surface-secondary" />
                <div className="mt-2 text-sm text-fg-secondary">bg-surface-secondary</div>
              </div>
              <div className="rounded-lg p-3 border border-line bg-surface w-full sm:w-1/2 md:w-1/4">
                <div className="h-10 w-full rounded border border-line" />
                <div className="mt-2 text-sm text-fg-secondary">border-line</div>
              </div>
            </div>
            <div className="mt-3 text-sm text-fg-secondary">These map to CSS variables for light/dark theming.</div>
          </section>

          {/* Layout & Spacing */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Layout & Spacing</h2>
            <div className="flex flex-wrap gap-3">
              <div className="flex gap-2 p-3 rounded border border-line bg-surface">
                <div className="w-10 h-10 rounded bg-emerald-200" />
                <div className="w-10 h-10 rounded bg-sky-200" />
                <div className="w-10 h-10 rounded bg-amber-200" />
              </div>
              <div className="flex gap-3 p-3 rounded border border-line bg-surface">
                <div className="w-10 h-10 rounded bg-emerald-200" />
                <div className="w-10 h-10 rounded bg-sky-200" />
                <div className="w-10 h-10 rounded bg-amber-200" />
              </div>
              <div className="flex gap-4 p-3 rounded border border-line bg-surface">
                <div className="w-10 h-10 rounded bg-emerald-200" />
                <div className="w-10 h-10 rounded bg-sky-200" />
                <div className="w-10 h-10 rounded bg-amber-200" />
              </div>
            </div>
          </section>

          {/* Responsive Utilities */}
          {/*<section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">*/}
          {/*  <h2 className="text-lg font-medium text-fg-primary mb-3">Responsive Utilities</h2>*/}
          {/*  <div className="text-sm text-fg-secondary mb-2">Resize window to see changes.</div>*/}
          {/*  <div className="rounded border border-line bg-surface p-3">*/}
          {/*    <div className="block sm:hidden text-fg-secondary">&lt; sm: Mobile view</div>*/}
          {/*    <div className="hidden sm:block md:hidden text-fg-secondary">sm–md: Small view</div>*/}
          {/*    <div className="hidden md:block lg:hidden text-fg-secondary">md–lg: Medium view</div>*/}
          {/*    <div className="hidden lg:block text-fg-secondary">≥ lg: Large view</div>*/}
          {/*  </div>*/}
          {/*</section>*/}

          {/* Typography & Buttons */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Typography & Buttons</h2>
            <div className="mb-2">
              <div className="text-xl font-semibold text-fg-primary">Headline</div>
              <div className="text-sm text-fg-secondary">Supporting description with subdued tone.</div>
            </div>
            <div className="flex gap-2 flex-wrap">
              <button className="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700">Primary</button>
              <button className="px-4 py-2 rounded border border-line hover:bg-surface-hover">Secondary</button>
              <button className="px-4 py-2 rounded bg-emerald-600 text-white hover:bg-emerald-700">Success</button>
              <button className="px-4 py-2 rounded bg-red-600 text-white hover:bg-red-700">Danger</button>
            </div>
            <div className="mt-4 flex flex-col gap-1">
              <div className="text-base font-light italic">font-light italic</div>
              <div className="text-base font-medium underline decoration-dashed decoration-2 underline-offset-4">underline decoration-dashed</div>
              <div className="text-sm tracking-wide uppercase">tracking-wide uppercase</div>
              <div className="text-sm leading-7">leading-7 paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit.</div>
              <div className="text-sm text-ellipsis overflow-hidden whitespace-nowrap w-56">truncate/ellipsis example that is much longer than container</div>
              <div className="text-right text-sm">text-right</div>
            </div>
          </section>

          {/* Animations */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Animations</h2>
            <div className="flex gap-6 flex-wrap items-center">
              <div className="w-12 h-12 rounded-full border-2 border-line border-t-fg animate-spin-slow" />
              <div className="w-12 h-12 rounded bg-amber-300 animate-bounce-fast" />
              <div className="w-12 h-12 rounded bg-emerald-300 animate-pulse-scale" />
            </div>
            <div className="text-sm text-fg-secondary mt-2">Uses custom animations configured in Tailwind.</div>
          </section>

          {/* Colors & Backgrounds */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Colors & Backgrounds</h2>
            <div className="flex flex-wrap gap-3">
              <div className="rounded-lg p-3 border border-line bg-white w-full sm:w-[220px]">
                <div className="text-red-600 font-medium">text-red-600</div>
                <div className="text-emerald-600 font-medium">text-emerald-600</div>
                <div className="text-sky-600 font-medium">text-sky-600</div>
              </div>
              <div className="rounded-lg p-3 border border-line bg-gradient-to-r from-sky-500 to-purple-600 text-white font-medium w-full sm:w-[220px]">bg-gradient-to-r</div>
              <div className="rounded-lg p-3 border border-line bg-surface w-full sm:w-[220px]">
                <div className="w-full h-10 rounded bg-emerald-200" />
                <div className="mt-2 w-full h-10 rounded bg-sky-200" />
              </div>
            </div>
          </section>

          {/* Borders, Radius & Rings */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Borders, Radius & Rings</h2>
            <div className="flex flex-wrap gap-3">
              <div className="rounded-sm p-3 border border-line bg-surface w-[160px] text-sm">rounded-sm</div>
              <div className="rounded-lg p-3 border border-dashed border-line bg-surface w-[160px] text-sm">border-dashed + rounded-lg</div>
              <div className="rounded-full p-3 border border-line bg-surface w-[160px] text-sm text-center">rounded-full</div>
              {/*<button className="px-3 py-2 rounded bg-white ring-2 ring-sky-400 ring-offset-2">focus ring</button>*/}
            </div>
          </section>

          {/* Shadows & Filters */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Shadows & Filters</h2>
            <div className="flex flex-wrap gap-3 items-end">
              <div className="w-[140px] h-[70px] rounded bg-white shadow text-sm flex items-center justify-center">shadow</div>
              <div className="w-[140px] h-[70px] rounded bg-white shadow-lg text-sm flex items-center justify-center">shadow-lg</div>
              {/*<div className="w-[140px] h-[70px] rounded bg-emerald-300 drop-shadow-md text-sm flex items-center justify-center">drop-shadow</div>*/}
              <div className="w-[140px] h-[70px] rounded bg-gradient-to-tr from-indigo-500 to-pink-500 text-white filter blur-[1px] brightness-110 flex items-center justify-center">filter</div>
            </div>
          </section>

          {/* Object Fit & Position */}
          {/*<section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">*/}
          {/*  <h2 className="text-lg font-medium text-fg-primary mb-3">Object Fit & Position</h2>*/}
          {/*  <div className="flex flex-wrap gap-3">*/}
          {/*    <div className="w-[220px] h-[120px] rounded border border-line bg-white overflow-hidden">*/}
          {/*      <img className="w-full h-full object-cover object-center" src="https://picsum.photos/400/300" alt="cover" />*/}
          {/*    </div>*/}
          {/*    <div className="w-[220px] h-[120px] rounded border border-line bg-white overflow-hidden">*/}
          {/*      <img className="w-full h-full object-contain object-bottom" src="https://picsum.photos/400/300" alt="contain" />*/}
          {/*    </div>*/}
          {/*    <div className="w-[220px] h-[120px] rounded border border-line bg-white overflow-hidden">*/}
          {/*      <img className="w-full h-full object-none object-left-top" src="https://picsum.photos/400/300" alt="none" />*/}
          {/*    </div>*/}
          {/*  </div>*/}
          {/*</section>*/}

          {/* Lists & Tables */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Lists</h2>
            <div className="flex flex-wrap gap-6">
              <div>
                <div className="text-sm text-fg-secondary mb-1">list-disc inside</div>
                <ul className="list-disc list-inside text-sm">
                  <li>Alpha</li>
                  <li>Beta</li>
                  <li>Gamma</li>
                </ul>
              </div>
              <div>
                <div className="text-sm text-fg-secondary mb-1">list-decimal outside</div>
                <ol className="list-decimal list-outside pl-5 text-sm">
                  <li>One</li>
                  <li>Two</li>
                  <li>Three</li>
                </ol>
              </div>
            </div>
          </section>

          {/*/!* Divide & Outline *!/*/}
          {/*<section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">*/}
          {/*  <h2 className="text-lg font-medium text-fg-primary mb-3">Divide & Outline</h2>*/}
          {/*  <div className="flex flex-wrap gap-3">*/}
          {/*    <div className="rounded border border-line bg-surface p-3">*/}
          {/*      <div className="text-sm text-fg-secondary mb-2">divide-y</div>*/}
          {/*      <div className="flex flex-col divide-y divide-line">*/}
          {/*        <div className="py-1">Row 1</div>*/}
          {/*        <div className="py-1">Row 2</div>*/}
          {/*        <div className="py-1">Row 3</div>*/}
          {/*      </div>*/}
          {/*    </div>*/}
          {/*    <div className="rounded border border-line bg-surface p-3">*/}
          {/*      <div className="text-sm text-fg-secondary mb-2">outline + offset</div>*/}
          {/*      <button className="px-3 py-2 rounded bg-white outline outline-2 outline-sky-400 outline-offset-2">Outlined</button>*/}
          {/*    </div>*/}
          {/*  </div>*/}
          {/*</section>*/}

          {/* Cursor & Selection */}
          {/*<section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">*/}
          {/*  <h2 className="text-lg font-medium text-fg-primary mb-3">Cursor & Selection</h2>*/}
          {/*  <div className="flex flex-wrap gap-3 items-center">*/}
          {/*    <div className="px-3 py-2 rounded border border-line bg-surface cursor-pointer">cursor-pointer</div>*/}
          {/*    <div className="px-3 py-2 rounded border border-line bg-surface cursor-not-allowed">cursor-not-allowed</div>*/}
          {/*    <div className="px-3 py-2 rounded border border-line bg-surface select-none">select-none</div>*/}
          {/*    <div className="px-3 py-2 rounded border border-line bg-surface pointer-events-none opacity-60">pointer-events-none</div>*/}
          {/*  </div>*/}
          {/*</section>*/}

          {/*/!* SVG Fill & Stroke *!/*/}
          {/*<section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">*/}
          {/*  <h2 className="text-lg font-medium text-fg-primary mb-3">SVG Fill & Stroke</h2>*/}
          {/*  <div className="flex flex-wrap gap-6 items-center">*/}
          {/*    <svg width="72" height="72" viewBox="0 0 24 24" className="fill-emerald-300 stroke-emerald-700 stroke-2">*/}
          {/*      <circle cx="12" cy="12" r="9" />*/}
          {/*    </svg>*/}
          {/*    <svg width="72" height="72" viewBox="0 0 24 24" className="fill-none stroke-sky-600 stroke-[3]">*/}
          {/*      <path d="M4 12h16M12 4v16" />*/}
          {/*    </svg>*/}
          {/*  </div>*/}
          {/*</section>*/}

          {/* Sizing Utilities */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Sizing Utilities</h2>
            <div className="flex flex-wrap gap-3 items-end">
              <div className="w-24 h-10 rounded bg-emerald-300" />
              <div className="w-32 h-12 rounded bg-sky-300" />
              <div className="w-40 h-16 rounded bg-amber-300" />
              <div className="min-w-[120px] min-h-[60px] rounded bg-purple-300" />
              <div className="max-w-[160px] h-14 rounded bg-rose-300" />
            </div>
          </section>

          {/* Forms & Accent */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Forms & Accent</h2>
            <div className="flex flex-wrap gap-4 items-center">
              <input placeholder="Placeholder" className="px-3 py-2 rounded border border-line bg-surface placeholder-gray-400 focus:ring-2 focus:ring-sky-400 focus:outline-none" />
              <label className="flex items-center gap-2 text-sm">
                <input type="checkbox" className="accent-sky-600" defaultChecked />
                accent-sky-600
              </label>
              <label className="flex items-center gap-2 text-sm">
                <input type="radio" name="r" className="accent-emerald-600" defaultChecked />
                accent-emerald-600
              </label>
            </div>
          </section>

          {/* Backdrop & Blend */}
          {/*<section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">*/}
          {/*  <h2 className="text-lg font-medium text-fg-primary mb-3">Backdrop & Blend</h2>*/}
          {/*  <div className="flex flex-wrap gap-3 items-center">*/}
          {/*    <div className="relative w-[220px] h-[120px] rounded overflow-hidden">*/}
          {/*      <img src="https://picsum.photos/id/1025/400/300" className="w-full h-full object-cover" />*/}
          {/*      <div className="absolute inset-0 bg-white/30 backdrop-blur-sm" />*/}
          {/*    </div>*/}
          {/*    <div className="w-[220px] h-[120px] rounded bg-[url('https://picsum.photos/seed/picsum/300/200')] bg-cover bg-center bg-blend-multiply bg-purple-400" />*/}
          {/*  </div>*/}
          {/*</section>*/}
          {/* Flexbox & Alignment */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Flexbox & Alignment</h2>
            <div className="rounded border border-line bg-surface p-3">
              <div className="text-sm text-fg-secondary mb-2">justify-between + items-center</div>
              <div className="flex justify-between items-center">
                <div className="w-10 h-10 rounded bg-emerald-300" />
                <div className="w-10 h-10 rounded bg-sky-300" />
                <div className="w-10 h-10 rounded bg-amber-300" />
              </div>
            </div>
            <div className="rounded border border-line bg-surface p-3 mt-3">
              <div className="text-sm text-fg-secondary mb-2">order utilities</div>
              <div className="flex gap-2">
                <div className="w-10 h-10 rounded bg-emerald-300 order-2" />
                <div className="w-10 h-10 rounded bg-sky-300 order-1" />
                <div className="w-10 h-10 rounded bg-amber-300 order-3" />
              </div>
            </div>
          </section>

          {/* Position & Z-Index */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Position & Z-Index</h2>
            <div className="flex flex-wrap gap-3">
              <div className="relative w-[160px] h-[90px] rounded border border-line bg-surface">
                <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">badge</span>
              </div>
              <div className="relative w-[160px] h-[90px]">
                <div className="absolute left-6 top-6 w-10 h-10 bg-emerald-300 rounded z-10" />
                <div className="absolute left-8 top-8 w-10 h-10 bg-sky-300 rounded z-0" />
              </div>
            </div>
          </section>

          {/* Spacing: space-x */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Spacing (space-x)</h2>
            <div className="rounded border border-line bg-surface p-3">
              <div className="flex space-x-3">
                <div className="w-10 h-10 rounded bg-emerald-300" />
                <div className="w-10 h-10 rounded bg-sky-300" />
                <div className="w-10 h-10 rounded bg-amber-300" />
              </div>
            </div>
          </section>

          {/* Cards (Flex) */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Cards & Flex</h2>
            <div className="flex flex-wrap gap-3">
              {[1,2,3,4].map(i => (
                <div key={i} className="rounded-xl border border-line bg-surface p-4 hover:bg-surface-hover transition w-full sm:w-1/2">
                  <div className="text-base font-semibold text-fg-primary mb-1">Card {i}</div>
                  <div className="text-sm text-fg-secondary">Utility‑first styling with consistent tokens.</div>
                </div>
              ))}
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
