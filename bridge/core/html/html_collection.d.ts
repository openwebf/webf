import {Element} from "../dom/element";

interface HTMLCollection {
    readonly length: double;
    item(index: double): Element | null;
    namedItem(name: string): Element | null;
}