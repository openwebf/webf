// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://wicg.github.io/IntersectionObserver/#intersection-observer-init

// Copyright (C) 2024-present The WebF authors. All rights reserved.

import {Node} from "./node";

// @ts-ignore
@Dictionary()
export interface IntersectionObserverInit {
  root?: Node | null; // 指定根(root)元素，用于检查目标的可见性。必须是目标元素的父级元素。
  rootMargin?: string; // 根(root)元素的外边距，用作 root 元素和 target 发生交集时候的计算交集的区域范围
  //scrollMargin?: string;
  threshold?: number[]; // 数组，该值为 1.0 含义是当 target 完全出现在 root 元素中时候回调才会被执行
  //delay?: number;
  //trackVisibility?: boolean;
}
