<script setup lang="ts">
import { Route, Routes } from '@openwebf/vue-router';
import { computed } from 'vue';
import RouterDemoAbout from './components/RouterDemoAbout.vue';
import RouterDemoFiles from './components/RouterDemoFiles.vue';
import RouterDemoHome from './components/RouterDemoHome.vue';
import RouterDemoNotFound from './components/RouterDemoNotFound.vue';
import RouterDemoUser from './components/RouterDemoUser.vue';
import { useHybridHistoryDebug } from './useHybridHistoryDebug';

const debug = useHybridHistoryDebug();
const stackJson = computed(() => JSON.stringify(debug.value.stack, null, 2));
</script>

<template>
  <div class="min-h-screen w-full px-6 py-6 text-left">
    <header class="mx-auto max-w-3xl space-y-3">
      <div class="flex items-center justify-between">
        <div class="text-lg font-semibold">`@openwebf/vue-router` demos</div>
        <a
          class="text-sm opacity-80 hover:opacity-100"
          href="https://github.com/openwebf/webf"
          target="_blank"
          rel="noreferrer"
        >
          webf repo
        </a>
      </div>

      <div class="rounded-lg border border-white/10 p-4">
        <div class="text-sm opacity-80">Hybrid history</div>
        <div class="mt-1 font-mono text-sm">{{ debug.path }}</div>
        <pre class="mt-3 overflow-auto rounded bg-black/30 p-3 text-xs">{{ stackJson }}</pre>
      </div>
    </header>

    <main class="mt-6">
      <Routes>
        <Route path="/" :element="RouterDemoHome" title="Home"   />
        <Route path="/about" :element="RouterDemoAbout" title="About" />
        <Route path="/users/:id" :element="RouterDemoUser" title="User" />
        <Route path="/files/*" :element="RouterDemoFiles" title="Files" />
        <Route path="*" :element="RouterDemoNotFound" title="Not Found" />
      </Routes>
    </main>
  </div>
</template>
