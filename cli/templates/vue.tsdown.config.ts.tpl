module.exports = {
  entry: ['src/index.ts'],
  format: ['esm', 'cjs'],
  dts: true,
  sourcemap: true,
  clean: true,
  external: ['vue', '@openwebf/vue-core-ui'],
};
