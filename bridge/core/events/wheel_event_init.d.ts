import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface WheelEventInit extends EventInit {
    deltaMode?: number;
    deltaX?: number;
    deltaY?: number;
    deltaZ?: number;
}