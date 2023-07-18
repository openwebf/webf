import {UIEvent} from "./ui_event";
import {EventTarget} from "../dom/events/event_target";
import {FocusEventInit} from "./focus_event_init";

/** Focus-related events like focus, blur, focusin, or focusout. */
interface FocusEvent extends UIEvent {
    readonly relatedTarget: EventTarget | null;
    [key: string]: any;
    new(type: string, init?: FocusEventInit): FocusEvent;
}