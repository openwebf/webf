import { EventTarget } from './events/event_target';
import { Document } from './document';
import {Element} from "./element";
import {NodeList} from "./node_list";

/** Node is an interface from which a number of DOM API object types inherit. It allows those types to be treated similarly; for example, inheriting the same set of methods, or being tested in the same way. */
interface Node extends EventTarget {
  readonly ELEMENT_NODE: StaticMember<number>;
  readonly ATTRIBUTE_NODE: StaticMember<number>;
  readonly TEXT_NODE: StaticMember<number>;
  readonly COMMENT_NODE: StaticMember<number>;
  readonly DOCUMENT_NODE: StaticMember<number>;
  readonly DOCUMENT_TYPE_NODE: StaticMember<number>;
  readonly DOCUMENT_FRAGMENT_NODE: StaticMember<number>;

  /**
   * Returns the type of node.
   */
  readonly nodeType: number;
  /**
   * Returns a string appropriate for the type of node.
   */
  readonly nodeName: string;

  nodeValue: string | null;
  hasChildNodes(): boolean;

  /**
   * Returns the children.
   */
  readonly childNodes: NodeList;
  /**
   * Returns the first child.
   */
  readonly firstChild: Node | null;
  /**
   * Returns true if node is connected and false otherwise.
   */
  readonly isConnected: boolean;
  /**
   * Returns the last child.
   */
  readonly lastChild: Node | null;
  /**
   * Returns the next sibling.
   */
  readonly nextSibling: Node | null;

  /**
   * Returns the node document. Returns null for documents.
   */
  readonly ownerDocument: Document | null;
  /**
   * Returns the parent element.
   */
  // @ts-ignore
  readonly parentElement: Element | null;
  /**
   * Returns the parent.
   */
  readonly parentNode: Node | null;
  /**
   * Returns the previous sibling.
   */
  readonly previousSibling: Node | null;
  textContent: string | null;
  appendChild(newNode: Node): Node;
  /**
   * Returns a copy of node. If deep is true, the copy also includes the node's descendants.
   */
  cloneNode(deep?: boolean): Node;
  /**
   * Returns true if other is an inclusive descendant of node, and false otherwise.
   */
  contains(other: Node | null): boolean;
  insertBefore(newChild: Node, refChild: Node | null): Node;
  /**
   * Returns whether node and otherNode have the same properties.
   */
  isEqualNode(otherNode: Node | null): boolean;
  isSameNode(otherNode: Node | null): boolean;
  removeChild(oldChild: Node): Node;
  remove(): void;
  replaceChild(newChild: Node, oldChild: Node): Node;

  new(): void;
}
