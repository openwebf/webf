import {Node} from "./node";
import {Document} from "./document";
import {ScrollToOptions} from "./scroll_to_options";
import { ElementAttributes } from './legacy/element_attributes';
import {CSSStyleDeclaration} from "../css/css_style_declaration";
import {ParentNode} from "./parent_node";
import {ChildNode} from "./child_node";
import {Blob} from "../fileapi/blob";

interface Element extends Node, ParentNode, ChildNode {
  id: string;
  className: string;
  readonly classList: DOMTokenList;
  readonly dataset: DOMStringMap;
  name: DartImpl<string>;
  readonly attributes: ElementAttributes;
  readonly style: InlineCssStyleDeclaration;
  readonly clientHeight: SupportAsync<DartImpl<DependentsOnLayout<number>>>;
  readonly clientLeft: SupportAsync<DartImpl<DependentsOnLayout<number>>>;
  readonly clientTop: SupportAsync<DartImpl<DependentsOnLayout<number>>>;
  readonly clientWidth: SupportAsync<DartImpl<DependentsOnLayout<number>>>;
  readonly outerHTML: string;
  innerHTML: string;
  readonly ownerDocument: Document;
  scrollLeft: SupportAsync<DartImpl<DependentsOnLayout<number>>>;
  scrollTop:SupportAsync< DartImpl<DependentsOnLayout<number>>>;
  readonly scrollWidth: SupportAsync<DartImpl<DependentsOnLayout<number>>>;
  readonly scrollHeight:SupportAsync< DartImpl<DependentsOnLayout<number>>>;
  readonly prefix: string | null;
  readonly localName: string;
  readonly namespaceURI: string | null;
  /**
   * Returns the HTML-uppercased qualified name.
   */
  readonly tagName: string;
  dir: DartImpl<string>;
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
  getBoundingClientRect(): SupportAsync<BoundingClientRect>;
  getClientRects(): SupportAsync<BoundingClientRect[]>;

  getElementsByClassName(className: string) : SupportAsync<Element[]>;
  getElementsByTagName(tagName: string): SupportAsync<Element[]>;

  querySelector(selectors: string): SupportAsync<Element | null>;
  querySelectorAll(selectors: string): SupportAsync<Element[]>;
  matches(selectors: string): SupportAsync<boolean>;

  closest(selectors: string): SupportAsync<Element | null>;

  insertAdjacentElement(position: string, element: Element): Element | null;

  scroll(options?: ScrollToOptions): SupportAsyncManual<void>;
  scroll(x: number, y: number): SupportAsyncManual<void>;
  scrollBy(options?: ScrollToOptions): SupportAsyncManual<void>;
  scrollBy(x: number, y: number): SupportAsyncManual<void>;
  scrollTo(options?: ScrollToOptions): SupportAsyncManual<void>;
  scrollTo(x: number, y: number): SupportAsyncManual<void>;

  // Export the target element's rendering content to PNG.
  // WebF special API.
  toBlob(devicePixelRatioValue?: double): Promise<Blob>;

  __testGlobalToLocal__(x: number, y: number): any;

  new(): void;
}
