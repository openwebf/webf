import {UIEvent} from "./ui_event";
import {KeyboardEventInit} from "./keyboard_event_init";

/** KeyboardEvent objects describe a user interaction with the keyboard; each event describes a single interaction between the user and a key (or combination of a key with modifier keys) on the keyboard. */
interface KeyboardEvent extends UIEvent {
    readonly altKey: boolean;
    /** @deprecated */
    readonly charCode: number;
    readonly code: string;
    readonly ctrlKey: boolean;
    readonly isComposing: boolean;
    readonly key: string;
    /** @deprecated */
    readonly keyCode: number;
    readonly location: number;
    readonly metaKey: boolean;
    readonly repeat: boolean;
    readonly shiftKey: boolean;
    // getModifierState(keyArg: string): boolean;
    readonly DOM_KEY_LOCATION_LEFT: StaticMember<number>;
    readonly DOM_KEY_LOCATION_NUMPAD: StaticMember<number>;
    readonly DOM_KEY_LOCATION_RIGHT: StaticMember<number>;
    readonly DOM_KEY_LOCATION_STANDARD: StaticMember<number>;
    [key: string]: any;

    new(type: string, init?: KeyboardEventInit): KeyboardEvent;
}