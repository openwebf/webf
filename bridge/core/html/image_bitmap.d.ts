/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
export interface ImageBitmap {
  readonly width: double;
  readonly height: double;

  close(): void;

  // Not constructible from script; `new ImageBitmap()` will throw.
  new(): void;
}

