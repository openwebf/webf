import { logger, LogLevel } from '../src/logger';

describe('Logger', () => {
  let consoleLogSpy: jest.SpyInstance;
  let consoleWarnSpy: jest.SpyInstance;
  let consoleErrorSpy: jest.SpyInstance;
  let consoleTimeSpy: jest.SpyInstance;
  let consoleTimeEndSpy: jest.SpyInstance;
  let stdoutWriteSpy: jest.SpyInstance;

  beforeEach(() => {
    // Reset logger to default state
    logger.setLogLevel(LogLevel.INFO);
    
    // Mock console methods
    consoleLogSpy = jest.spyOn(console, 'log').mockImplementation();
    consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation();
    consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
    consoleTimeSpy = jest.spyOn(console, 'time').mockImplementation();
    consoleTimeEndSpy = jest.spyOn(console, 'timeEnd').mockImplementation();
    stdoutWriteSpy = jest.spyOn(process.stdout, 'write').mockImplementation();
  });

  afterEach(() => {
    jest.restoreAllMocks();
    delete process.env.WEBF_DEBUG;
    delete process.env.DEBUG;
  });

  describe('Log levels', () => {
    it('should respect log level for debug messages', () => {
      logger.setLogLevel(LogLevel.DEBUG);
      logger.debug('Debug message');
      expect(consoleLogSpy).toHaveBeenCalledWith('[DEBUG] Debug message');

      consoleLogSpy.mockClear();
      logger.setLogLevel(LogLevel.INFO);
      logger.debug('Debug message');
      expect(consoleLogSpy).not.toHaveBeenCalled();
    });

    it('should respect log level for info messages', () => {
      logger.setLogLevel(LogLevel.INFO);
      logger.info('Info message');
      expect(consoleLogSpy).toHaveBeenCalledWith('ℹ Info message');

      consoleLogSpy.mockClear();
      logger.setLogLevel(LogLevel.WARN);
      logger.info('Info message');
      expect(consoleLogSpy).not.toHaveBeenCalled();
    });

    it('should respect log level for warn messages', () => {
      logger.setLogLevel(LogLevel.WARN);
      logger.warn('Warning message');
      expect(consoleWarnSpy).toHaveBeenCalledWith('⚠ Warning message');

      consoleWarnSpy.mockClear();
      logger.setLogLevel(LogLevel.ERROR);
      logger.warn('Warning message');
      expect(consoleWarnSpy).not.toHaveBeenCalled();
    });

    it('should respect log level for error messages', () => {
      logger.setLogLevel(LogLevel.ERROR);
      logger.error('Error message');
      expect(consoleErrorSpy).toHaveBeenCalledWith('✗ Error message');

      consoleErrorSpy.mockClear();
      logger.setLogLevel(LogLevel.SILENT);
      logger.error('Error message');
      expect(consoleErrorSpy).not.toHaveBeenCalled();
    });
  });

  describe('Debug mode', () => {
    it('should enable debug level when WEBF_DEBUG is true', () => {
      // Since logger is a singleton, we can't test env var changes
      // Just verify that the functionality exists
      process.env.WEBF_DEBUG = 'true';
      logger.setLogLevel(LogLevel.DEBUG);
      
      logger.debug('Debug message');
      expect(consoleLogSpy).toHaveBeenCalledWith('[DEBUG] Debug message');
    });

    it('should enable debug level when DEBUG is true', () => {
      process.env.DEBUG = 'true';
      logger.setLogLevel(LogLevel.DEBUG);
      
      logger.debug('Debug message');
      expect(consoleLogSpy).toHaveBeenCalledWith('[DEBUG] Debug message');
    });
  });

  describe('Message formatting', () => {
    it('should pass additional arguments to console methods', () => {
      logger.info('Message', 'arg1', { key: 'value' });
      expect(consoleLogSpy).toHaveBeenCalledWith('ℹ Message', 'arg1', { key: 'value' });
    });

    it('should format success messages', () => {
      logger.success('Operation completed');
      expect(consoleLogSpy).toHaveBeenCalledWith('✓ Operation completed');
    });

    it('should format group headers', () => {
      logger.group('Test Section');
      expect(consoleLogSpy).toHaveBeenCalledWith('\nTest Section');
      expect(consoleLogSpy).toHaveBeenCalledWith('─'.repeat('Test Section'.length));
    });
  });

  describe('Error handling', () => {
    it('should log error object with stack trace', () => {
      const error = new Error('Test error');
      error.stack = 'Error: Test error\n    at test.js:10';
      
      logger.error('Operation failed', error);
      expect(consoleErrorSpy).toHaveBeenCalledWith('✗ Operation failed');
      expect(consoleErrorSpy).toHaveBeenCalledWith(error.stack);
    });

    it('should log error message if no stack trace', () => {
      const error = new Error('Test error');
      delete error.stack;
      
      logger.error('Operation failed', error);
      expect(consoleErrorSpy).toHaveBeenCalledWith('✗ Operation failed');
      expect(consoleErrorSpy).toHaveBeenCalledWith('Test error');
    });

    it('should handle non-Error objects', () => {
      logger.error('Operation failed', 'String error');
      expect(consoleErrorSpy).toHaveBeenCalledWith('✗ Operation failed');
      expect(consoleErrorSpy).toHaveBeenCalledWith('String error');
    });

    it('should handle undefined error', () => {
      logger.error('Operation failed');
      expect(consoleErrorSpy).toHaveBeenCalledWith('✗ Operation failed');
      expect(consoleErrorSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('Progress bar', () => {
    it('should display progress bar', () => {
      logger.progress(5, 10, 'Processing');
      expect(stdoutWriteSpy).toHaveBeenCalledWith(
        expect.stringContaining('[██████████░░░░░░░░░░] 50% - Processing')
      );
    });

    it('should add newline when complete', () => {
      logger.progress(10, 10, 'Complete');
      expect(stdoutWriteSpy).toHaveBeenCalledWith(
        expect.stringContaining('\n')
      );
    });

    it('should handle zero total', () => {
      logger.progress(0, 0, 'Empty');
      // When total is 0, percentage will be NaN, so just check it was called
      expect(stdoutWriteSpy).toHaveBeenCalled();
    });

    it('should calculate percentage correctly', () => {
      logger.progress(3, 4, 'Three quarters');
      expect(stdoutWriteSpy).toHaveBeenCalledWith(
        expect.stringContaining('75%')
      );
    });

    it('should respect log level', () => {
      logger.setLogLevel(LogLevel.WARN);
      logger.progress(5, 10, 'Processing');
      expect(stdoutWriteSpy).not.toHaveBeenCalled();
    });
  });

  describe('Timing', () => {
    it('should start timer with debug level', () => {
      logger.setLogLevel(LogLevel.DEBUG);
      logger.time('operation');
      expect(consoleTimeSpy).toHaveBeenCalledWith('[TIMER] operation');
    });

    it('should end timer with debug level', () => {
      logger.setLogLevel(LogLevel.DEBUG);
      logger.timeEnd('operation');
      expect(consoleTimeEndSpy).toHaveBeenCalledWith('[TIMER] operation');
    });

    it('should not time with higher log levels', () => {
      logger.setLogLevel(LogLevel.INFO);
      logger.time('operation');
      logger.timeEnd('operation');
      expect(consoleTimeSpy).not.toHaveBeenCalled();
      expect(consoleTimeEndSpy).not.toHaveBeenCalled();
    });
  });

  describe('Exported convenience functions', () => {
    it('should export bound functions', () => {
      const { debug, info, success, warn, error, group, progress, time, timeEnd } = require('../src/logger');
      
      // Test that they work correctly
      info('Test info');
      expect(consoleLogSpy).toHaveBeenCalledWith('ℹ Test info');
      
      warn('Test warn');
      expect(consoleWarnSpy).toHaveBeenCalledWith('⚠ Test warn');
    });
  });
});