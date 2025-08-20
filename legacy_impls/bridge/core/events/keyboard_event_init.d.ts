import {UIEventInit} from "./ui_event_init";

// @ts-ignore
@Dictionary()
export interface KeyboardEventInit extends UIEventInit {
    altKey?: boolean;
    /** @deprecated */
    charCode?: number;
    code?: string;
    ctrlKey?: boolean;
    isComposing?: boolean;
    key?: string;
    /** @deprecated */
    keyCode?: number;
    location?: number;
    metaKey?: boolean;
    repeat?: boolean;
    shiftKey?: boolean;
}
