<script setup lang="ts">
import { ref } from 'vue';

const wrapDemoHeight = ref<'auto' | '50%'>('auto');

function demoItemBase(variant: 'base' | 'alt1' | 'alt2' | 'alt3' | 'alt4' = 'base') {
  const base = 'flex items-center justify-center text-xs font-medium rounded-md border';
  if (variant === 'alt1') return `${base} bg-yellow-200 border-yellow-300 text-gray-900`;
  if (variant === 'alt2') return `${base} bg-red-200 border-red-300 text-gray-900`;
  if (variant === 'alt3') return `${base} bg-green-200 border-green-300 text-gray-900`;
  if (variant === 'alt4') return `${base} bg-purple-200 border-purple-300 text-gray-900`;
  return `${base} bg-blue-100 border-blue-200 text-gray-900`;
}

const demoNumbers = Array.from({ length: 8 }, (_, i) => i + 1);
const demoSix = Array.from({ length: 6 }, (_, i) => i + 1);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <div class="flex flex-row flex-wrap items-center gap-y-5 bg-[#f4f4f4] p-5 font-bold rounded-xl border border-line">
        <div class="text-[34px] font-black text-center w-full border-y-[5px] border-x-0 border-solid border-y-green-500 border-x-red-500 py-2">
          Flex layout
        </div>
        <div class="bg-sky-400 flex-[1_100%] p-2.5 text-center">
          The flexible box layout module (usually referred to as flexbox) is a one-dimensional layout model for
          distributing space between items and includes numerous alignment capabilities. This article gives an outline
          of the main features of flexbox, which we will explore in more detail in the rest of these guides.
        </div>
        <div class="bg-yellow-400 flex-[1_0_0] p-2.5 text-center">flex: 1 0 0</div>
        <div class="bg-pink-400 flex-[2_0_0] p-2.5 text-center">flex: 2 0 0</div>
        <div class="bg-green-300 flex-[1_100%] p-2.5 text-center">Footer -- flex: 1 100%</div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Verified Behaviors (from integration tests)</h2>
        <ul class="list-disc pl-5 text-sm text-fg-secondary space-y-1">
          <li>Parent containers with <code>display: flex</code> lay out children correctly.</li>
          <li>Row/column direction via <code>flex-direction</code> are supported.</li>
          <li><code>align-items: stretch</code> stretches auto-height children on the cross-axis.</li>
          <li>Percentage heights resolve inside flex containers (row and column).</li>
          <li>Late style changes (e.g., setting <code>height: 50%</code> after mount) update layout.</li>
          <li>Nesting flex containers computes constraints correctly with padding and borders.</li>
        </ul>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Column Flex Container</h3>
        <div
          :style="{
            width: '300px',
            height: '200px',
            padding: '10px',
            margin: '15px',
            border: '5px solid black',
            display: 'flex',
            flexDirection: 'column',
            background: '#fafafa',
          }"
        >
          <div :style="{ width: '100%', background: 'lightblue', padding: '10px' }">Text inside flex container</div>
        </div>
        <div class="mt-2 text-xs text-fg-secondary">
          Matches test setup: 300×200 container with padding, margin, border, column flow.
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Nested Flex Containers</h3>
        <div
          :style="{
            width: '400px',
            height: '300px',
            padding: '20px',
            border: '5px solid black',
            display: 'flex',
            background: '#fff',
          }"
        >
          <div
            :style="{
              width: '80%',
              padding: '15px',
              border: '3px solid red',
              display: 'flex',
              background: '#fff',
            }"
          >
            <div :style="{ background: 'lightgreen', padding: '10px' }">Deeply nested text widget</div>
          </div>
        </div>
        <div class="mt-2 text-xs text-fg-secondary">
          Matches test setup: parent(400×300, padding/border) → child(80% width, padding/border) → content.
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Align Items: Stretch (Row)</h3>
        <div
          :style="{
            width: '200px',
            height: '200px',
            display: 'flex',
            background: '#666',
            flexDirection: 'row',
            alignItems: 'stretch',
            gap: '6px',
            padding: '4px',
          }"
        >
          <div
            :style="{
              width: '50px',
              background: 'blue',
              color: '#fff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '12px',
            }"
          >
            no height
          </div>
          <div :style="{ width: '50px', height: '100px', background: 'red' }" />
          <div :style="{ width: '50px', height: '50px', background: 'green' }" />
        </div>
        <div class="mt-2 text-xs text-fg-secondary">
          Matches test: parent flex row with align-items: stretch; first child grows to container cross-axis.
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Percentage Heights (Row)</h3>
        <div :style="{ display: 'flex', width: '200px', height: '200px', background: 'green', position: 'relative', gap: '6px', padding: '4px' }">
          <div :style="{ height: '50%', width: '100px', background: 'yellow' }" />
          <div :style="{ height: '50%', width: '100%', background: 'blue', display: 'flex' }">
            <div :style="{ height: '100%', width: '100px', background: 'red' }" />
          </div>
        </div>
        <div class="mt-2 text-xs text-fg-secondary">Verified: percent heights resolve against flex container size (row direction).</div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Percentage Heights (Column)</h3>
        <div
          :style="{
            display: 'flex',
            flexDirection: 'column',
            width: '200px',
            height: '200px',
            background: 'green',
            position: 'relative',
            gap: '6px',
            padding: '4px',
          }"
        >
          <div :style="{ height: '50%', width: '100px', background: 'yellow' }" />
          <div :style="{ height: '50%', width: '100%', background: 'blue', display: 'flex' }">
            <div :style="{ height: '100%', width: '100px', background: 'red' }" />
          </div>
        </div>
        <div class="mt-2 text-xs text-fg-secondary">Verified: percent heights resolve with column direction as well.</div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Flex Wrap + Late Percentage Height</h3>
        <div :style="{ display: 'flex', flexWrap: 'wrap', width: '200px', height: '200px', background: 'green', position: 'relative', padding: '4px', gap: '6px' }">
          <div :style="{ width: '100px', height: wrapDemoHeight, background: 'yellow' }" />
        </div>
        <div class="mt-2 text-xs text-fg-secondary">Test parity: setting child height to 50% after mount updates layout.</div>
        <button class="mt-2 rounded-md border border-line bg-black/80 px-3 py-2 text-xs text-white hover:bg-black/70" @click="wrapDemoHeight = '50%'">
          Set height to 50%
        </button>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Justify/Align Center (Row)</h3>
        <div
          :style="{
            width: '100%',
            height: '100px',
            border: '1px solid #000',
            background: '#fff',
            display: 'flex',
            flexDirection: 'row',
            justifyContent: 'center',
            alignItems: 'center',
            gap: '12px',
          }"
        >
          <div :style="{ width: '120px', height: '40px', background: '#0ea5e9' }" />
          <div :style="{ width: '120px', height: '40px', background: '#f97316' }" />
        </div>
        <div class="mt-2 text-xs text-fg-secondary">Based on test: custom elements read flex styles with center alignment.</div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Inline Flex</h3>
        <div class="text-xs text-fg-secondary mb-2">Inline-level flex containers participate in inline flow.</div>
        <div class="flex items-center flex-wrap gap-2">
          <span class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'inline-flex', gap: '6px', padding: '6px', marginRight: '8px' }">
            <span :class="demoItemBase('base')" :style="{ width: '40px', height: '30px' }">A</span>
            <span :class="demoItemBase('alt1')" :style="{ width: '40px', height: '30px' }">B</span>
          </span>
          <span class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'inline-flex', gap: '6px', padding: '6px' }">
            <span :class="demoItemBase('alt2')" :style="{ width: '40px', height: '30px' }">C</span>
            <span :class="demoItemBase('alt3')" :style="{ width: '40px', height: '30px' }">D</span>
          </span>
          <span class="text-xs text-fg-secondary">Text flows around inline flex containers.</span>
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Flex Grow/Shrink</h3>
        <div class="text-sm font-semibold text-fg-secondary mb-2">Shrink within constrained width</div>
        <div class="overflow-x-auto">
          <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', width: '320px', gap: '8px' }">
            <div :class="demoItemBase('base')" :style="{ width: '200px', flexShrink: 1, height: '36px' }">shrink:1, w200</div>
            <div :class="demoItemBase('alt1')" :style="{ width: '200px', flexShrink: 1, height: '36px' }">shrink:1, w200</div>
          </div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">Grow to fill leftover space</div>
        <div class="overflow-x-auto">
          <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', width: '420px', gap: '8px' }">
            <div :class="demoItemBase('base')" :style="{ flex: 1, minWidth: '60px', height: '36px' }">flex:1</div>
            <div :class="demoItemBase('alt2')" :style="{ flex: 2, minWidth: '60px', height: '36px' }">flex:2</div>
            <div :class="demoItemBase('alt3')" :style="{ flex: 3, minWidth: '60px', height: '36px' }">flex:3</div>
          </div>
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">justify-content Variants</h3>
        <div class="text-sm font-semibold text-fg-secondary mb-2">space-between</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', justifyContent: 'space-between', gap: 0 }">
          <div :class="demoItemBase('base')" :style="{ width: '60px', height: '30px' }">A</div>
          <div :class="demoItemBase('alt1')" :style="{ width: '60px', height: '30px' }">B</div>
          <div :class="demoItemBase('alt2')" :style="{ width: '60px', height: '30px' }">C</div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">space-around</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', justifyContent: 'space-around' }">
          <div :class="demoItemBase('base')" :style="{ width: '60px', height: '30px' }">A</div>
          <div :class="demoItemBase('alt1')" :style="{ width: '60px', height: '30px' }">B</div>
          <div :class="demoItemBase('alt2')" :style="{ width: '60px', height: '30px' }">C</div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">space-evenly</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', justifyContent: 'space-evenly' }">
          <div :class="demoItemBase('base')" :style="{ width: '60px', height: '30px' }">A</div>
          <div :class="demoItemBase('alt1')" :style="{ width: '60px', height: '30px' }">B</div>
          <div :class="demoItemBase('alt2')" :style="{ width: '60px', height: '30px' }">C</div>
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">align-content (with wrap)</h3>
        <div class="text-sm font-semibold text-fg-secondary mb-2">start</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', flexWrap: 'wrap', alignContent: 'flex-start', height: '120px', gap: '6px' }">
          <div v-for="n in demoNumbers" :key="`ac-start-${n}`" :class="demoItemBase('base')" :style="{ width: '60px', height: '30px' }">
            {{ n }}
          </div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">center</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', flexWrap: 'wrap', alignContent: 'center', height: '120px', gap: '6px' }">
          <div
            v-for="n in demoNumbers"
            :key="`ac-center-${n}`"
            :class="demoItemBase(n % 2 === 0 ? 'alt1' : 'base')"
            :style="{ width: '60px', height: '30px' }"
          >
            {{ n }}
          </div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">space-between</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', flexWrap: 'wrap', alignContent: 'space-between', height: '120px', gap: '6px' }">
          <div
            v-for="n in demoNumbers"
            :key="`ac-between-${n}`"
            :class="demoItemBase(n % 3 === 1 ? 'alt2' : 'base')"
            :style="{ width: '60px', height: '30px' }"
          >
            {{ n }}
          </div>
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">align-self</h3>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', alignItems: 'flex-start', height: '100px', gap: '8px' }">
          <div :class="demoItemBase('base')" :style="{ width: '60px', height: '30px' }">start (inherited)</div>
          <div :class="demoItemBase('alt1')" :style="{ width: '60px', height: '30px', alignSelf: 'center' }">center</div>
          <div :class="demoItemBase('alt2')" :style="{ width: '60px', height: '30px', alignSelf: 'flex-end' }">end</div>
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">order</h3>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', gap: '8px' }">
          <div :class="demoItemBase('base')" :style="{ width: '60px', height: '30px', order: 3 }">1 (3)</div>
          <div :class="demoItemBase('alt1')" :style="{ width: '60px', height: '30px', order: 1 }">2 (1)</div>
          <div :class="demoItemBase('alt2')" :style="{ width: '60px', height: '30px', order: 2 }">3 (2)</div>
        </div>
        <div class="mt-2 text-xs text-fg-secondary">Numbers in parentheses are the applied order values.</div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">flex-basis</h3>
        <div class="overflow-x-auto">
          <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', width: '520px', gap: '8px' }">
            <div :class="demoItemBase('base')" :style="{ flex: '0 0 100px', height: '36px' }">basis 100</div>
            <div :class="demoItemBase('alt1')" :style="{ flex: '0 0 150px', height: '36px' }">basis 150</div>
            <div :class="demoItemBase('alt2')" :style="{ flex: '0 0 200px', height: '36px' }">basis 200</div>
          </div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">basis + grow</div>
        <div class="overflow-x-auto">
          <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', width: '520px', gap: '8px' }">
            <div :class="demoItemBase('base')" :style="{ flex: '1 1 100px', height: '36px' }">1 1 100</div>
            <div :class="demoItemBase('alt1')" :style="{ flex: '2 1 100px', height: '36px' }">2 1 100</div>
            <div :class="demoItemBase('alt2')" :style="{ flex: '3 1 100px', height: '36px' }">3 1 100</div>
          </div>
        </div>
      </div>

      <div class="mt-5 rounded-xl bg-surface-secondary border border-line p-4">
        <h3 class="text-base font-semibold text-fg-primary mb-3">Gaps (gap, row-gap, column-gap)</h3>
        <div class="text-sm font-semibold text-fg-secondary mb-2">gap: 12px</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', flexWrap: 'wrap', gap: '12px', width: '320px' }">
          <div v-for="n in demoSix" :key="`gap-${n}`" :class="demoItemBase('base')" :style="{ width: '80px', height: '30px' }">
            {{ n }}
          </div>
        </div>
        <div class="text-sm font-semibold text-fg-secondary mt-3 mb-2">row-gap: 16px; column-gap: 6px</div>
        <div class="border border-line bg-surface rounded-lg p-2" :style="{ display: 'flex', flexWrap: 'wrap', rowGap: '16px', columnGap: '6px', width: '320px' }">
          <div
            v-for="n in demoSix"
            :key="`rg-${n}`"
            :class="demoItemBase(n % 2 === 0 ? 'alt1' : 'base')"
            :style="{ width: '80px', height: '30px' }"
          >
            {{ n }}
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
