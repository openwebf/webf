export interface IdleDeadline {
  readonly didTimeout: boolean;
  timeRemaining(): double;
  new(): void;
}