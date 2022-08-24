import { EventInit } from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface GestureEventInit extends EventInit {
    state?: string;
    direction?: string;
    deltaX?: number;
    deltaY?: number;
    velocityX?: number;
    velocityY?: number;
    scale?: number;
    rotation?: number;
}
