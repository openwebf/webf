import {UIEvent} from "./ui_event";
import {InputEventInit} from "./input_event_init";

interface InputEvent extends UIEvent {
  readonly inputType: string;
  readonly data: string;
  [key: string]: any;
  new(type: string, init?: InputEventInit): InputEvent;
}
