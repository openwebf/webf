// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://wicg.github.io/IntersectionObserver/#intersection-observer-entry

// Copyright (C) 2024-present The WebF authors. All rights reserved.

import {Element} from "./element";

export interface IntersectionObserverEntry {
    // TODO(pengfei12.guo): DOMHighResTimeStamp not supported
    //readonly time: DOMHighResTimeStamp;

    // TODO(pengfei12.guo): DOMRectReadOnly not supported
    // TODO(szager): |rootBounds| should not be nullable.
    //readonly rootBounds: DOMRectReadOnly | null; // rootBounds 可以为 null
    //readonly boundingClientRect: DOMRectReadOnly;
    //readonly intersectionRect: DOMRectReadOnly;

    readonly isIntersecting: boolean;

    // TODO(pengfei12.guo): isVisible not supported
    //readonly isVisible: boolean;

    // TODO(pengfei12.guo): intersectionRatio not supported
    //readonly intersectionRatio: number;

    readonly target: Element;

    new(): void;
}


