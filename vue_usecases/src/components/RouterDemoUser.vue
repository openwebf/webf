<script setup lang="ts">
import { computed } from 'vue';
import { WebFRouter, useLocation, useNavigate, useParams, useRouteContext } from '@openwebf/vue-router';

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

function inferUserIdFromPathname(pathname: string): string | undefined {
  const parts = pathname.split('/').filter(Boolean);
  const i = parts.lastIndexOf('users');
  if (i === -1) return undefined;
  return parts[i + 1];
}

const userId = computed(() => params.value.id ?? inferUserIdFromPathname(location.value.pathname) ?? '(missing)');

const currentStateJson = computed(() => {
  const state = location.value.state;
  if (state === undefined) return 'undefined';
  try {
    return JSON.stringify(state, null, 2);
  } catch {
    return String(state);
  }
});

async function nextUser() {
  const current = Number(userId.value);
  const next = Number.isFinite(current) ? current + 1 : 1;
  await WebFRouter.replace(joinBase(`/users/${next}`), { from: location.value.pathname, at: Date.now() });
}

async function prevUser() {
  const current = Number(userId.value);
  const prev = Number.isFinite(current) ? Math.max(0, current - 1) : 0;
  await WebFRouter.replace(joinBase(`/users/${prev}`), { from: location.value.pathname, at: Date.now() });
}
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-4 text-left">
    <div class="flex items-start justify-between gap-3">
      <h1 class="text-2xl font-semibold">User</h1>
      <div class="rounded-lg border border-white/10 px-3 py-2">
        <div class="text-xs opacity-70">Path</div>
        <div class="font-mono text-xs">{{ location.pathname }}</div>
      </div>
    </div>

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
      <pre class="overflow-auto rounded bg-black/30 p-3 text-xs">{{ currentStateJson }}</pre>
    </div>

    <div class="grid gap-3 sm:grid-cols-2">
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(joinBase('/'))">
        Home
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="nav.navigate(-1)">
        Back
      </button>
      <button class="rounded-lg bg-white/10 px-4 py-2 text-sm hover:bg-white/15" @click="prevUser">
        Previous user
      </button>
      <button class="rounded-lg bg-blue-500/70 px-4 py-2 text-sm hover:bg-blue-500/80" @click="nextUser">
        Next user
      </button>
    </div>
  </div>
</template>
