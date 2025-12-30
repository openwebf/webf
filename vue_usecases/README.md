# Vue 3 + TypeScript + Vite

This template should help get you started developing with Vue 3 and TypeScript in Vite. The template uses Vue 3 `<script setup>` SFCs, check out the [script setup docs](https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup) to learn more.

Learn more about the recommended Project Setup and IDE Support in the [Vue Docs TypeScript Guide](https://vuejs.org/guide/typescript/overview.html#project-setup).

## WebF Cupertino UI typings

This project consumes the generated WebF Cupertino UI Vue typings package:
- Local dependency: `@openwebf/vue-cupertino-ui` (`file:../packages/vue-cupertino-ui`)
- Global component types are loaded via `src/env.d.ts` (imports `@openwebf/vue-cupertino-ui`)
- Vue compiler is configured to treat `webf-*` / `flutter-*` tags as custom elements in `vite.config.ts`

## Router demos

This app also includes route demos using `@openwebf/vue-router`.
These demos are intended to run inside the WebF environment where `webf.hybridHistory` and
`<webf-router-link>` are available.

## Use cases pages

This repo mirrors the page/folder structure (and route paths) from `../use_cases`:
- Routes: `src/routes.ts`
- Pages: `src/pages/` (placeholders to be ported from the React implementation)

### Debugging

This project enables vue-router debug logs by default in `src/main.ts`.
If you want to disable them, remove:

```ts
// @ts-ignore
globalThis.__WEBF_VUE_ROUTER_DEBUG__ = true;
```

### What to look at

- Route configuration: `src/routes.ts`
- Pages: `src/pages/`
- Legacy router demo components (not wired by default):
  - `src/components/RouterDemoHome.vue`
  - `src/components/RouterDemoUser.vue`
  - `src/components/RouterDemoFiles.vue`
  - `src/components/RouterDemoNotFound.vue`
