import {UIEventInit} from "./ui_event_init";
import {TouchList} from "../input/touch_list";

// @ts-ignore
@Dictionary()
export interface TouchEventInit extends UIEventInit {
    altKey?: boolean;
    changedTouches?: TouchList;
    ctrlKey?: boolean;
    metaKey?: boolean;
    shiftKey?: boolean;
    targetTouches?: TouchList;
    touches?: TouchList;
}