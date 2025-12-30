<script setup lang="ts">
import { computed } from 'vue';
import { WebFRouter, useLocation, useNavigate, useParams, useRouteContext } from '@openwebf/vue-router';

const nav = useNavigate();
const params = useParams();
const location = useLocation();
const route = useRouteContext();

const userId = computed(() => params.value.id ?? '(missing)');

async function nextUser() {
  const current = Number(params.value.id);
  const next = Number.isFinite(current) ? current + 1 : 1;
  await WebFRouter.push(`/users/${next}`, { from: location.value.pathname, at: Date.now() });
}
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-4 text-left">
    <h1 class="text-2xl font-semibold">User</h1>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">Route context</div>
      <div class="grid gap-1 font-mono text-sm">
        <div><span class="opacity-70">pattern:</span> {{ route.path }}</div>
        <div><span class="opacity-70">mounted:</span> {{ route.mountedPath }}</div>
        <div><span class="opacity-70">active:</span> {{ route.activePath }}</div>
        <div><span class="opacity-70">isActive:</span> {{ route.isActive }}</div>
      </div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">Params</div>
      <div class="font-mono text-sm">id = {{ userId }}</div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">State</div>
      <pre class="overflow-auto rounded bg-black/30 p-3 text-xs">{{ location.state }}</pre>
    </div>

    <div class="flex flex-wrap gap-3">
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate('/')">
        Home
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nextUser">
        Next user
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
        Back
      </button>
    </div>
  </div>
</template>

