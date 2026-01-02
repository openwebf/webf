<script setup lang="ts">
const cards = [1, 2, 3, 4];
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <p class="text-fg-secondary mb-6">Demonstrates Tailwind utilities and tokenized theme support running on WebF.</p>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Design Tokens</h2>
        <div class="flex flex-wrap gap-3">
          <div class="rounded-lg p-3 border border-line bg-surface w-full sm:w-1/2 md:w-1/4">
            <div class="h-10 w-full rounded bg-fg/10" />
            <div class="mt-2 text-sm text-fg-secondary">text-fg</div>
          </div>
          <div class="rounded-lg p-3 border border-line bg-surface w-full sm:w-1/2 md:w-1/4">
            <div class="h-10 w-full rounded bg-surface-secondary" />
            <div class="mt-2 text-sm text-fg-secondary">bg-surface-secondary</div>
          </div>
          <div class="rounded-lg p-3 border border-line bg-surface w-full sm:w-1/2 md:w-1/4">
            <div class="h-10 w-full rounded border border-line" />
            <div class="mt-2 text-sm text-fg-secondary">border-line</div>
          </div>
        </div>
        <div class="mt-3 text-sm text-fg-secondary">These map to CSS variables for light/dark theming.</div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Layout & Spacing</h2>
        <div class="flex flex-wrap gap-3">
          <div class="flex gap-2 p-3 rounded border border-line bg-surface">
            <div class="w-10 h-10 rounded bg-emerald-200" />
            <div class="w-10 h-10 rounded bg-sky-200" />
            <div class="w-10 h-10 rounded bg-amber-200" />
          </div>
          <div class="flex gap-3 p-3 rounded border border-line bg-surface">
            <div class="w-10 h-10 rounded bg-emerald-200" />
            <div class="w-10 h-10 rounded bg-sky-200" />
            <div class="w-10 h-10 rounded bg-amber-200" />
          </div>
          <div class="flex gap-4 p-3 rounded border border-line bg-surface">
            <div class="w-10 h-10 rounded bg-emerald-200" />
            <div class="w-10 h-10 rounded bg-sky-200" />
            <div class="w-10 h-10 rounded bg-amber-200" />
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Typography & Buttons</h2>
        <div class="mb-2">
          <div class="text-xl font-semibold text-fg-primary">Headline</div>
          <div class="text-sm text-fg-secondary">Supporting description with subdued tone.</div>
        </div>
        <div class="flex gap-2 flex-wrap">
          <button class="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700">Primary</button>
          <button class="px-4 py-2 rounded border border-line hover:bg-surface-hover">Secondary</button>
          <button class="px-4 py-2 rounded bg-emerald-600 text-white hover:bg-emerald-700">Success</button>
          <button class="px-4 py-2 rounded bg-red-600 text-white hover:bg-red-700">Danger</button>
        </div>
        <div class="mt-4 flex flex-col gap-1">
          <div class="text-base font-light italic">font-light italic</div>
          <div class="text-base font-medium underline decoration-dashed decoration-2 underline-offset-4">underline decoration-dashed</div>
          <div class="text-sm tracking-wide uppercase">tracking-wide uppercase</div>
          <div class="text-sm leading-7">leading-7 paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit.</div>
          <div class="text-sm text-ellipsis overflow-hidden whitespace-nowrap w-56">truncate/ellipsis example that is much longer than container</div>
          <div class="text-right text-sm">text-right</div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Animations</h2>
        <div class="flex gap-6 flex-wrap items-center">
          <div class="w-12 h-12 rounded-full border-2 border-line border-t-fg animate-spin-slow" />
          <div class="w-12 h-12 rounded bg-amber-300 animate-bounce-fast" />
          <div class="w-12 h-12 rounded bg-emerald-300 animate-pulse-scale" />
        </div>
        <div class="text-sm text-fg-secondary mt-2">Uses custom animations configured in Tailwind.</div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Colors & Backgrounds</h2>
        <div class="flex flex-wrap gap-3">
          <div class="rounded-lg p-3 border border-line bg-white w-full sm:w-[220px]">
            <div class="text-red-600 font-medium">text-red-600</div>
            <div class="text-emerald-600 font-medium">text-emerald-600</div>
            <div class="text-sky-600 font-medium">text-sky-600</div>
          </div>
          <div class="rounded-lg p-3 border border-line bg-gradient-to-r from-sky-500 to-purple-600 text-white font-medium w-full sm:w-[220px]">
            bg-gradient-to-r
          </div>
          <div class="rounded-lg p-3 border border-line bg-surface w-full sm:w-[220px]">
            <div class="w-full h-10 rounded bg-emerald-200" />
            <div class="mt-2 w-full h-10 rounded bg-sky-200" />
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Borders, Radius & Rings</h2>
        <div class="flex flex-wrap gap-3">
          <div class="rounded-sm p-3 border border-line bg-surface w-[160px] text-sm">rounded-sm</div>
          <div class="rounded-lg p-3 border border-dashed border-line bg-surface w-[160px] text-sm">border-dashed + rounded-lg</div>
          <div class="rounded-full p-3 border border-line bg-surface w-[160px] text-sm text-center">rounded-full</div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Shadows & Filters</h2>
        <div class="flex flex-wrap gap-3 items-end">
          <div class="w-[140px] h-[70px] rounded bg-white shadow text-sm flex items-center justify-center">shadow</div>
          <div class="w-[140px] h-[70px] rounded bg-white shadow-lg text-sm flex items-center justify-center">shadow-lg</div>
          <div class="w-[140px] h-[70px] rounded bg-gradient-to-tr from-indigo-500 to-pink-500 text-white filter blur-[1px] brightness-110 flex items-center justify-center">
            filter
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Lists</h2>
        <div class="flex flex-wrap gap-6">
          <div>
            <div class="text-sm text-fg-secondary mb-1">list-disc inside</div>
            <ul class="list-disc list-inside text-sm">
              <li>Alpha</li>
              <li>Beta</li>
              <li>Gamma</li>
            </ul>
          </div>
          <div>
            <div class="text-sm text-fg-secondary mb-1">list-decimal outside</div>
            <ol class="list-decimal list-outside pl-5 text-sm">
              <li>One</li>
              <li>Two</li>
              <li>Three</li>
            </ol>
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Sizing Utilities</h2>
        <div class="flex flex-wrap gap-3 items-end">
          <div class="w-24 h-10 rounded bg-emerald-300" />
          <div class="w-32 h-12 rounded bg-sky-300" />
          <div class="w-40 h-16 rounded bg-amber-300" />
          <div class="min-w-[120px] min-h-[60px] rounded bg-purple-300" />
          <div class="max-w-[160px] h-14 rounded bg-rose-300" />
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Forms & Accent</h2>
        <div class="flex flex-wrap gap-4 items-center">
          <input
            placeholder="Placeholder"
            class="px-3 py-2 rounded border border-line bg-surface placeholder-gray-400 focus:ring-2 focus:ring-sky-400 focus:outline-none"
          />
          <label class="flex items-center gap-2 text-sm">
            <input type="checkbox" class="accent-sky-600" checked />
            accent-sky-600
          </label>
          <label class="flex items-center gap-2 text-sm">
            <input type="radio" name="r" class="accent-emerald-600" checked />
            accent-emerald-600
          </label>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Flexbox & Alignment</h2>
        <div class="rounded border border-line bg-surface p-3">
          <div class="text-sm text-fg-secondary mb-2">justify-between + items-center</div>
          <div class="flex justify-between items-center">
            <div class="w-10 h-10 rounded bg-emerald-300" />
            <div class="w-10 h-10 rounded bg-sky-300" />
            <div class="w-10 h-10 rounded bg-amber-300" />
          </div>
        </div>
        <div class="rounded border border-line bg-surface p-3 mt-3">
          <div class="text-sm text-fg-secondary mb-2">order utilities</div>
          <div class="flex gap-2">
            <div class="w-10 h-10 rounded bg-emerald-300 order-2" />
            <div class="w-10 h-10 rounded bg-sky-300 order-1" />
            <div class="w-10 h-10 rounded bg-amber-300 order-3" />
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Position & Z-Index</h2>
        <div class="flex flex-wrap gap-3">
          <div class="relative w-[160px] h-[90px] rounded border border-line bg-surface">
            <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">badge</span>
          </div>
          <div class="relative w-[160px] h-[90px]">
            <div class="absolute left-6 top-6 w-10 h-10 bg-emerald-300 rounded z-10" />
            <div class="absolute left-8 top-8 w-10 h-10 bg-sky-300 rounded z-0" />
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Spacing (space-x)</h2>
        <div class="rounded border border-line bg-surface p-3">
          <div class="flex space-x-3">
            <div class="w-10 h-10 rounded bg-emerald-300" />
            <div class="w-10 h-10 rounded bg-sky-300" />
            <div class="w-10 h-10 rounded bg-amber-300" />
          </div>
        </div>
      </section>

      <section class="mb-6 bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Cards & Flex</h2>
        <div class="flex flex-wrap gap-3">
          <div v-for="i in cards" :key="i" class="rounded-xl border border-line bg-surface p-4 hover:bg-surface-hover transition w-full sm:w-1/2">
            <div class="text-base font-semibold text-fg-primary mb-1">Card {{ i }}</div>
            <div class="text-sm text-fg-secondary">Utility‑first styling with consistent tokens.</div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>
