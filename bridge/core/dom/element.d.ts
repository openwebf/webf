import {Node} from "./node";
import {Document} from "./document";
import {ScrollToOptions} from "./scroll_to_options";
import { ElementAttributes } from './legacy/element_attributes';
import {CSSStyleDeclaration} from "../css/legacy/css_style_declaration";
import {ParentNode} from "./parent_node";

interface Element extends Node, ParentNode {
  id: string;
  className: string;
  readonly classList: DOMTokenList;
  name: DartImpl<string>;
  readonly attributes: ElementAttributes;
  readonly style: CSSStyleDeclaration;
  readonly clientHeight: DartImpl<number>;
  readonly clientLeft: DartImpl<number>;
  readonly clientTop: DartImpl<number>;
  readonly clientWidth: DartImpl<number>;
  readonly outerHTML: string;
  innerHTML: string;
  readonly ownerDocument: Document;
  scrollLeft: DartImpl<number>;
  scrollTop: DartImpl<number>;
  readonly scrollWidth: DartImpl<number>;
  readonly scrollHeight: DartImpl<number>;
  /**
   * Returns the HTML-uppercased qualified name.
   */
  readonly tagName: string;
  /**
   * Returns element's first attribute whose qualified name is qualifiedName, and null if there is no such attribute otherwise.
   */
  getAttribute(qualifiedName: string): string | null;
  /**
   * Sets the value of element's first attribute whose qualified name is qualifiedName to value.
   */
  setAttribute(qualifiedName: string, value: string): void;
  /**
   * Removes element's first attribute whose qualified name is qualifiedName.
   */
  removeAttribute(qualifiedName: string): void;

  /**
   * Indicating whether the specified element has the specified attribute or not.
   */
  hasAttribute(qualifiedName: string): boolean;

  // CSSOM View Module
  // https://drafts.csswg.org/cssom-view/#extension-to-the-element-interface
  getBoundingClientRect(): BoundingClientRect;

  getElementsByClassName(className: string) : Element[];
  getElementsByTagName(tagName: string): Element[];

  scroll(options?: ScrollToOptions): void;
  scroll(x: number, y: number): void;
  scrollBy(options?: ScrollToOptions): void;
  scrollBy(x: number, y: number): void;
  scrollTo(options?: ScrollToOptions): void;
  scrollTo(x: number, y: number): void;

  // Export the target element's rendering content to PNG.
  // WebF special API.
  toBlob(devicePixelRatioValue?: double): Promise<ArrayBuffer>;

  new(): void;
}
