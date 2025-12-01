/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
interface PerformanceMark extends PerformanceEntry {
  readonly detail: any;
  new(): void;
}