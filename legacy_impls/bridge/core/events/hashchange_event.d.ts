import {Event} from "../dom/events/event";
import {GestureEventInit} from "./gesture_event_init";
import {HashchangeEventInit} from "./hashchange_event_init";

interface HashchangeEvent extends Event {
  readonly newURL: string;
  readonly oldURL: string;
  [key: string]: any;
  new(type: string, init?: HashchangeEventInit): HashchangeEvent;
}
