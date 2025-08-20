import {Event} from "../dom/events/event";
import {CloseEventInit} from "./close_event_init";

interface CloseEvent extends Event {
    readonly code: int64;
    readonly reason: string;
    readonly wasClean: boolean;
    [key: string]: any;
    new(type: string, init?: CloseEventInit): CloseEvent;
}
