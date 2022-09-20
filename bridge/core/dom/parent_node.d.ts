// @ts-ignore
import {HTMLAllCollection} from "../html/html_all_collection";
import {Element} from "./element";

// @ts-ignore
@Mixin()
export interface ParentNode {
  readonly firstElementChild: Element | null;
  readonly lastElementChild: Element | null;
  readonly children: Element[];
}