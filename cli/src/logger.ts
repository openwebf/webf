// Simplified logger without chalk dependency for now

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  SILENT = 4
}

class Logger {
  private logLevel: LogLevel = LogLevel.INFO;
  private debugMode: boolean = false;
  
  constructor() {
    // Check for debug environment variable
    this.debugMode = process.env.WEBF_DEBUG === 'true' || process.env.DEBUG === 'true';
    if (this.debugMode) {
      this.logLevel = LogLevel.DEBUG;
    }
  }
  
  setLogLevel(level: LogLevel) {
    this.logLevel = level;
  }
  
  debug(message: string, ...args: any[]) {
    if (this.logLevel <= LogLevel.DEBUG) {
      console.log(`[DEBUG] ${message}`, ...args);
    }
  }
  
  info(message: string, ...args: any[]) {
    if (this.logLevel <= LogLevel.INFO) {
      console.log(`ℹ ${message}`, ...args);
    }
  }
  
  success(message: string, ...args: any[]) {
    if (this.logLevel <= LogLevel.INFO) {
      console.log(`✓ ${message}`, ...args);
    }
  }
  
  warn(message: string, ...args: any[]) {
    if (this.logLevel <= LogLevel.WARN) {
      console.warn(`⚠ ${message}`, ...args);
    }
  }
  
  error(message: string, error?: Error | unknown) {
    if (this.logLevel <= LogLevel.ERROR) {
      console.error(`✗ ${message}`);
      if (error) {
        if (error instanceof Error) {
          console.error(error.stack || error.message);
        } else {
          console.error(String(error));
        }
      }
    }
  }
  
  group(title: string) {
    if (this.logLevel <= LogLevel.INFO) {
      console.log(`\n${title}`);
      console.log('─'.repeat(title.length));
    }
  }
  
  progress(current: number, total: number, message: string) {
    if (this.logLevel <= LogLevel.INFO) {
      const percentage = Math.round((current / total) * 100);
      const progressBar = this.createProgressBar(percentage);
      process.stdout.write(`\r${progressBar} ${percentage}% - ${message}`);
      if (current === total) {
        process.stdout.write('\n');
      }
    }
  }
  
  private createProgressBar(percentage: number): string {
    const width = 20;
    const filled = Math.round((percentage / 100) * width);
    const empty = width - filled;
    return `[${'█'.repeat(filled)}${'░'.repeat(empty)}]`;
  }
  
  time(label: string) {
    if (this.logLevel <= LogLevel.DEBUG) {
      console.time(`[TIMER] ${label}`);
    }
  }
  
  timeEnd(label: string) {
    if (this.logLevel <= LogLevel.DEBUG) {
      console.timeEnd(`[TIMER] ${label}`);
    }
  }
}

// Export singleton instance
export const logger = new Logger();

// Export convenience functions
export const debug = logger.debug.bind(logger);
export const info = logger.info.bind(logger);
export const success = logger.success.bind(logger);
export const warn = logger.warn.bind(logger);
export const error = logger.error.bind(logger);
export const group = logger.group.bind(logger);
export const progress = logger.progress.bind(logger);
export const time = logger.time.bind(logger);
export const timeEnd = logger.timeEnd.bind(logger);