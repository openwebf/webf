<script setup lang="ts">
import { computed, ref } from 'vue';
import { useLocation, useNavigate, useParams, useRouteContext } from '@openwebf/vue-router';

const props = withDefaults(
  defineProps<{
    basePath?: string;
  }>(),
  {
    basePath: '',
  },
);

function joinBase(path: string) {
  if (!props.basePath) return path;
  const base = props.basePath.endsWith('/') ? props.basePath.slice(0, -1) : props.basePath;
  const suffix = path.startsWith('/') ? path : `/${path}`;
  return `${base}${suffix}`.replace(/\/{2,}/g, '/');
}

const nav = useNavigate();
const params = useParams();
const location = useLocation();
const route = useRouteContext();

const splat = computed(() => params.value['*'] ?? '(missing)');

const currentStateJson = computed(() => {
  const state = location.value.state;
  if (state === undefined) return 'undefined';
  try {
    return JSON.stringify(state, null, 2);
  } catch {
    return String(state);
  }
});

const nextPath = ref('docs/getting-started');

function goToPath() {
  nav.navigate(joinBase(`/files/${nextPath.value}`));
}
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-4 text-left">
    <div class="flex items-start justify-between gap-3">
      <h1 class="text-2xl font-semibold">Files</h1>
      <div class="rounded-lg border border-white/10 px-3 py-2">
        <div class="text-xs opacity-70">Path</div>
        <div class="font-mono text-xs">{{ location.pathname }}</div>
      </div>
    </div>
    <p class="text-sm opacity-80">
      Wildcard route <code>{{ joinBase('/files/*') }}</code> extracts splat into <code>params["*"]</code>.
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
      <div class="text-sm opacity-80">Splat</div>
      <div class="font-mono text-sm">{{ splat }}</div>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">State</div>
      <pre class="overflow-auto rounded bg-black/30 p-3 text-xs">{{ currentStateJson }}</pre>
    </div>

    <div class="rounded-lg border border-white/10 p-4 space-y-2">
      <div class="text-sm opacity-80">Navigate within files</div>
      <div class="flex gap-2">
        <input
          v-model="nextPath"
          class="w-full rounded bg-black/20 px-3 py-2 text-sm outline-none ring-1 ring-white/10 focus:ring-white/20"
          placeholder="path (e.g. a/b/c.txt)"
        />
        <button class="rounded-lg bg-blue-500/70 px-4 py-2 text-sm hover:bg-blue-500/80" @click="goToPath">
          Go
        </button>
      </div>
    </div>

    <div class="grid gap-3 sm:grid-cols-2">
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(joinBase('/'))">
        Home
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
        Back
      </button>
    </div>
  </div>
</template>
