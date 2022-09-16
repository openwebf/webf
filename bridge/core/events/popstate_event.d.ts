import {Event} from "../dom/events/event";

interface PopstateEvent extends Event {
  readonly state: any;
  new(): PopstateEvent;
}