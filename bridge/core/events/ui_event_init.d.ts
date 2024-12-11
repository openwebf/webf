import { EventInit } from "../dom/events/event_init";
import {Window} from "../frame/window";
import {UIEvent} from "./ui_event";

// @ts-ignore
@Dictionary()
export interface UIEventInit extends EventInit {
    detail?: number;
    view?: Window | null;
    /** @deprecated */
    which?: number;
}
