// @ts-ignore
import {BlobOptions} from "./blob_options";

// @ts-ignore
@Dictionary()
export interface FileOptions extends BlobOptions {
  readonly lastModified?: number;
}