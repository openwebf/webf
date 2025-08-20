import { EventInit } from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface HashchangeEventInit extends EventInit {
    oldURL?: string;
    newURL?: string;
}
