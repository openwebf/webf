// @ts-ignore
import {HTMLAllCollection} from "../html/html_all_collection";
import {Element} from "./element";

// @ts-ignore
@Mixin()
export interface ParentNode {
  readonly children: Element[];
}