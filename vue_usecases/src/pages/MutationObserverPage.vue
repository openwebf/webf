<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue';

type MutationLog = {
  id: string;
  timestamp: string;
  type: string;
  target: string;
  details: string;
};

const mutations = ref<MutationLog[]>([]);
const todoItems = ref<string[]>(['Learn ResizeObserver', 'Master MutationObserver']);
const currentInput = ref('');
const attributeColor = ref('#2196F3');
const isLogCollapsed = ref(false);

const attributeTargetRef = ref<HTMLElement | null>(null);
const childListTargetRef = ref<HTMLElement | null>(null);
const subtreeTargetRef = ref<HTMLElement | null>(null);

let mutationObserver: MutationObserver | null = null;

function pushMutations(list: MutationRecord[]) {
  const next: MutationLog[] = [];
  list.forEach((mutation, index) => {
    const timestamp = new Date().toLocaleTimeString();
    const node = mutation.target as Node;
    const element = mutation.target instanceof Element ? mutation.target : null;
    const target = node.nodeName + (element?.className ? `.${element.className}` : '');

    let details = '';
    if (mutation.type === 'attributes') {
      const attrName = mutation.attributeName ?? '';
      const attrValue = element?.getAttribute(attrName) ?? '';
      details = `${attrName}: "${attrValue}"`;
    } else if (mutation.type === 'childList') {
      const added = mutation.addedNodes.length;
      const removed = mutation.removedNodes.length;
      details = `+${added} -${removed} nodes`;
    }

    next.push({
      id: `${Date.now()}-${index}`,
      timestamp,
      type: mutation.type,
      target,
      details,
    });
  });

  mutations.value = [...next, ...mutations.value].slice(0, 50);
}

onMounted(() => {
  mutationObserver = new MutationObserver(pushMutations);

  const elements: Array<{ element: HTMLElement | null; config: MutationObserverInit }> = [
    { element: attributeTargetRef.value, config: { attributes: true, attributeOldValue: true } },
    { element: childListTargetRef.value, config: { childList: true } },
    { element: subtreeTargetRef.value, config: { childList: true, attributes: true, subtree: true } },
  ];

  elements.forEach(({ element, config }) => {
    if (element) mutationObserver?.observe(element, config);
  });
});

onBeforeUnmount(() => {
  mutationObserver?.disconnect();
  mutationObserver = null;
});

function addTodoItem() {
  const v = currentInput.value.trim();
  if (!v) return;
  todoItems.value = [...todoItems.value, v];
  currentInput.value = '';
}

function removeTodoItem(index: number) {
  todoItems.value = todoItems.value.filter((_, i) => i !== index);
}

function changeAttributeColor() {
  const colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0'];
  const currentIndex = colors.indexOf(attributeColor.value);
  attributeColor.value = colors[(currentIndex + 1) % colors.length] ?? colors[0] ?? '#2196F3';
}

function addRandomElement() {
  const element = document.createElement('div');
  element.textContent = `Dynamic element ${Date.now()}`;
  element.className = 'dynamic-element px-3 py-2 bg-gradient-to-tr from-indigo-500 to-purple-600 text-white rounded text-xs font-medium mr-2 mb-2';
  subtreeTargetRef.value?.appendChild(element);
}

function clearDynamicElements() {
  const dynamicElements = subtreeTargetRef.value?.querySelectorAll('.dynamic-element');
  dynamicElements?.forEach((el) => el.remove());
}

function clearMutations() {
  mutations.value = [];
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6 pb-40">
      <div class="flex flex-col gap-6">
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Attribute Mutations</div>
          <div class="text-sm text-fg-secondary mb-3">Observer tracks changes to element attributes</div>
          <div
            ref="attributeTargetRef"
            class="w-full h-30 h-[120px] rounded flex items-center justify-center mb-4 transition-colors"
            :style="{ backgroundColor: attributeColor }"
          >
            <div class="text-white text-lg font-semibold drop-shadow">Background Color: {{ attributeColor }}</div>
          </div>
          <div class="flex gap-2 flex-wrap items-center">
            <button class="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700" @click="changeAttributeColor">Change Color</button>
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Child List Mutations</div>
          <div class="text-sm text-fg-secondary mb-3">Observer tracks addition and removal of child elements</div>
          <div ref="childListTargetRef" class="min-h-[120px] border-2 border-dashed border-line rounded p-4 mb-3 bg-surface">
            <div
              v-for="(item, index) in todoItems"
              :key="index"
              class="flex items-center justify-between p-3 mb-2 bg-white rounded border border-line hover:border-sky-600 hover:-translate-y-px hover:shadow transition"
            >
              <span class="flex-1 text-sm text-fg-primary">{{ item }}</span>
              <button class="w-6 h-6 rounded-full bg-red-500 text-white flex items-center justify-center" @click="removeTodoItem(index)">×</button>
            </div>
          </div>
          <div class="flex gap-2 flex-wrap items-center">
            <input
              v-model="currentInput"
              type="text"
              placeholder="Add new todo"
              class="flex-1 min-w-[220px] rounded border-2 border-line px-3 py-2 bg-surface focus:border-sky-600 outline-none"
              @keydown.enter="addTodoItem"
            />
            <button class="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700" @click="addTodoItem">Add Item</button>
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-3">
          <div class="text-lg font-medium text-fg-primary">Subtree Mutations</div>
          <div class="text-sm text-fg-secondary mb-3">Observer tracks changes throughout the entire subtree</div>
          <div ref="subtreeTargetRef" class="min-h-[120px] border-2 border-line rounded p-4 mb-3 bg-surface">
            <div class="text-fg-primary font-medium mb-2 pb-2 border-b border-line">Subtree Container</div>
            <div class="flex flex-wrap" />
          </div>
          <div class="flex gap-2 flex-wrap items-center">
            <button class="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700" @click="addRandomElement">Add Element</button>
            <button class="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700" @click="clearDynamicElements">Clear All</button>
          </div>
        </div>
      </div>
    </webf-list-view>

    <div class="fixed bottom-0 left-0 right-0 z-50">
      <div class="max-w-4xl mx-auto px-3 md:px-6">
        <div class="bg-surface-secondary border border-line rounded-t-xl shadow-xl">
          <div class="flex items-center justify-between p-3">
            <div class="text-lg font-medium text-fg-primary">Mutations Log</div>
            <div class="flex items-center gap-2">
              <button class="px-3 py-1.5 rounded bg-black text-white hover:bg-neutral-700 text-sm" @click="clearMutations">Clear</button>
              <button
                class="px-3 py-1.5 rounded border border-line bg-white hover:bg-neutral-50 text-sm"
                :aria-expanded="!isLogCollapsed"
                aria-controls="mutations-log-panel"
                @click="isLogCollapsed = !isLogCollapsed"
              >
                {{ isLogCollapsed ? 'Expand' : 'Fold' }}
              </button>
            </div>
          </div>
          <div
            id="mutations-log-panel"
            class="border-t border-line rounded-b-xl overflow-hidden transition-all duration-300 ease-in-out"
            :class="isLogCollapsed ? 'max-h-0 opacity-0' : 'max-h-[24vh] opacity-100'"
          >
            <div class="bg-surface p-4 overflow-y-auto max-h-[24vh]">
              <div v-for="mutation in mutations" :key="mutation.id" class="p-3 mb-2 bg-white rounded border">
                <div class="flex items-center justify-between mb-1">
                  <span
                    class="px-2 py-1 rounded text-xs font-semibold uppercase tracking-wide"
                    :class="
                      mutation.type === 'attributes'
                        ? 'bg-blue-100 text-blue-700'
                        : mutation.type === 'childList'
                          ? 'bg-green-100 text-green-700'
                          : 'bg-amber-100 text-amber-600'
                    "
                  >
                    {{ mutation.type }}
                  </span>
                  <span class="text-xs text-fg-secondary font-mono">{{ mutation.timestamp }}</span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-sm font-medium font-mono text-fg-primary">{{ mutation.target }}</span>
                  <span class="text-sm italic text-fg-secondary">{{ mutation.details }}</span>
                </div>
              </div>

              <div v-if="mutations.length === 0" class="text-center text-fg-secondary italic py-10">Interact with elements above to see mutations...</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
