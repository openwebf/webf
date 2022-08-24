import {Element} from "../dom/element";

interface HTMLCollection {
    readonly length: double;
    item(index: double): Element | null;
    readonly [key: number]: Element | null;
    new(): void;
}