import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface HybridRouterChangeEventInit extends EventInit {
  from?: string;
  to?: string;
  state?: any;
}