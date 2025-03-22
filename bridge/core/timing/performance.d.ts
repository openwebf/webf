import {PerformanceMarkOptions} from "./performance_mark_options";
import {PerformanceMeasureOptions} from "./performance_measure_options";

interface Performance {
  now(): int64;
  __webf_navigation_summary__(): string;
  toJSON(): any;

  getEntries(): PerformanceEntry[];
  getEntriesByType(entryType: string): PerformanceEntry[];
  getEntriesByName(name: string, type?: string): PerformanceEntry[];

  mark(name: string, options?: PerformanceMarkOptions): void;
  // measure(name: string): void;
  // measure(name: string, startMark?: any): void;
  measure(name: string, startMark?: any, endMark?: string): void;
  clearMarks(name?: string): void;
  clearMeasures(name?: string): void;

  readonly timeOrigin: int64;
  new(): void;
}