import { EventInit } from "../dom/events/event_init";
import {EventTarget} from "../dom/events/event_target";

// @ts-ignore
@Dictionary()
export interface MouseEventInit extends EventInit {
    altKey?: boolean;
    button?: number;
    buttons?: number;
    clientX?: number;
    clientY?: number;
    ctrlKey?: boolean;
    metaKey?: boolean;
    relatedTarget?: EventTarget | null;
    screenX?: number;
    screenY?: number;
    shiftKey?: boolean;
}