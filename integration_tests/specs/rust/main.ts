describe('Rust', () => {
  it('should work with rust native library', async () => {
    // @ts-expect-error
    await nativeLoader.loadNativeLibrary('rust_native_api_tests', {}).catch(err => console.log(err));
  }, 5 * 1000);
});
