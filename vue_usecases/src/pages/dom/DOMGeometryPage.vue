<script setup lang="ts">
import { computed, ref } from 'vue';

const support =
  typeof (globalThis as any).DOMMatrix !== 'undefined' && typeof (globalThis as any).DOMPoint !== 'undefined';

const tx = ref(10);
const ty = ref(20);
const sx = ref(1.25);
const sy = ref(1.25);
const deg = ref(15);
const px = ref(10);
const py = ref(20);

const geom = computed(() => {
  if (!support) return null;
  try {
    const M = (globalThis as any).DOMMatrix;
    const P = (globalThis as any).DOMPoint;
    const m = new M().translate(tx.value, ty.value).scale(sx.value, sy.value).rotate(0, 0, deg.value);
    const p = new P(px.value, py.value);
    const p2 = p.matrixTransform(m);
    const inv = m.inverse();
    const back = new P(p2.x, p2.y).matrixTransform(inv);
    return {
      matrix: m,
      matrix2d: { a: m.a, b: m.b, c: m.c, d: m.d, e: m.e, f: m.f },
      is2D: (m as any).is2D,
      isIdentity: (m as any).isIdentity,
      point: { x: p.x, y: p.y },
      transformed: { x: p2.x, y: p2.y },
      roundTrip: { x: back.x, y: back.y },
      css: `translate(${tx.value}px, ${ty.value}px) scale(${sx.value}, ${sy.value}) rotate(${deg.value}deg)`,
    };
  } catch {
    return null;
  }
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">DOMMatrix / DOMPoint</h1>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-medium text-fg-primary mb-2">Overview</div>
        <div v-if="!support" class="text-fg-secondary">DOMMatrix/DOMPoint not available in this environment.</div>
        <div v-else class="text-sm text-fg-secondary leading-relaxed">
          <p class="mb-2">
            <span class="font-semibold text-fg-primary">DOMPoint</span> represents a point in 2D/3D space.
            <span class="font-semibold text-fg-primary">DOMMatrix</span> represents an affine transform (translate, scale, rotate, etc.). Combine them to transform
            coordinates or elements.
          </p>
          <p>Below you can tweak a matrix and see: the raw matrix values, how a point is transformed, and the same transform applied to a demo element.</p>
        </div>
      </div>

      <div v-if="support && geom" class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-medium text-fg-primary mb-3">Interactive Matrix Builder</div>
        <div class="flex flex-col md:flex-row gap-4">
          <div class="flex-1 min-w-0">
            <div class="text-sm font-medium text-fg-primary mb-2">Transform Controls</div>
            <div class="space-y-3">
              <div class="flex items-center gap-3">
                <label class="text-xs text-fg-secondary w-24">Translate X</label>
                <input v-model.number="tx" type="range" min="-200" max="200" step="1" class="flex-1" />
                <input v-model.number="tx" type="number" class="w-20 rounded border border-line px-2 py-1 text-sm" />
              </div>
              <div class="flex items-center gap-3">
                <label class="text-xs text-fg-secondary w-24">Translate Y</label>
                <input v-model.number="ty" type="range" min="-200" max="200" step="1" class="flex-1" />
                <input v-model.number="ty" type="number" class="w-20 rounded border border-line px-2 py-1 text-sm" />
              </div>
              <div class="flex items-center gap-3">
                <label class="text-xs text-fg-secondary w-24">Scale X</label>
                <input v-model.number="sx" type="range" min="0.25" max="3" step="0.01" class="flex-1" />
                <input v-model.number="sx" type="number" step="0.01" class="w-20 rounded border border-line px-2 py-1 text-sm" />
              </div>
              <div class="flex items-center gap-3">
                <label class="text-xs text-fg-secondary w-24">Scale Y</label>
                <input v-model.number="sy" type="range" min="0.25" max="3" step="0.01" class="flex-1" />
                <input v-model.number="sy" type="number" step="0.01" class="w-20 rounded border border-line px-2 py-1 text-sm" />
              </div>
              <div class="flex items-center gap-3">
                <label class="text-xs text-fg-secondary w-24">Rotate (deg)</label>
                <input v-model.number="deg" type="range" min="-180" max="180" step="1" class="flex-1" />
                <input v-model.number="deg" type="number" class="w-20 rounded border border-line px-2 py-1 text-sm" />
              </div>
            </div>
          </div>

          <div class="flex-1 min-w-0">
            <div class="text-sm font-medium text-fg-primary mb-2">Matrix (2D components)</div>
            <div class="flex flex-wrap gap-2 text-sm font-mono">
              <div class="p-2 bg-white rounded border flex-1 min-w-[120px]">a: {{ geom.matrix2d.a.toFixed(4) }}</div>
              <div class="p-2 bg-white rounded border flex-1 min-w-[120px]">b: {{ geom.matrix2d.b.toFixed(4) }}</div>
              <div class="p-2 bg-white rounded border flex-1 min-w-[120px]">c: {{ geom.matrix2d.c.toFixed(4) }}</div>
              <div class="p-2 bg-white rounded border flex-1 min-w-[120px]">d: {{ geom.matrix2d.d.toFixed(4) }}</div>
              <div class="p-2 bg-white rounded border flex-1 min-w-[120px]">e: {{ geom.matrix2d.e.toFixed(4) }}</div>
              <div class="p-2 bg-white rounded border flex-1 min-w-[120px]">f: {{ geom.matrix2d.f.toFixed(4) }}</div>
            </div>
            <div class="flex gap-2 text-xs text-fg-secondary mt-2">
              <span class="px-2 py-1 bg-white rounded border">is2D: {{ String(geom.is2D) }}</span>
              <span class="px-2 py-1 bg-white rounded border">isIdentity: {{ String(geom.isIdentity) }}</span>
            </div>
          </div>
        </div>

        <div class="mt-4 flex flex-col md:flex-row gap-4">
          <div class="flex-1 min-w-0">
            <div class="text-sm font-medium text-fg-primary mb-2">Transform a Point</div>
            <div class="flex items-center gap-3 mb-3">
              <label class="text-xs text-fg-secondary w-24">Point (x, y)</label>
              <input v-model.number="px" type="number" class="w-20 rounded border border-line px-2 py-1 text-sm" />
              <input v-model.number="py" type="number" class="w-20 rounded border border-line px-2 py-1 text-sm" />
            </div>
            <pre class="font-mono text-xs bg-surface rounded border border-line p-2">{{ JSON.stringify({ from: geom.point, to: geom.transformed, inverseBack: geom.roundTrip }, null, 2) }}</pre>
          </div>

          <div class="flex-1 min-w-0">
            <div class="text-sm font-medium text-fg-primary mb-2">Apply to Element</div>
            <div class="relative h-40 border border-dashed border-line rounded bg-white overflow-hidden">
              <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 border-2 border-rose-500/40 rounded pointer-events-none" />
              <div
                class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 bg-gradient-to-tr from-indigo-500 to-purple-600 rounded shadow text-white flex items-center justify-center text-xs font-semibold"
                :style="{ transform: geom.css }"
              >
                transform
              </div>
            </div>
            <div class="text-xs text-fg-secondary mt-2 font-mono break-all">CSS: {{ geom.css }}</div>
          </div>
        </div>
      </div>

      <div v-if="support" class="bg-surface-secondary border border-line rounded-xl p-4">
        <div class="text-lg font-medium text-fg-primary mb-2">Common Recipes</div>
        <ul class="list-disc pl-5 text-sm text-fg-secondary space-y-2">
          <li><span class="font-semibold text-fg-primary">Compose transforms</span>: `new DOMMatrix().translate(x,y).scale(sx,sy).rotate(0,0,deg)`</li>
          <li><span class="font-semibold text-fg-primary">Transform a point</span>: `new DOMPoint(x,y).matrixTransform(matrix)`</li>
          <li><span class="font-semibold text-fg-primary">Invert a matrix</span>: `const inv = matrix.inverse();`</li>
          <li><span class="font-semibold text-fg-primary">Multiply matrices</span>: `m3 = m1.multiply(m2)` (apply `m2` then `m1`).</li>
          <li><span class="font-semibold text-fg-primary">From arrays/strings</span>: `DOMMatrix.fromFloat32Array(arr)` or `new DOMMatrix(cssMatrixString)`.</li>
        </ul>
      </div>
    </webf-list-view>
  </div>
</template>
