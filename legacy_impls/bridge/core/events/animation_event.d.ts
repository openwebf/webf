import {Event} from "../dom/events/event";
import {AnimationEventInit} from "./animation_event_init";

/** Events providing information related to animations. */
interface AnimationEvent extends Event {
    readonly animationName: string;
    readonly elapsedTime: number;
    readonly pseudoElement: string;
    [key: string]: any;
    new(type: string, init?: AnimationEventInit): AnimationEvent;
}