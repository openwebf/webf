import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface TransitionEventInit extends EventInit {
    elapsedTime?: number;
    propertyName?: string;
    pseudoElement?: string;
}