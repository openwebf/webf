<script setup lang="ts">
import { useLocation, useNavigate } from '@openwebf/vue-router';

const location = useLocation();
const nav = useNavigate();
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-4 text-left">
    <h1 class="text-2xl font-semibold">About</h1>
    <p class="text-sm opacity-80">A static route at <code>/about</code>.</p>

    <div class="rounded-lg border border-white/10 p-4">
      <div class="text-sm opacity-80">Location</div>
      <div class="mt-1 font-mono text-sm">{{ location.pathname }}</div>
    </div>

    <div class="flex gap-3">
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate('/')">
        Go home
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
        Back
      </button>
    </div>
  </div>
</template>

