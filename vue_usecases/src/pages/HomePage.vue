<script setup lang="ts">
import { WebFRouter } from '@openwebf/vue-router';
</script>

<template>
  <div class="min-h-screen w-full px-6 py-6 text-left">
    <div class="mx-auto max-w-3xl space-y-4">
      <div class="rounded-2xl bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 p-6 text-white shadow-lg">
        <h1 class="text-3xl font-bold drop-shadow">WebF Vue Use Cases</h1>
        <p class="mt-2 text-sm opacity-90">
          Vue mirror of `../use_cases` pages and route structure.
        </p>
      </div>

      <div class="grid gap-3 sm:grid-cols-2">
        <button class="rounded-lg bg-blue-500/70 px-4 py-2 text-sm hover:bg-blue-500/80" @click="WebFRouter.pushState({}, '/features')">
          Open Feature Catalog
        </button>
      </div>
    </div>
  </div>
</template>

