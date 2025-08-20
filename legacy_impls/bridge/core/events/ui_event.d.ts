import {Event} from "../dom/events/event";
import {Window} from "../frame/window";
import {UIEventInit} from "./ui_event_init";

/** Simple user interface events. */
interface UIEvent extends Event {
    // Returns a long with details about the event, depending on the event type.
    // For click or dblclick events, UIEvent.detail is the current click count.
    // For mousedown or mouseup events, UIEvent.detail is 1 plus the current click count.
    // For all other UIEvent objects, UIEvent.detail is always zero.
    readonly detail: number;
    readonly view: Window | null;
    /** @deprecated */
    readonly which: number;
    [key: string]: any;
    new(type: string, init?: UIEventInit): UIEvent;
}