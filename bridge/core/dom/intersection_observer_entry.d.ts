// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://wicg.github.io/IntersectionObserver/#intersection-observer-entry

// Copyright (C) 2024-present The WebF authors. All rights reserved.

import {Element} from "./element";

export interface IntersectionObserverEntry {
    readonly time: int64;
    readonly rootBounds: BoundingClientRect | null;
    readonly boundingClientRect: BoundingClientRect;
    readonly intersectionRect: BoundingClientRect;
    readonly isVisible: boolean;

    readonly isIntersecting: boolean;

    readonly intersectionRatio: number;

    readonly target: Element;

    new(): void;
}
