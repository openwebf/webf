/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/** A list of contact points on a touch surface. For example, if the user has three fingers on the touch surface (such as a screen or trackpad), the corresponding TouchList object would have one Touch object for each finger, for a total of three entries. */
import {Touch} from "./touch";

interface TouchList {
    readonly length: number;
    item(index: number): Touch | null;
    [index: number]: Touch;
    new(): void;
}