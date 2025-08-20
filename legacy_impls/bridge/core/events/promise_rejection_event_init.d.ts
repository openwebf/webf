import { EventInit } from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface PromiseRejectionEventInit extends EventInit {
    promise: any;
    reason: any;
}
