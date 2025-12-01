/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {BlobOptions} from "./blob_options";

interface Blob {
  readonly size: number;
  readonly type: string;
  arrayBuffer(): Promise<ArrayBuffer>;
  slice(start?: int64, end?: int64, contentType?: string): Blob;
  text(): Promise<string>;
  base64(): Promise<string>;
  new(blobParts?: BlobPart[], options?: BlobOptions): Blob;
}
