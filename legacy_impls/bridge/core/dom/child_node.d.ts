// @ts-ignore
import {HTMLAllCollection} from "../html/html_all_collection";
import {Element} from "./element";
import {Node} from "./node";

// @ts-ignore
@Mixin()
export interface ChildNode {
  before(...node: (string | Node)[]): void;
  after(...node: (string | Node) []): void;
}