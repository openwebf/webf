import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  resolve: {
    alias: {
      // `@openwebf/vue-cupertino-ui` is typings-only (no runtime JS entry). We alias it to a
      // local shim so production builds can bundle enum values like `CupertinoIcons`.
      '@openwebf/vue-cupertino-ui': fileURLToPath(new URL('./src/shims/openwebf-vue-cupertino-ui.ts', import.meta.url)),
    },
  },
  plugins: [
    vue({
      template: {
        compilerOptions: {
          isCustomElement: tag => tag.startsWith('webf-') || tag.startsWith('flutter-'),
        },
      },
    }),
  ],
})
