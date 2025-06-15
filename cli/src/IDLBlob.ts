import fs from 'fs';
import {ClassObject, FunctionObject} from "./declaration";

export class IDLBlob {
  raw: string = '';
  dist: string;
  source: string;
  filename: string;
  implement: string;
  objects: (ClassObject | FunctionObject)[] = [];

  constructor(source: string, dist: string, filename: string, implement: string) {
    this.source = source;
    this.dist = dist;
    this.filename = filename;
    this.implement = implement;
    // Don't read file in constructor - let the generator handle it
  }
}
