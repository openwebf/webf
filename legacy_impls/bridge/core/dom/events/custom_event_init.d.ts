import { EventInit } from "./event_init";

// @ts-ignore
@Dictionary()
export interface CustomEventInit extends EventInit {
    detail?: any;
}
