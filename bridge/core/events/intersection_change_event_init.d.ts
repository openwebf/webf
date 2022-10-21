import {UIEventInit} from "./ui_event_init";

// @ts-ignore
@Dictionary()
export interface IntersectionChangeEventInit extends UIEventInit {
    intersectionRatio?: number;
}
