import {Node} from "./node";

export interface CharacterData extends Node {
  data: string;
  readonly length: int64;
  new(): void;
}
