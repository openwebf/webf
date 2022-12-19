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

interface Document extends Node {
  readonly all: HTMLAllCollection;
  body: HTMLBodyElement | null;
  cookie: DartImpl<string>;
  __clear_cookies__(): DartImpl<void>;
  readonly head: HTMLHeadElement | null;
  readonly documentElement: HTMLHtmlElement | null;
  // Legacy impl: get the polyfill implements from global object.
  readonly location: any;

  createElement(tagName: string, options?: any): Element;
  createTextNode(value: string): Text;
  createDocumentFragment(): DocumentFragment;
  createComment(data: string): Comment;
  createEvent(event_type: string): Event;

  getElementById(id: string): Element | null;
  getElementsByClassName(className: string) : Element[];
  getElementsByTagName(tagName: string): Element[];
  getElementsByName(name: string): Element[];

  querySelector(selectors: string): Element | null;
  querySelectorAll(selectors: string): Element[];

  new(): Document;
}
