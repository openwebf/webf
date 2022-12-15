import fs from 'fs';
import {ClassObject} from "../idl/declaration";

export class DAPBlob {
  raw: string;
  dist: string;
  source: string;
  filename: string;
  implement: string;
  objects: (ClassObject)[];

  constructor(source: string, dist: string, filename: string, implement: string) {
    this.source = source;
    this.raw = fs.readFileSync(source, {encoding: 'utf-8'});
    this.dist = dist;
    this.filename = filename;
    this.implement = implement;
  }
}
