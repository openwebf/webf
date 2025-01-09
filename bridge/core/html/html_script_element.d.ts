import {HTMLElement} from "./html_element";

interface HTMLScriptElement extends HTMLElement {
    src: SupportAsync<DartImpl<string>>;
    type: SupportAsync<DartImpl<string>>;
    noModule: DartImpl<boolean>;
    async: SupportAsync<DartImpl<boolean>>;
    text: SupportAsync<DartImpl<string>>;
    readonly readyState: SupportAsync<DartImpl<string>>;
    supports(type: string): StaticMember<boolean>;
    new(): void;
}
