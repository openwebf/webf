export interface ImageBitmap {
  readonly width: double;
  readonly height: double;

  close(): void;

  // Not constructible from script; `new ImageBitmap()` will throw.
  new(): void;
}

