import {Node} from "./node";
import {ChildNode} from "./child_node";

export interface CharacterData extends Node, ChildNode {
  data: string;
  readonly length: int64;
  new(): void;
}
