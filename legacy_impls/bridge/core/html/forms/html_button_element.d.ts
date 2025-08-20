import {HTMLElement} from "../html_element";

interface HTMLButtonElement extends HTMLElement {
    disabled: DartImpl<boolean>;
    type: DartImpl<string>;
    name: DartImpl<string>;
    value: DartImpl<string>;
    new(): void;
}
