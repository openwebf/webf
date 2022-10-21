import {UIEventInit} from "./ui_event_init";

// @ts-ignore
@Dictionary()
export interface InputEventInit extends UIEventInit {
    inputType?: string;
    data?: string;
}
