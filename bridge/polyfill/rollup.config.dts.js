import { dts } from 'rollup-plugin-dts';
import path from 'path';

export default {
  input: './src/index.ts',
  output: {
    file: '../typings/polyfill.d.ts',
    format: 'es',
    // Preserve the export structure
    preserveModules: false,
    // Ensure exports are properly maintained
    exports: 'named'
  },
  plugins: [
    dts({
      respectExternal: true,
      compilerOptions: {
        preserveSymlinks: false,
        declaration: true,
        declarationMap: false
      }
    })
  ],
  external: [
    // External dependencies that should not be bundled
    'es6-promise',
    'event-emitter'
  ]
};