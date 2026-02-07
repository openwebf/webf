<script setup lang="ts">
const nums4 = [1, 2, 3, 4];
const nums8 = [1, 2, 3, 4, 5, 6, 7, 8];
const nums10 = Array.from({ length: 10 }, (_, i) => i + 1);
const letters5 = ['A', 'B', 'C', 'D', 'E'];
</script>

<template>
  <div id="main" class="w-full h-full bg-gray-50">
    <webf-list-view class="p-5 flex flex-col gap-6 w-full box-border pb-20">

      <!-- Hero -->
      <div class="grid grid-cols-3 grid-rows-3 gap-3 p-5 rounded-2xl" :style="{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }">
        <div class="col-span-3 bg-white/90 rounded-xl p-4 text-center text-xl font-extrabold text-indigo-700">
          CSS Grid Layout
        </div>
        <div class="bg-white/85 rounded-xl p-3 text-center font-semibold text-purple-700">Sidebar</div>
        <div class="bg-white/95 rounded-xl p-4 text-sm text-gray-700">
          CSS Grid is a two-dimensional layout system that handles both columns and rows. It is ideal for building complex page layouts with precise control.
        </div>
        <div class="bg-white/85 rounded-xl p-3 text-center font-semibold text-purple-700">Aside</div>
        <div class="col-span-3 bg-white/85 rounded-xl p-3 text-center font-semibold text-purple-700">Footer</div>
      </div>

      <!-- 1. Basic Grid -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">1. Basic Grid (grid-cols)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Equal-width columns using <code>grid-cols-3</code>.</p>
          <div class="grid grid-cols-3 gap-3">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-100 border border-blue-300 text-blue-800">1</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-100 border border-blue-300 text-blue-800">2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-100 border border-blue-300 text-blue-800">3</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-amber-100 border border-amber-300 text-amber-800">4</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-amber-100 border border-amber-300 text-amber-800">5</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-amber-100 border border-amber-300 text-amber-800">6</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid grid-cols-3 gap-3</span>
        </div>
      </div>

      <!-- 2. Column Spanning -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">2. Column Spanning</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Items spanning multiple columns with <code>col-span-*</code>.</p>
          <div class="grid grid-cols-4 gap-3">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-4 bg-indigo-500 text-white">col-span-4 (full width)</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-indigo-400 text-white">col-span-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-purple-400 text-white">col-span-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-1 bg-blue-200 text-blue-800">1</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-pink-400 text-white">col-span-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-1 bg-blue-200 text-blue-800">1</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-3 bg-emerald-400 text-white">col-span-3</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-1 bg-blue-200 text-blue-800">1</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid grid-cols-4 + col-span-*</span>
        </div>
      </div>

      <!-- 3. Row Spanning -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">3. Row Spanning</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Items spanning multiple rows with <code>row-span-*</code>.</p>
          <div class="grid grid-cols-3 grid-rows-3 gap-3" :style="{ height: '220px' }">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 row-span-3 bg-violet-500 text-white">row-span-3</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-sky-200 text-sky-800">A</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 row-span-2 bg-rose-400 text-white">row-span-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-amber-200 text-amber-800">B</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-emerald-200 text-emerald-800">C</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid grid-cols-3 grid-rows-3 + row-span-*</span>
        </div>
      </div>

      <!-- 4. Gap Variants -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">4. Gap Variants</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-1">Uniform gap with <code>gap-4</code>:</p>
          <div class="grid grid-cols-4 gap-4">
            <div v-for="i in nums4" :key="`g4-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-teal-100 border border-teal-300 text-teal-800">{{ i }}</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1">Different row/column gaps with <code>gap-x-2 gap-y-6</code>:</p>
          <div class="grid grid-cols-4 gap-x-2 gap-y-6">
            <div v-for="i in nums8" :key="`gxy-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-orange-100 border border-orange-300 text-orange-800">{{ i }}</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">gap-4 / gap-x-2 gap-y-6</span>
        </div>
      </div>

      <!-- 5. Explicit Start/End -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">5. Explicit Start / End</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Place items at exact grid positions using <code>col-start-*</code> and <code>col-end-*</code>.</p>
          <div class="grid grid-cols-6 gap-2">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-start-1 col-end-3 bg-blue-400 text-white">col 1-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-start-3 col-end-7 bg-pink-400 text-white">col 3-6</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-start-1 col-end-4 bg-emerald-400 text-white">col 1-3</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-start-4 col-end-5 bg-amber-300 text-amber-800">4</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-start-5 col-end-7 bg-violet-400 text-white">col 5-6</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-start-2 col-end-6 bg-cyan-400 text-white">col 2-5</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">col-start-* col-end-*</span>
        </div>
      </div>

      <!-- 6. Named Grid Areas -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">6. Named Grid Areas</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Classic page layout using <code>grid-template-areas</code>.</p>
          <div
            class="grid gap-2"
            :style="{
              gridTemplateAreas: '\'header header header\' \'nav content sidebar\' \'footer footer footer\'',
              gridTemplateColumns: '140px 1fr 110px',
              gridTemplateRows: '50px 1fr 40px',
              height: '260px',
            }"
          >
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-500 text-white font-bold" :style="{ gridArea: 'header' }">Header</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-purple-500 text-white" :style="{ gridArea: 'nav' }">Nav</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-sky-50 border border-sky-200 text-sky-700" :style="{ gridArea: 'content' }">Content</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-500 text-white" :style="{ gridArea: 'sidebar' }">Sidebar</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-500 text-white font-bold" :style="{ gridArea: 'footer' }">Footer</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid-template-areas</span>
        </div>
      </div>

      <!-- 7. Auto Flow -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">7. Grid Auto Flow</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-1"><code>grid-flow-row</code> (default):</p>
          <div class="grid grid-cols-3 grid-flow-row gap-2">
            <div v-for="c in letters5" :key="`fr-${c}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-100 border border-blue-300 text-blue-800">{{ c }}</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1"><code>grid-flow-col</code> with 2 rows:</p>
          <div class="grid grid-rows-2 grid-flow-col gap-2">
            <div v-for="c in letters5" :key="`fc-${c}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-rose-100 border border-rose-300 text-rose-800">{{ c }}</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1"><code>grid-flow-row-dense</code> (fills gaps):</p>
          <div class="grid grid-cols-3 grid-flow-row-dense gap-2">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-indigo-400 text-white">col-span-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-amber-200 text-amber-800">B</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-indigo-400 text-white">col-span-2</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-200 text-emerald-800">D</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-cyan-200 text-cyan-800">E</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid-flow-row / grid-flow-col / grid-flow-row-dense</span>
        </div>
      </div>

      <!-- 8. Auto Columns / Auto Rows -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">8. Auto Columns &amp; Auto Rows</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-1"><code>auto-rows-min</code> — rows shrink to content:</p>
          <div class="grid grid-cols-3 auto-rows-min gap-2">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-teal-100 border border-teal-300 text-teal-800">Short</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-6 bg-teal-100 border border-teal-300 text-teal-800">Taller content with more padding</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-teal-100 border border-teal-300 text-teal-800">Short</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1"><code>auto-rows-fr</code> — rows expand equally:</p>
          <div class="grid grid-cols-3 auto-rows-fr gap-2" :style="{ height: '160px' }">
            <div v-for="i in 5" :key="`arf-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-violet-100 border border-violet-300 text-violet-800">{{ i }}</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">auto-rows-min / auto-rows-fr</span>
        </div>
      </div>

      <!-- 9. Place Items -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">9. Place Items (Align + Justify)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-1"><code>place-items-center</code>:</p>
          <div class="grid grid-cols-3 place-items-center gap-3 bg-gray-100 rounded-lg p-3" :style="{ height: '120px' }">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-400 text-white w-16 h-10">A</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-400 text-white w-16 h-10">B</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-400 text-white w-16 h-10">C</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1"><code>place-items-start</code>:</p>
          <div class="grid grid-cols-3 place-items-start gap-3 bg-gray-100 rounded-lg p-3" :style="{ height: '120px' }">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-400 text-white w-16 h-10">A</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-400 text-white w-16 h-10">B</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-400 text-white w-16 h-10">C</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1"><code>place-items-end</code>:</p>
          <div class="grid grid-cols-3 place-items-end gap-3 bg-gray-100 rounded-lg p-3" :style="{ height: '120px' }">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-400 text-white w-16 h-10">A</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-400 text-white w-16 h-10">B</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-400 text-white w-16 h-10">C</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">place-items-center / start / end</span>
        </div>
      </div>

      <!-- 10. Place Content -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">10. Place Content</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-1"><code>place-content-center</code> — centers the whole grid:</p>
          <div class="grid grid-cols-2 place-content-center gap-3 bg-gray-100 rounded-lg" :style="{ height: '180px' }">
            <div v-for="i in nums4" :key="`pcc-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-indigo-400 text-white w-20 h-12">{{ i }}</div>
          </div>
          <p class="text-sm text-gray-600 mt-3 mb-1"><code>place-content-between</code>:</p>
          <div class="grid grid-cols-2 place-content-between gap-3 bg-gray-100 rounded-lg" :style="{ height: '180px' }">
            <div v-for="i in nums4" :key="`pcb-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-rose-400 text-white w-20 h-12">{{ i }}</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">place-content-center / between</span>
        </div>
      </div>

      <!-- 11. Place Self -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">11. Place Self (Per-Item Alignment)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Override alignment on individual items with <code>place-self-*</code>.</p>
          <div class="grid grid-cols-3 gap-3 bg-gray-100 rounded-lg p-3" :style="{ height: '160px' }">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 place-self-start bg-blue-400 text-white w-16 h-10">start</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 place-self-center bg-pink-400 text-white w-16 h-10">center</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 place-self-end bg-emerald-400 text-white w-16 h-10">end</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 place-self-stretch bg-amber-300 text-amber-800">stretch</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 justify-self-end self-start bg-violet-400 text-white w-16 h-10">j-end s-start</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 justify-self-start self-end bg-cyan-400 text-white w-16 h-10">j-start s-end</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">place-self-start / center / end / stretch</span>
        </div>
      </div>

      <!-- 12. Responsive Grid -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">12. Responsive Grid</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Columns change at breakpoints: <code>grid-cols-2 md:grid-cols-4</code>.</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div v-for="i in nums8" :key="`resp-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-gradient-to-br from-blue-100 to-indigo-100 border border-indigo-200 text-indigo-700">
              Item {{ i }}
            </div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid-cols-2 md:grid-cols-4</span>
        </div>
      </div>

      <!-- 13. Auto-fill with minmax -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">13. Auto-Fill with minmax</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Auto-fill creates as many columns as will fit. Uses <code>repeat(auto-fill, minmax(80px, 1fr))</code>.</p>
          <div class="grid gap-3" :style="{ gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))' }">
            <div v-for="i in nums10" :key="`af-${i}`" class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-100 border border-emerald-300 text-emerald-800">{{ i }}</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">repeat(auto-fill, minmax(80px, 1fr))</span>
        </div>
      </div>

      <!-- 14. Nested Grid -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">14. Nested Grids</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Grids inside grid cells for complex layouts.</p>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid grid-cols-2 gap-2 bg-blue-50 rounded-lg p-3 border border-blue-200">
              <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-400 text-white">A1</div>
              <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-blue-300 text-white">A2</div>
              <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-blue-500 text-white">A3 (span 2)</div>
            </div>
            <div class="grid grid-rows-3 gap-2 bg-pink-50 rounded-lg p-3 border border-pink-200">
              <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-400 text-white">B1</div>
              <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-300 text-white">B2</div>
              <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-pink-500 text-white">B3</div>
            </div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">Nested grid grid-cols-2 inside grid cells</span>
        </div>
      </div>

      <!-- 15. Dashboard Layout -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">15. Dashboard Layout</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Real-world grid layout resembling a dashboard.</p>
          <div class="grid grid-cols-4 grid-rows-3 gap-3" :style="{ height: '300px' }">
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-4 bg-slate-800 text-white font-bold text-base">Dashboard Header</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-1 row-span-2 bg-slate-700 text-white flex-col gap-2">
              <div class="text-xs opacity-70">Menu</div>
              <div>Nav</div>
            </div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-blue-500 text-white flex-col">
              <div class="text-xs opacity-80">Revenue</div>
              <div class="text-lg font-bold">$12,450</div>
            </div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-emerald-500 text-white flex-col">
              <div class="text-xs opacity-80">Users</div>
              <div class="text-lg font-bold">1,234</div>
            </div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 col-span-2 bg-amber-100 border border-amber-300 text-amber-800">Chart Area</div>
            <div class="flex items-center justify-center rounded-lg text-sm font-semibold p-3 bg-purple-100 border border-purple-300 text-purple-800">Activity</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">grid-cols-4 grid-rows-3 + col-span + row-span</span>
        </div>
      </div>

      <!-- 16. Photo Gallery -->
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">16. Photo Gallery Grid</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600">Masonry-like gallery with span variations.</p>
          <div class="grid grid-cols-3 gap-2">
            <div class="col-span-2 row-span-2 bg-gradient-to-br from-sky-400 to-blue-500 rounded-lg flex items-center justify-center text-white font-bold text-lg" :style="{ minHeight: '140px' }">Featured</div>
            <div class="bg-gradient-to-br from-pink-400 to-rose-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" :style="{ minHeight: '65px' }">Photo 2</div>
            <div class="bg-gradient-to-br from-amber-400 to-orange-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" :style="{ minHeight: '65px' }">Photo 3</div>
            <div class="bg-gradient-to-br from-emerald-400 to-green-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" :style="{ minHeight: '65px' }">Photo 4</div>
            <div class="bg-gradient-to-br from-violet-400 to-purple-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" :style="{ minHeight: '65px' }">Photo 5</div>
            <div class="bg-gradient-to-br from-cyan-400 to-teal-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" :style="{ minHeight: '65px' }">Photo 6</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">col-span-2 row-span-2 for featured item</span>
        </div>
      </div>

    </webf-list-view>
  </div>
</template>
