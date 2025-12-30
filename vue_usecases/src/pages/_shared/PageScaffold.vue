<script setup lang="ts">
import { useLocation, useNavigate } from '@openwebf/vue-router';

defineProps<{
  title: string;
  description?: string;
}>();

const nav = useNavigate();
const location = useLocation();
</script>

<template>
  <div class="min-h-screen w-full px-6 py-6 text-left">
    <header class="mx-auto max-w-3xl space-y-3">
      <div class="flex items-start justify-between gap-3">
        <div class="space-y-1">
          <div class="text-2xl font-semibold">{{ title }}</div>
          <div v-if="description" class="text-sm opacity-80">{{ description }}</div>
        </div>

        <div class="flex shrink-0 items-center gap-2">
          <button class="rounded-lg bg-white/10 px-3 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
            Back
          </button>
          <button class="rounded-lg bg-white/10 px-3 py-2 text-sm hover:bg-white/15" @click="nav.navigate('/')">
            Home
          </button>
          <button class="rounded-lg bg-blue-500/70 px-3 py-2 text-sm hover:bg-blue-500/80" @click="nav.navigate('/features')">
            Features
          </button>
        </div>
      </div>

      <div class="rounded-lg border border-white/10 p-4">
        <div class="text-sm opacity-80">Path</div>
        <div class="mt-1 font-mono text-sm">{{ location.pathname }}</div>
      </div>
    </header>

    <main class="mx-auto mt-6 max-w-3xl">
      <slot />
    </main>
  </div>
</template>

