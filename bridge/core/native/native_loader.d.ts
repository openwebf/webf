interface NativeLoader {
  new(): void;
  loadNativeLibrary(libName: string, importObject: any): Promise<void>;
}