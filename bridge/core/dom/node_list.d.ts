import {Node} from "./node";

export interface NodeList {
  readonly length: int64;
  item(index: number): Node | null;
  readonly [index: number]: Node | null;
  readonly forEach: JSArrayProtoMethod;
  readonly keys: JSArrayProtoMethod;
  readonly entries: JSArrayProtoMethod;
  readonly values: JSArrayProtoMethod;
  readonly [Symbol.iterator]: JSArrayProtoMethod;
  new(): void;
}
