/** Events providing information related to animations. */
import {Event} from "./event";
import {CustomEventInit} from "./custom_event_init";

interface CustomEvent extends Event {
    readonly detail: any;

    [key: string]: any;
    initCustomEvent(type: string, canBubble?: boolean, cancelable?: boolean, detail?: any): void;

    new(type: string, init?: CustomEventInit): CustomEvent;
}