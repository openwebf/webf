import {Event} from "../dom/events/event";
import {PromiseRejectionEventInit} from "./promise_rejection_event_init";

interface PromiseRejectionEvent extends Event {
    readonly promise: any;
    readonly reason: any;
    [key: string]: any;
    new(eventType: string, init?: PromiseRejectionEventInit) : PromiseRejectionEvent;
}
