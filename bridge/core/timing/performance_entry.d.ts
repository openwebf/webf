/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
interface PerformanceEntry {
  readonly name: string;
  readonly entryType: string;
  readonly startTime: int64;
  readonly duration: int64;
  toJSON(): any;
  new(): void;
}