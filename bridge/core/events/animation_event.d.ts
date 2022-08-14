import {Event} from "../dom/events/event";

/** Events providing information related to animations. */
interface AnimationEvent extends Event {
    readonly animationName: string;
    readonly elapsedTime: number;
    readonly pseudoElement: string;
}