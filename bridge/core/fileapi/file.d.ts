/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// @ts-ignore
import {FileOptions} from "./file_options";

interface File extends Blob {
  readonly name: string;
  readonly lastModified: number;
  new(blobParts: BlobPart[], fileName: string, options?: FileOptions): File;
}