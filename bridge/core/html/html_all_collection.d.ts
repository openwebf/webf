import {Element} from "../dom/element";

interface HTMLAllCollection {
    readonly length: double;
    item(index: double): Element | null;
    readonly [key: number]: Element | null;
    new(): void;
}