interface PerformanceEntry {
  readonly name: string;
  readonly entryType: string;
  readonly startTime: int64;
  readonly duration: int64;
  toJSON(): any;
  new(): void;
}