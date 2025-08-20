interface PerformanceMeasure extends PerformanceEntry {
  readonly detail: any;
  new(): void;
}