export interface TestConfig {
  scope?: string;
  headless?: boolean;
  devtools?: boolean;
  parallel?: boolean;
  verbose?: boolean;
  viewport?: {
    width: number;
    height: number;
  };
  snapshots?: {
    enabled: boolean;
    updateSnapshots?: boolean;
    threshold?: number;
  };
  timeout?: number;
  retries?: number;
}

export interface TestResult {
  file: string;
  name: string;
  status: 'passed' | 'failed' | 'pending' | 'disabled';
  duration: number;
  error?: {
    message: string;
    stack?: string;
  };
  snapshot?: string; // Backward compatibility - first snapshot
  snapshots?: string[]; // All snapshots captured during the test
}

export interface TestScope {
  name: string;
  description: string;
  groups?: string[];
  include?: string[];
  exclude?: string[];
}

export interface TestReport {
  scope: string;
  timestamp: number;
  duration: number;
  results: TestResult[];
  summary: {
    total: number;
    passed: number;
    failed: number;
    skipped: number;
  };
}