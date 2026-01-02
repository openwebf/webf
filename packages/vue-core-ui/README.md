# @openwebf/vue-core-ui

Vue 3 typings (and small helpers) for WebF custom elements.

## Installation

```bash
npm install @openwebf/vue-core-ui
```

## Custom Elements (typings)

This package augments Vue’s `GlobalComponents` so tags like `<webf-list-view />` and `<flutter-gesture-detector />` are type-checked in templates.

If your project doesn’t pick up the global typings automatically, add an import once (for example in `src/env.d.ts` or `src/main.ts`):

```ts
import '@openwebf/vue-core-ui';
```

## `v-flutter-attached` directive (onscreen/offscreen)

WebF dispatches `onscreen` when an element is fully rendered by Flutter and `offscreen` when it detaches.

Register the directive:

```ts
import { createApp } from 'vue';
import App from './App.vue';
import { flutterAttached } from '@openwebf/vue-core-ui';

createApp(App).directive('flutter-attached', flutterAttached).mount('#app');
```

TypeScript / IDE note: runtime `app.directive(...)` registration isn’t something TypeScript can “see”. This package ships a `GlobalDirectives` type augmentation so `v-flutter-attached` is recognized by Vue template type-checking/IntelliSense as long as your project includes the package types (e.g. via `import '@openwebf/vue-core-ui'` once).

Use it in templates:

```vue
<template>
  <webf-list-view
    v-flutter-attached="onAttached"
    style="height: 300px"
  />

  <flutter-gesture-detector
    v-flutter-attached="{ onAttached, onDetached }"
  />
</template>

<script setup lang="ts">
function onAttached(e: Event) {
  // element rendered by Flutter
}

function onDetached(e: Event) {
  // element detached from Flutter render tree
}
</script>
```

## `useFlutterAttached()` composable (alternative)

If you prefer composables (Composition API) over directives:

```vue
<template>
  <webf-list-view :ref="el" style="height: 300px" />
  <div :ref="otherEl" />
</template>

<script setup lang="ts">
import { useFlutterAttached } from '@openwebf/vue-core-ui';

const el = useFlutterAttached(
  () => {
    // onscreen
  },
  () => {
    // offscreen
  },
);

const otherEl = useFlutterAttached(() => {});
</script>
```
