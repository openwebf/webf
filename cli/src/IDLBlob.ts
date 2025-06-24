import {ClassObject, FunctionObject} from "./declaration";

export class IDLBlob {
  raw: string = '';
  dist: string;
  source: string;
  filename: string;
  implement: string;
  relativeDir: string = '';
  objects: (ClassObject | FunctionObject)[] = [];

  constructor(source: string, dist: string, filename: string, implement: string, relativeDir: string = '') {
    this.source = source;
    this.dist = dist;
    this.filename = filename;
    this.implement = implement;
    this.relativeDir = relativeDir;
    // Don't read file in constructor - let the generator handle it
  }
}
