import { EventTarget } from "../dom/events/event_target";
import {UIEventInit} from "./ui_event_init";

// @ts-ignore
@Dictionary()
export interface FocusEventInit extends UIEventInit {
    relatedTarget?: EventTarget | null;
}
