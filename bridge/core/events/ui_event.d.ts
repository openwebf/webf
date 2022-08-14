import {Event} from "../dom/events/event";
import {Window} from "../frame/window";

/** Simple user interface events. */
interface UIEvent extends Event {
    readonly detail: number;
    readonly view: Window | null;
    /** @deprecated */
    readonly which: number;
}