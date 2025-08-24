export interface ComparisonResult {
  testName: string;
  testDescription: string;
  specFile: string;
  webfSnapshot: string;
  chromeSnapshot: string;
  diffImage?: string;
  pixelDifference: number;
  percentDifference: number;
  width: number;
  height: number;
}

export type ViewMode = 'grid' | 'slider';