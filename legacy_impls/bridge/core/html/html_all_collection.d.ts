import {HTMLCollection} from "./html_collection";
import {Element} from "../dom/element";

interface HTMLAllCollection extends HTMLCollection {
    item(index: double): Element | null;
    readonly [key: number]: Element | null;
    new(): void;
}