import {HTMLElement} from "../html_element";

interface WidgetElement extends HTMLElement {
  [key: string]: any;
  new(): void;
}