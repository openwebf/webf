/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// @ts-ignore
import {BlobOptions} from "./blob_options";

// @ts-ignore
@Dictionary()
export interface FileOptions extends BlobOptions {
  readonly lastModified?: number;
}