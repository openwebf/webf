import { EventInit } from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface AnimationEventInit extends EventInit {
    animationName?: string;
    elapsedTime?: number;
    pseudoElement?: string;
}
