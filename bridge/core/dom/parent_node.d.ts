// @ts-ignore
import {HTMLAllCollection} from "../html/html_all_collection";
import {Element} from "./element";
import {Node} from "./node";

// @ts-ignore
@Mixin()
export interface ParentNode {
  readonly firstElementChild: Element | null;
  readonly lastElementChild: Element | null;
  readonly children: Element[];
  readonly childElementCount: int64;

  prepend(...node: (string | Node)[]): void;
  append(...node: (string | Node) []): void;
}