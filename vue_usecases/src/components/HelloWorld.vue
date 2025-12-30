<script setup lang="ts">
import { ref } from 'vue'

defineProps<{ msg: string }>()

const count = ref(0)
</script>

<template>
  <h1 class="text-5xl font-bold leading-tight">{{ msg }}</h1>

  <div class="p-8">
    <button
      type="button"
      @click="count++"
      class="rounded-lg border border-transparent px-5 py-2.5 text-base font-medium bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 cursor-pointer transition-colors hover:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-500/50"
    >
      count is {{ count }}
    </button>
    <p class="mt-4">
      Edit
      <code class="bg-gray-800 dark:bg-gray-200 px-2 py-1 text-white rounded text-sm">components/HelloWorld.vue</code> to test HMR
    </p>
  </div>

  <p class="mb-4">
    Check out
    <a
      href="https://vuejs.org/guide/quick-start.html#local"
      target="_blank"
      class="font-medium text-blue-600 dark:text-blue-400 hover:text-blue-500"
    >create-vue</a>, the official Vue + Vite starter
  </p>
  <p class="mb-4">
    Learn more about IDE Support for Vue in the
    <a
      href="https://vuejs.org/guide/scaling-up/tooling.html#ide-support"
      target="_blank"
      class="font-medium text-blue-600 dark:text-blue-400 hover:text-blue-500"
    >Vue Docs Scaling up Guide</a>.
  </p>
  <p class="text-gray-500">Click on the Vite and Vue logos to learn more</p>
</template>
