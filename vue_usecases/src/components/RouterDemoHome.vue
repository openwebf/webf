<script setup lang="ts">
import { computed, ref } from 'vue';
import { WebFRouter, useLocation, useNavigate } from '@openwebf/vue-router';

const location = useLocation();
const nav = useNavigate();

const userId = ref('123');
const filePath = ref('docs/getting-started');
const unknownPath = ref('somewhere/else');

const currentStateJson = computed(() => {
  const state = location.value.state;
  if (state === undefined) return 'undefined';
  try {
    return JSON.stringify(state, null, 2);
  } catch {
    return String(state);
  }
});

async function goUser() {
  const to = `/users/${userId.value}`;
  await WebFRouter.push(to, { from: location.value.pathname, at: Date.now() });
}

async function goFiles() {
  const to = `/files/${filePath.value}`;
  await WebFRouter.push(to, { from: 'home', at: Date.now() });
}

async function goUnknown() {
  const to = `/${unknownPath.value}`.replace(/\/{2,}/g, '/');
  await WebFRouter.push(to, { from: 'home', at: Date.now() });
}
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-6 text-left">
    <div class="space-y-2">
      <h1 class="text-2xl font-semibold">Vue Router Demo (WebF)</h1>
      <p class="text-sm opacity-80">
        This demo runs inside the WebF environment and uses the native <code>webf.hybridHistory</code> +
        <code>&lt;webf-router-link&gt;</code>.
      </p>
    </div>

    <div class="rounded-lg border border-white/10 p-4">
      <div class="text-sm opacity-80">Current location</div>
      <div class="mt-1 font-mono text-sm">{{ location.pathname }}</div>
    </div>

    <div class="rounded-lg border border-white/10 p-4">
      <div class="text-sm opacity-80">Current state</div>
      <pre class="mt-2 overflow-auto rounded bg-black/30 p-3 text-xs">{{ currentStateJson }}</pre>
    </div>

    <div class="grid gap-3 sm:grid-cols-2">
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate('/about')">
        Go to /about
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
        Back (-1)
      </button>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-3">
      <div class="font-medium">Dynamic route: <code>/users/:id</code></div>
      <div class="flex gap-2">
        <input
          v-model="userId"
          class="w-full rounded bg-black/20 px-3 py-2 text-sm outline-none ring-1 ring-white/10 focus:ring-white/20"
          placeholder="id (e.g. 123)"
        />
        <button class="rounded-lg bg-blue-500/70 px-4 py-2 text-sm hover:bg-blue-500/80" @click="goUser">
          Navigate
        </button>
      </div>
      <div class="text-xs opacity-80">Uses WebFRouter pre-mount (ensureRouteMounted) before pushing.</div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-3">
      <div class="font-medium">Wildcard route: <code>/files/*</code></div>
      <div class="flex gap-2">
        <input
          v-model="filePath"
          class="w-full rounded bg-black/20 px-3 py-2 text-sm outline-none ring-1 ring-white/10 focus:ring-white/20"
          placeholder="path (e.g. a/b/c.txt)"
        />
        <button class="rounded-lg bg-blue-500/70 px-4 py-2 text-sm hover:bg-blue-500/80" @click="goFiles">
          Navigate
        </button>
      </div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-3">
      <div class="font-medium">Catch-all route: <code>*</code></div>
      <div class="flex gap-2">
        <input
          v-model="unknownPath"
          class="w-full rounded bg-black/20 px-3 py-2 text-sm outline-none ring-1 ring-white/10 focus:ring-white/20"
          placeholder="unknown path (e.g. foo/bar)"
        />
        <button class="rounded-lg bg-blue-500/70 px-4 py-2 text-sm hover:bg-blue-500/80" @click="goUnknown">
          Navigate
        </button>
      </div>
    </div>
  </div>
</template>
