<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue';

const labels: string[] = ['IPSUM', 'DOLOR', 'LOREM', 'SIT', 'AMET', 'CONSECTRTUR', 'ADIPISICING', 'ELIT'];

const itemsCount = labels.length;

const itemGap = ref(Math.round(((typeof window !== 'undefined' ? window.innerWidth : 750) * 110) / 750));
const order = ref<number[]>(Array.from({ length: itemsCount }, (_, i) => i));

const mouseY = ref(0);
const isPressed = ref(false);
const originalPosOfLastPressed = ref(0);

const topDeltaY = ref(0);

function clamp(n: number, min: number, max: number) {
  return Math.max(Math.min(n, max), min);
}

function reinsert<T>(arr: T[], from: number, to: number): T[] {
  const _arr = arr.slice(0);
  const val = _arr[from]!;
  _arr.splice(from, 1);
  _arr.splice(to, 0, val);
  return _arr;
}

function onResize() {
  itemGap.value = Math.round((window.innerWidth * 110) / 750);
}

function onTouchMove(touch: Touch) {
  if (!isPressed.value) return;
  const pageY = touch.pageY;
  const mouseYVal = pageY - topDeltaY.value;
  const currentRow = clamp(Math.round(mouseYVal / itemGap.value), 0, itemsCount - 1);
  const fromIndex = order.value.indexOf(originalPosOfLastPressed.value);
  if (currentRow !== fromIndex) {
    order.value = reinsert(order.value, fromIndex, currentRow);
  }
  mouseY.value = mouseYVal;
}

function onTouchEnd() {
  isPressed.value = false;
  topDeltaY.value = 0;
}

function onTouchStart(pos: number, pressY: number, pageY: number) {
  topDeltaY.value = pageY - pressY;
  mouseY.value = pressY;
  isPressed.value = true;
  originalPosOfLastPressed.value = pos;
}

const itemHeight = computed(() => Math.round(itemGap.value * (80 / 110)));
const containerHeight = computed(() => (itemsCount - 1) * itemGap.value + itemHeight.value);

function itemColor(i: number) {
  return i % 4 === 0 ? '#6c5ce7' : i % 4 === 1 ? '#0984e3' : i % 4 === 2 ? '#00b894' : '#fdcb6e';
}

function itemTextColor(i: number) {
  return i % 4 === 3 ? '#222' : '#fff';
}

function itemY(i: number) {
  const isActive = originalPosOfLastPressed.value === i && isPressed.value;
  return isActive ? mouseY.value : order.value.indexOf(i) * itemGap.value;
}

function itemScale(i: number) {
  const isActive = originalPosOfLastPressed.value === i && isPressed.value;
  return isActive ? 1.1 : 1;
}

function itemZIndex(i: number) {
  return i === originalPosOfLastPressed.value ? 99 : i;
}

function itemTransition(i: number) {
  const isActive = originalPosOfLastPressed.value === i && isPressed.value;
  return isActive ? 'none' : 'transform 200ms cubic-bezier(0.23, 1, 0.32, 1)';
}

onMounted(() => window.addEventListener('resize', onResize));
onUnmounted(() => window.removeEventListener('resize', onResize));
</script>

<template>
  <div
    class="dragable-list-demo"
    :style="{
      position: 'relative',
      margin: 0,
      width: '100vw',
      height: `${containerHeight}px`,
      touchAction: 'none',
      userSelect: 'none',
      paddingTop: '24px',
      backgroundColor: 'var(--background-color)',
    }"
  >
    <webf-toucharea
      v-for="i in itemsCount"
      :key="i - 1"
      class="dragable-item"
      :style="{
        position: 'absolute',
        left: '10vw',
        width: '80vw',
        height: 'calc(10.6667vw)',
        padding: '0 16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        boxSizing: 'border-box',
        borderRadius: '13px',
        color: itemTextColor(i - 1),
        willChange: 'transform',
        transformOrigin: '40vw 45px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1), 0 10px 20px rgba(0,0,0,0.15)',
        transform: `translate3d(0px, ${itemY(i - 1)}px, 0px) scale(${itemScale(i - 1)})`,
        zIndex: itemZIndex(i - 1),
        transition: itemTransition(i - 1),
        backgroundColor: itemColor(i - 1),
      }"
      @touchstart="(e: TouchEvent) => onTouchStart(i - 1, itemY(i - 1), e.touches[0]?.pageY ?? 0)"
      @touchmove="(e: TouchEvent) => onTouchMove(e.touches[0] as Touch)"
      @touchend="onTouchEnd"
      @touchcancel="onTouchEnd"
    >
      <div
        :style="{
          pointerEvents: 'none',
          position: 'relative',
          width: '100%',
          display: 'flex',
          alignItems: 'center',
        }"
      >
        <span :style="{ fontWeight: 600, letterSpacing: '0.5px', color: itemTextColor(i - 1) }">
          Items {{ i }}. {{ labels[i - 1] }}
        </span>
      </div>

      <div
        :style="{
          position: 'absolute',
          right: '16px',
          top: '50%',
          transform: 'translateY(-50%)',
          display: 'flex',
          flexDirection: 'column',
        }"
      >
        <div v-for="n in 3" :key="n" :style="{ width: '10px', height: '2px', marginBottom: '2px', backgroundColor: '#ffffff' }" />
      </div>
    </webf-toucharea>
  </div>
</template>
