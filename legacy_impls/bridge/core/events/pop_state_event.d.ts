import {Event} from "../dom/events/event";

interface PopStateEvent extends Event {
  readonly state: any;
  [key: string]: any;
  new(): PopStateEvent;
}