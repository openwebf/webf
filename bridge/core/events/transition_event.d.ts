import {Event} from "../dom/events/event";
import {TransitionEventInit} from "./transition_event_init";
/** Events providing information related to transitions. */

interface TransitionEvent extends Event {
    readonly elapsedTime: number;
    readonly propertyName: string;
    readonly pseudoElement: string;
    [key: string]: any;
    new(type: string, init?: TransitionEventInit): TransitionEvent;
}