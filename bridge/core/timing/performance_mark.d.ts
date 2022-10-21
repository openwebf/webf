interface PerformanceMark extends PerformanceEntry {
  readonly detail: any;
  new(): void;
}