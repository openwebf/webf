import {UIEvent} from "./ui_event";
import {EventTarget} from "../dom/events/event_target";

/** Focus-related events like focus, blur, focusin, or focusout. */
interface FocusEvent extends UIEvent {
    readonly relatedTarget: EventTarget | null;
}