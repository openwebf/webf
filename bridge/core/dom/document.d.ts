import {Node} from "./node";
import {Text} from "./text";
import {Comment} from "./comment";
import {DocumentFragment} from "./document_fragment";
import {HTMLHeadElement} from "../html/html_head_element";
import {HTMLBodyElement} from "../html/html_body_element";
import {HTMLHtmlElement} from "../html/html_html_element";
import {Element} from "./element";
import {Event} from "./events/event";
import {HTMLAllCollection} from "../html/html_all_collection";
import {IDLEventHandler} from "../frame/window_event_handlers";
import {Window} from "../frame/window";
import {ParentNode} from "./parent_node";

interface Document extends Node, ParentNode {
  readonly all: HTMLAllCollection;
  title: SupportAsync<DartImpl<string>>;
  body: HTMLBodyElement | null;
  cookie: SupportAsync<DartImpl<string>>;
  __clear_cookies__(): DartImpl<void>;
  __force_rebuild__(): DartImpl<void>;
  domain: SupportAsync<DartImpl<string>>;
  readonly head: HTMLHeadElement | null;
  readonly documentElement: HTMLHtmlElement | null;
  // Legacy impl: get the polyfill implements from global object.
  readonly location: any;
  readonly compatMode: SupportAsync<DartImpl<string>>;
  readonly readyState: SupportAsync<DartImpl<string>>;
  readonly visibilityState: SupportAsync<DartImpl<string>>;
  readonly hidden: SupportAsync<DartImpl<boolean>>;
  readonly defaultView: Window;

  createElement(tagName: string, options?: any): Element;
  createElementNS(uri: string | null, tagName: string, options?: any): Element;
  createTextNode(value: string): Text;
  createDocumentFragment(): DocumentFragment;
  createComment(data: string): Comment;
  createEvent(event_type: string): Event;

  getElementById(id: string): SupportAsync<Element | null>;
  getElementsByClassName(className: string) : SupportAsync<Element[]>;
  getElementsByTagName(tagName: string): SupportAsync<Element[]>;
  getElementsByName(name: string): SupportAsync<Element[]>;

  querySelector(selectors: string): SupportAsync<Element | null>;
  querySelectorAll(selectors: string): SupportAsync<Element[]>;

  elementFromPoint(x: number, y: number): SupportAsync<Element | null>;

  onreadystatechange: IDLEventHandler | null;
  new(): Document;
}
