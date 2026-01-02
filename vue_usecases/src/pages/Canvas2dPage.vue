<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue';

type DrawFn = (ctx: CanvasRenderingContext2D) => void;

const isWebF = typeof (globalThis as any).webf !== 'undefined';

function createCanvasController(draw: DrawFn, animated = false) {
  const canvasRef = ref<HTMLCanvasElement | null>(null);
  let rafId = 0;

  function stop() {
    if (rafId) cancelAnimationFrame(rafId);
    rafId = 0;
  }

  function start(target: Event | HTMLCanvasElement | null) {
    stop();
    const canvasEl = (target instanceof Event ? (target.target as HTMLCanvasElement | null) : target) as
      | HTMLCanvasElement
      | null;
    if (!canvasEl) return;

    const ctx = canvasEl.getContext('2d');
    if (!ctx) return;

    const dpr = window.devicePixelRatio || 1;
    const rect = canvasEl.getBoundingClientRect();
    if (!rect.width || !rect.height) return;

    canvasEl.width = rect.width * dpr;
    canvasEl.height = rect.height * dpr;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.scale(dpr, dpr);

    if (animated) {
      const render = () => {
        ctx.clearRect(0, 0, canvasEl.width / dpr, canvasEl.height / dpr);
        draw(ctx);
        rafId = requestAnimationFrame(render);
      };
      render();
    } else {
      draw(ctx);
    }
  }

  function onAttached(event: Event) {
    start(event);
  }

  function onDetached() {
    stop();
  }

  onMounted(() => {
    if (isWebF) return;
    if (canvasRef.value) start(canvasRef.value);
  });

  onUnmounted(() => stop());

  return { canvasRef, onAttached, onDetached };
}

const cards = [
  {
    section: 'Basic Shapes & Styles',
    title: 'Rectangles (Fill & Stroke)',
    controller: createCanvasController((ctx) => {
      ctx.fillStyle = 'rgb(200, 0, 0)';
      ctx.fillRect(20, 20, 100, 100);

      ctx.fillStyle = 'rgba(0, 0, 200, 0.5)';
      ctx.fillRect(60, 60, 100, 100);

      ctx.strokeStyle = 'green';
      ctx.lineWidth = 5;
      ctx.strokeRect(100, 30, 80, 80);

      ctx.clearRect(80, 80, 40, 40);
    }),
  },
  {
    section: 'Basic Shapes & Styles',
    title: 'Paths (Lines & Arcs)',
    controller: createCanvasController((ctx) => {
      ctx.beginPath();
      ctx.moveTo(50, 50);
      ctx.lineTo(150, 50);
      ctx.lineTo(100, 150);
      ctx.closePath();
      ctx.fillStyle = '#FFCD56';
      ctx.fill();
      ctx.stroke();

      ctx.beginPath();
      ctx.arc(220, 80, 40, 0, Math.PI * 2, true);
      ctx.moveTo(255, 80);
      ctx.arc(220, 80, 35, 0, Math.PI, false);
      ctx.moveTo(210, 70);
      ctx.arc(205, 70, 5, 0, Math.PI * 2, true);
      ctx.moveTo(240, 70);
      ctx.arc(235, 70, 5, 0, Math.PI * 2, true);
      ctx.strokeStyle = '#36A2EB';
      ctx.stroke();
    }),
  },
  {
    section: 'Styles & Text',
    title: 'Gradients & Patterns',
    controller: createCanvasController((ctx) => {
      const lingrad = ctx.createLinearGradient(0, 0, 0, 150);
      lingrad.addColorStop(0, '#00ABEB');
      lingrad.addColorStop(0.5, '#fff');
      lingrad.addColorStop(0.5, '#26C000');
      lingrad.addColorStop(1, '#fff');
      ctx.fillStyle = lingrad;
      ctx.fillRect(10, 10, 130, 130);

      const radgrad = ctx.createRadialGradient(220, 75, 10, 220, 75, 60);
      radgrad.addColorStop(0, '#A7D30C');
      radgrad.addColorStop(0.9, '#019F62');
      radgrad.addColorStop(1, 'rgba(1, 159, 98, 0)');
      ctx.fillStyle = radgrad;
      ctx.fillRect(150, 0, 150, 150);
    }),
  },
  {
    section: 'Styles & Text',
    title: 'Text Rendering',
    controller: createCanvasController((ctx) => {
      ctx.font = '24px serif';
      ctx.fillStyle = 'black';
      ctx.fillText('Fill Text', 20, 50);

      ctx.font = 'bold 30px sans-serif';
      ctx.lineWidth = 1;
      ctx.strokeStyle = 'red';
      ctx.strokeText('Stroke Text', 20, 100);

      ctx.font = 'italic 20px monospace';
      ctx.fillStyle = 'blue';
      ctx.fillText('Monospace', 20, 140);
    }),
  },
  {
    section: 'Transformations',
    title: 'Rotate & Translate',
    controller: createCanvasController((ctx) => {
      ctx.save();
      ctx.translate(150, 100);

      for (let i = 0; i < 6; i++) {
        ctx.fillStyle = `rgba(${255 - 40 * i}, ${40 * i}, 255, 0.5)`;
        for (let j = 0; j < i * 6; j++) {
          ctx.rotate((Math.PI * 2) / (i * 6));
          ctx.beginPath();
          ctx.arc(0, i * 12.5, 5, 0, Math.PI * 2, true);
          ctx.fill();
        }
      }
      ctx.restore();
    }),
  },
  {
    section: 'Transformations',
    title: 'Scale',
    controller: createCanvasController((ctx) => {
      ctx.save();
      ctx.translate(20, 20);
      ctx.strokeStyle = 'purple';
      ctx.strokeRect(0, 0, 50, 50);

      ctx.scale(2, 2);
      ctx.strokeStyle = 'orange';
      ctx.strokeRect(0, 0, 50, 50);

      ctx.scale(1.5, 1.5);
      ctx.strokeStyle = 'green';
      ctx.strokeRect(0, 0, 50, 50);
      ctx.restore();
    }),
  },
  {
    section: 'Animation',
    title: 'Animated Solar System',
    controller: createCanvasController(
      (ctx) => {
        const time = new Date();
        ctx.clearRect(0, 0, 300, 200);

        ctx.save();
        ctx.translate(150, 100);

        ctx.beginPath();
        ctx.arc(0, 0, 20, 0, Math.PI * 2);
        ctx.fillStyle = 'yellow';
        ctx.fill();
        ctx.shadowBlur = 20;
        ctx.shadowColor = 'orange';
        ctx.stroke();

        ctx.strokeStyle = 'rgba(0, 153, 255, 0.4)';
        ctx.beginPath();
        ctx.arc(0, 0, 70, 0, Math.PI * 2);
        ctx.stroke();

        ctx.rotate(((2 * Math.PI) / 60) * time.getSeconds() + ((2 * Math.PI) / 60000) * time.getMilliseconds());
        ctx.translate(70, 0);
        ctx.beginPath();
        ctx.arc(0, 0, 10, 0, Math.PI * 2);
        ctx.fillStyle = 'blue';
        ctx.fill();

        ctx.strokeStyle = 'rgba(200, 200, 200, 0.4)';
        ctx.beginPath();
        ctx.arc(0, 0, 20, 0, Math.PI * 2);
        ctx.stroke();

        ctx.rotate(((2 * Math.PI) / 6) * time.getSeconds() + ((2 * Math.PI) / 6000) * time.getMilliseconds());
        ctx.translate(0, 20);
        ctx.beginPath();
        ctx.arc(0, 0, 4, 0, Math.PI * 2);
        ctx.fillStyle = 'gray';
        ctx.fill();

        ctx.restore();
      },
      true,
    ),
  },
] as const;

const sectionOrder = ['Basic Shapes & Styles', 'Styles & Text', 'Transformations', 'Animation'] as const;

function itemsForSection(section: (typeof sectionOrder)[number]) {
  return cards.filter((c) => c.section === section);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-gray-50">
    <webf-list-view class="w-full px-4 max-w-4xl mx-auto py-6 flex flex-col gap-4">
      <h1 class="text-2xl font-bold text-gray-900 mb-2">Canvas 2D Context</h1>
      <p class="text-gray-600 mb-4">The HTML &lt;canvas&gt; element is used to draw graphics, on the fly, via JavaScript.</p>

      <template v-for="section in sectionOrder" :key="section">
        <h2 class="text-lg font-bold text-gray-800 mt-6 mb-3 px-1 border-b border-gray-200 pb-2">{{ section }}</h2>
        <div class="flex flex-wrap justify-center gap-4">
          <div
            v-for="card in itemsForSection(section)"
            :key="`${section}:${card.title}`"
            class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-3"
          >
            <h3 class="text-sm font-semibold text-gray-700">{{ card.title }}</h3>
            <div class="w-full flex justify-center bg-gray-50 rounded border border-gray-100 overflow-hidden">
              <canvas
                :ref="(el) => (card.controller.canvasRef.value = el as HTMLCanvasElement | null)"
                style="width: 300px; height: 200px"
                class="w-[300px] h-[200px]"
                v-flutter-attached="{ onAttached: card.controller.onAttached, onDetached: card.controller.onDetached }"
              />
            </div>
          </div>
        </div>
      </template>
    </webf-list-view>
  </div>
</template>
