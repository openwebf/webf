import {Event} from "../dom/events/event";
import {IntersectionChangeEventInit} from "./intersection_change_event_init";

interface IntersectionChangeEvent extends Event {
  readonly intersectionRatio: number;
  [key: string]: any;
  new(type: string, init?: IntersectionChangeEventInit): IntersectionChangeEventInit;
}
