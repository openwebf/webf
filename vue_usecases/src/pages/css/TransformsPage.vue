<script setup lang="ts">
type TransformCase = { label: string; transform: string; origin?: string };

const translateCases: TransformCase[] = [
  { label: 'translateX(20px)', transform: 'translateX(20px)' },
  { label: 'translateY(20px)', transform: 'translateY(20px)' },
  { label: 'translate(10px, 10px)', transform: 'translate(10px, 10px)' },
  { label: 'translate(50%, -50%)', transform: 'translate(50%, -50%)' },
];

const scaleCases: TransformCase[] = [
  { label: 'scale(1.2)', transform: 'scale(1.2)' },
  { label: 'scaleX(1.5)', transform: 'scaleX(1.5)' },
  { label: 'scaleY(0.6)', transform: 'scaleY(0.6)' },
  { label: 'scale(-1, 1) (flip X)', transform: 'scale(-1, 1)' },
];

const rotateCases: TransformCase[] = [
  { label: 'rotate(15deg)', transform: 'rotate(15deg)' },
  { label: 'rotate(-30deg)', transform: 'rotate(-30deg)' },
  { label: 'rotateZ(45deg)', transform: 'rotateZ(45deg)' },
];

const skewCases: TransformCase[] = [
  { label: 'skewX(10deg)', transform: 'skewX(10deg)' },
  { label: 'skewY(10deg)', transform: 'skewY(10deg)' },
  { label: 'skew(10deg, 5deg)', transform: 'skew(10deg, 5deg)' },
];

const originCases: (Required<Pick<TransformCase, 'label' | 'transform'>> & { origin: string })[] = [
  { label: 'rotate(25deg) origin center', transform: 'rotate(25deg)', origin: 'center' },
  { label: 'rotate(25deg) origin top left', transform: 'rotate(25deg)', origin: 'top left' },
  { label: 'rotate(25deg) origin bottom right', transform: 'rotate(25deg)', origin: 'bottom right' },
  { label: 'scale(1.2) origin left', transform: 'scale(1.2)', origin: 'left' },
];

const orderMatters: TransformCase[] = [
  { label: 'translate(40px,0) rotate(30deg)', transform: 'translate(40px, 0) rotate(30deg)' },
  { label: 'rotate(30deg) translate(40px,0)', transform: 'rotate(30deg) translate(40px, 0)' },
];

const matrixCases: TransformCase[] = [
  { label: 'matrix(1, 0.2, -0.2, 1, 10, 0)', transform: 'matrix(1, 0.2, -0.2, 1, 10, 0)' },
  { label: 'matrix(0.866, 0.5, -0.5, 0.866, 0, 0)', transform: 'matrix(0.866, 0.5, -0.5, 0.866, 0, 0)' },
];

const threeD: TransformCase[] = [
  { label: 'rotateX(30deg)', transform: 'rotateX(30deg)' },
  { label: 'rotateY(30deg)', transform: 'rotateY(30deg)' },
  { label: 'translateZ(40px)', transform: 'translateZ(40px)' },
];

const combined: TransformCase[] = [
  { label: 'translate + scale + rotate', transform: 'translate(10px, 10px) scale(0.9) rotate(10deg)' },
  { label: 'skew + rotate + scale', transform: 'skew(8deg, 5deg) rotate(15deg) scale(1.1)' },
];
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
          <h1 class="text-[22px] font-bold mb-1 drop-shadow">Transforms</h1>
          <p class="text-[14px]/[1.5] opacity-90">Translate, scale, rotate, skew, origin, matrix and 3D</p>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Translate</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in translateCases" :key="`t-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div
              class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center"
              :style="{ transform: o.transform }"
            >
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Scale</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in scaleCases" :key="`s-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div
              class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center"
              :style="{ transform: o.transform, transformOrigin: o.origin }"
            >
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Rotate</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in rotateCases" :key="`r-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" :style="{ transform: o.transform }">
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Skew</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in skewCases" :key="`k-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" :style="{ transform: o.transform }">
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Transform origin</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in originCases" :key="`o-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div
              class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center"
              :style="{ transform: o.transform, transformOrigin: o.origin }"
            >
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Order matters</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in orderMatters" :key="`om-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" :style="{ transform: o.transform }">
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Matrix</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in matrixCases" :key="`m-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" :style="{ transform: o.transform }">
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">3D (with perspective)</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in threeD" :key="`3d-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div
            class="mt-2 mb-4 w-[160px] h-[160px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center"
            :style="{ perspective: '600px' }"
          >
            <div class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" :style="{ transform: o.transform }">
              Box
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Combined</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in combined" :key="`c-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center">
            <div class="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" :style="{ transform: o.transform }">
              Box
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
