import {UIEventInit} from "./ui_event_init";

// @ts-ignore
@Dictionary()
export interface KeyboardEventInit extends UIEventInit {
    // altKey?: boolean;
    // /** @deprecated */
    // charCode?: number;
    key?: string;
    code?: string;
    // ctrlKey?: boolean;
    // isComposing?: boolean;
    // /** @deprecated */
    // keyCode?: number;
    // location?: number;
    // metaKey?: boolean;
    // repeat?: boolean;
    // shiftKey?: boolean;
}
