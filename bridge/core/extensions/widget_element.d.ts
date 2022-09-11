import {HTMLElement} from "../html/html_element";

interface WidgetElement extends HTMLElement {
    [key: string]: any;
    new(): void;
}