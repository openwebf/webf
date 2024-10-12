// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://www.w3.org/TR/intersection-observer/#intersection-observer-interface

// Copyright (C) 2024-present The WebF authors. All rights reserved.

import {IntersectionObserverInit} from "./intersection_observer_init";
import {IntersectionObserverEntry} from "./intersection_observer_entry";
import {Node} from "./node";
import {Element} from "./element";

//type IntersectionObserverCallback = (entries: IntersectionObserverEntry[], observer: IntersectionObserver)

interface IntersectionObserver {
  //new (callback: IntersectionObserverCallback, options?: IntersectionObserverInit): IntersectionObserver;
  new(callback: Function, options?: IntersectionObserverInit): IntersectionObserver;

  //readonly root: Node | null;
  //readonly rootMargin: string;
  //readonly scrollMargin: string;
  //readonly thresholds: number[];
  //readonly delay: number;
  //readonly trackVisibility: boolean;

  observe(target: Element): void;
  unobserve(target: Element): void;
  disconnect(): void;
  //takeRecords(): IntersectionObserverEntry[];
}
