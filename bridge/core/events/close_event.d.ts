import {Event} from "../dom/events/event";

interface CloseEvent extends Event {
    readonly code: int64;
    readonly reason: string;
    readonly wasClean: boolean;
}
