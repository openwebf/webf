import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const TailwindShowcasePage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-2">Tailwind CSS Showcase</h1>
          <p className="text-fg-secondary mb-6">Demonstrates Tailwind utilities and tokenized theme support running on WebF.</p>

          {/* Design Tokens */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Design Tokens</h2>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              <div className="rounded-lg p-3 border border-line bg-surface">
                <div className="h-10 w-full rounded bg-fg/10" />
                <div className="mt-2 text-sm text-fg-secondary">text-fg</div>
              </div>
              <div className="rounded-lg p-3 border border-line bg-surface">
                <div className="h-10 w-full rounded bg-surface" />
                <div className="mt-2 text-sm text-fg-secondary">bg-surface</div>
              </div>
              <div className="rounded-lg p-3 border border-line bg-surface">
                <div className="h-10 w-full rounded bg-surface-secondary" />
                <div className="mt-2 text-sm text-fg-secondary">bg-surface-secondary</div>
              </div>
              <div className="rounded-lg p-3 border border-line bg-surface">
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
              {[8, 12, 16].map((g) => (
                <div key={g} className={`flex gap-${g/4} p-3 rounded border border-line bg-surface`}>
                  <div className="w-10 h-10 rounded bg-emerald-200" />
                  <div className="w-10 h-10 rounded bg-sky-200" />
                  <div className="w-10 h-10 rounded bg-amber-200" />
                </div>
              ))}
            </div>
          </section>

          {/* Responsive Utilities */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Responsive Utilities</h2>
            <div className="text-sm text-fg-secondary mb-2">Resize window to see changes.</div>
            <div className="rounded border border-line bg-surface p-3">
              <div className="block sm:hidden text-fg-secondary">&lt; sm: Mobile view</div>
              <div className="hidden sm:block md:hidden text-fg-secondary">sm–md: Small view</div>
              <div className="hidden md:block lg:hidden text-fg-secondary">md–lg: Medium view</div>
              <div className="hidden lg:block text-fg-secondary">≥ lg: Large view</div>
            </div>
          </section>

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

          {/* Cards & Grid */}
          <section className="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Cards & Grid</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {[1,2,3,4].map(i => (
                <div key={i} className="rounded-xl border border-line bg-surface p-4 hover:bg-surface-hover transition">
                  <div className="text-base font-semibold text-fg-primary mb-1">Card {i}</div>
                  <div className="text-sm text-fg-secondary">Utility‑first styling with consistent tokens.</div>
                </div>
              ))}
            </div>
          </section>

          {/* Dark Mode Note */}
          <section className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Dark Mode</h2>
            <p className="text-sm text-fg-secondary">This showcase respects system dark mode (Tailwind darkMode: media) and mapped CSS variables.</p>
          </section>
        </div>
      </WebFListView>
    </div>
  );
};

