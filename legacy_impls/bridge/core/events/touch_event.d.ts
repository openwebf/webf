import {UIEvent} from "./ui_event";
import {EventTarget} from "../dom/events/event_target";
import {TouchList} from "../input/touch_list";
import {TouchEventInit} from "./touch_event_init";

/** An event sent when the state of contacts with a touch-sensitive surface changes. This surface can be a touch screen or trackpad, for example. The event can describe one or more points of contact with the screen and includes support for detecting movement, addition and removal of contact points, and so forth. */
interface TouchEvent extends UIEvent {
    readonly touches: TouchList;
    readonly targetTouches: TouchList;
    readonly changedTouches: TouchList;
    readonly altKey: boolean;
    readonly metaKey: boolean;
    readonly ctrlKey: boolean;
    readonly shiftKey: boolean;
    [key: string]: any;
    new(type: string, init?: TouchEventInit): TouchEvent;
}