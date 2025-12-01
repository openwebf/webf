/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
export interface IdleDeadline {
  readonly didTimeout: boolean;
  timeRemaining(): double;
  new(): void;
}