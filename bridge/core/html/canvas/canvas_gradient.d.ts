/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
interface CanvasGradient {
  addColorStop(offset: double, color: string): SupportAsync<DartImpl<void>>;
  new(): void;
}