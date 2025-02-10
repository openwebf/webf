import {Element} from "../dom/element";
import {HTMLElement} from "./html_element";

interface HTMLAnchorElement extends HTMLElement {
  target: DartImpl<string>;
  accessKey: DartImpl<string>;
  download: DartImpl<string>;
  ping: DartImpl<string>;
  rel: DartImpl<string>;
  type: DartImpl<string>;
  text: DartImpl<string>;
  href: DartImpl<string>;
  readonly origin: DartImpl<string>;
  protocol: DartImpl<string>;
  username: DartImpl<string>;
  password: DartImpl<string>;
  host: DartImpl<string>;
  hostname: DartImpl<string>;
  port: DartImpl<string>;
  pathname: DartImpl<string>;
  search: DartImpl<string>;
  hash: DartImpl<string>;
  new(): void;
}
