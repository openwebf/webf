/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
interface NativeLoader {
  new(): void;
  loadNativeLibrary(libName: string, importObject: any): Promise<void>;
}