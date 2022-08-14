import {Event} from "../dom/events/event";
/** Events providing information related to transitions. */

interface TransitionEvent extends Event {
    readonly elapsedTime: number;
    readonly propertyName: string;
    readonly pseudoElement: string;
}