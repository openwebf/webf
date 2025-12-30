<script setup lang="ts">
import { computed } from 'vue';
import { useLocation, useNavigate, useParams, useRouteContext } from '@openwebf/vue-router';

const nav = useNavigate();
const params = useParams();
const location = useLocation();
const route = useRouteContext();

const caught = computed(() => params.value['*'] ?? '(missing)');
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-4 text-left">
    <h1 class="text-2xl font-semibold">Not Found</h1>
    <p class="text-sm opacity-80">
      Catch-all route <code>*</code> captures the entire pathname into <code>params["*"]</code>.
    </p>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">Route</div>
      <div class="grid gap-1 font-mono text-sm">
        <div><span class="opacity-70">pattern:</span> {{ route.path }}</div>
        <div><span class="opacity-70">mounted:</span> {{ route.mountedPath }}</div>
        <div><span class="opacity-70">active:</span> {{ route.activePath }}</div>
      </div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">Captured</div>
      <div class="font-mono text-sm">{{ caught }}</div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">State</div>
      <pre class="overflow-auto rounded bg-black/30 p-3 text-xs">{{ location.state }}</pre>
    </div>

    <div class="flex gap-3">
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate('/')">
        Home
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
        Back
      </button>
    </div>
  </div>
</template>

