import {Event} from "../dom/events/event";
import {Window} from "../frame/window";
import {UIEventInit} from "./ui_event_init";

/** Simple user interface events. */
interface UIEvent extends Event {
    readonly detail: number;
    readonly view: Window | null;
    /** @deprecated */
    readonly which: number;
    new(type: string, init?: UIEventInit): UIEvent;
}