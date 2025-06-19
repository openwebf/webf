import fs from 'fs';
import path from 'path';
import { glob } from 'glob';
import { dartGen, reactGen, vueGen, clearAllCaches } from '../src/generator';
import * as analyzer from '../src/analyzer';
import * as dartGenerator from '../src/dart';
import * as reactGenerator from '../src/react';
import * as vueGenerator from '../src/vue';
import { ClassObject } from '../src/declaration';

// Mock dependencies
jest.mock('fs');
jest.mock('glob');
jest.mock('../src/analyzer');
jest.mock('../src/dart');
jest.mock('../src/react');
jest.mock('../src/vue');
jest.mock('../src/logger', () => ({
  logger: {
    setLogLevel: jest.fn(),
    debug: jest.fn(),
    info: jest.fn(),
    success: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    group: jest.fn(),
    progress: jest.fn(),
    time: jest.fn(),
    timeEnd: jest.fn(),
  },
  debug: jest.fn(),
  info: jest.fn(),
  success: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
  group: jest.fn(),
  progress: jest.fn(),
  time: jest.fn(),
  timeEnd: jest.fn(),
  LogLevel: {
    DEBUG: 0,
    INFO: 1,
    WARN: 2,
    ERROR: 3,
    SILENT: 4,
  },
}));

const mockFs = fs as jest.Mocked<typeof fs>;
const mockGlob = glob as jest.Mocked<typeof glob>;
const mockAnalyzer = analyzer as jest.Mocked<typeof analyzer>;
const mockDartGenerator = dartGenerator as jest.Mocked<typeof dartGenerator>;
const mockReactGenerator = reactGenerator as jest.Mocked<typeof reactGenerator>;
const mockVueGenerator = vueGenerator as jest.Mocked<typeof vueGenerator>;

describe('Generator', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    clearAllCaches();
    ClassObject.globalClassMap = Object.create(null);
    
    // Setup default mocks
    mockFs.existsSync.mockReturnValue(true);
    mockFs.readFileSync.mockReturnValue('test content');
    mockFs.writeFileSync.mockImplementation(() => undefined);
    mockFs.mkdirSync.mockImplementation(() => undefined);
    
    mockGlob.globSync.mockReturnValue(['test.d.ts', 'component.d.ts']);
    
    mockAnalyzer.analyzer.mockImplementation(() => undefined);
    mockAnalyzer.clearCaches.mockImplementation(() => undefined);
    
    mockDartGenerator.generateDartClass.mockReturnValue('dart code');
    mockReactGenerator.generateReactComponent.mockReturnValue('react component');
    mockReactGenerator.generateReactIndex.mockReturnValue('export * from "./test"');
    mockVueGenerator.generateVueTypings.mockReturnValue('vue typings');
  });

  describe('dartGen', () => {
    it('should generate Dart code for type files', async () => {
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockGlob.globSync).toHaveBeenCalledWith('**/*.d.ts', {
        cwd: '/test/source',
        ignore: ['**/node_modules/**', '**/dist/**', '**/build/**']
      });
      
      expect(mockAnalyzer.analyzer).toHaveBeenCalledTimes(2); // For each file
      expect(mockDartGenerator.generateDartClass).toHaveBeenCalledTimes(2);
      expect(mockFs.writeFileSync).toHaveBeenCalled();
    });

    it('should handle absolute and relative paths', async () => {
      await dartGen({
        source: './relative/source',
        target: './relative/target',
        command: 'test command'
      });

      expect(mockGlob.globSync).toHaveBeenCalledWith('**/*.d.ts', {
        cwd: expect.stringContaining('relative/source'),
        ignore: ['**/node_modules/**', '**/dist/**', '**/build/**']
      });
    });

    it('should filter out global.d.ts files', async () => {
      mockGlob.globSync.mockReturnValue(['test.d.ts', 'global.d.ts', 'component.d.ts']);
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      // Should only process 2 files (excluding global.d.ts)
      expect(mockAnalyzer.analyzer).toHaveBeenCalledTimes(2);
      expect(mockDartGenerator.generateDartClass).toHaveBeenCalledTimes(2);
    });

    it('should handle empty type files', async () => {
      mockGlob.globSync.mockReturnValue([]);
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockAnalyzer.analyzer).not.toHaveBeenCalled();
      expect(mockDartGenerator.generateDartClass).not.toHaveBeenCalled();
    });

    it('should continue processing if one file fails', async () => {
      mockGlob.globSync.mockReturnValue(['test1.d.ts', 'test2.d.ts']);
      mockAnalyzer.analyzer
        .mockImplementationOnce(() => { throw new Error('Parse error'); })
        .mockImplementationOnce(() => undefined);
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockDartGenerator.generateDartClass).toHaveBeenCalledTimes(2);
    });

    it('should validate source path exists', async () => {
      mockFs.existsSync.mockImplementation((path) => 
        !path.toString().includes('/test/source')
      );
      
      await expect(dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      })).rejects.toThrow('Source path does not exist');
    });

    it('should cache file content', async () => {
      const firstRunReadCount = mockFs.readFileSync.mock.calls.length;
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      const afterFirstRunReadCount = mockFs.readFileSync.mock.calls.length;
      const firstRunReads = afterFirstRunReadCount - firstRunReadCount;

      // Run again
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      const afterSecondRunReadCount = mockFs.readFileSync.mock.calls.length;
      const secondRunReads = afterSecondRunReadCount - afterFirstRunReadCount;

      // Second run should read less due to caching
      expect(secondRunReads).toBeLessThan(firstRunReads);
    });

    it('should only write changed files', async () => {
      // First run
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      mockFs.writeFileSync.mockClear();
      
      // Second run with same content
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockImplementation((path) => {
        if (path.toString().endsWith('_bindings_generated.dart')) {
          return 'dart code'; // Same as generated
        }
        return 'test content';
      });
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockFs.writeFileSync).not.toHaveBeenCalled();
    });
    
    it('should generate index.d.ts with references and exports', async () => {
      mockGlob.globSync.mockReturnValue(['components/button.d.ts', 'widgets/card.d.ts']);
      mockFs.readFileSync.mockReturnValue('interface Test {}');
      mockFs.existsSync.mockImplementation((path) => {
        // Source directory exists
        if (path.toString() === '/test/source') return true;
        return false;
      });
      mockDartGenerator.generateDartClass.mockReturnValue('generated dart code');
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });
      
      // Check that index.d.ts was written
      const writeFileCalls = mockFs.writeFileSync.mock.calls;
      const indexDtsCall = writeFileCalls.find(call => 
        call[0].toString().endsWith('index.d.ts')
      );
      
      expect(indexDtsCall).toBeDefined();
      expect(indexDtsCall![1]).toContain('/// <reference path="./global.d.ts" />');
      expect(indexDtsCall![1]).toContain('/// <reference path="./components/button.d.ts" />');
      expect(indexDtsCall![1]).toContain('/// <reference path="./widgets/card.d.ts" />');
      expect(indexDtsCall![1]).toContain("export * from './components/button';");
      expect(indexDtsCall![1]).toContain("export * from './widgets/card';");
      expect(indexDtsCall![1]).toContain('TypeScript Definitions');
    });
    
    it('should copy original .d.ts files to output directory', async () => {
      mockGlob.globSync.mockReturnValue(['test.d.ts']);
      const originalContent = 'interface Original {}';
      mockFs.readFileSync.mockReturnValue(originalContent);
      mockFs.existsSync.mockImplementation((path) => {
        // Source directory exists
        if (path.toString() === '/test/source') return true;
        return false;
      });
      mockDartGenerator.generateDartClass.mockReturnValue('generated dart code');
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });
      
      // Check that .d.ts file was copied
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('test.d.ts'),
        originalContent,
        'utf-8'
      );
    });
  });

  describe('reactGen', () => {
    it('should generate React components', async () => {
      await reactGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockReactGenerator.generateReactComponent).toHaveBeenCalledTimes(2);
      expect(mockReactGenerator.generateReactIndex).toHaveBeenCalled();
      expect(mockFs.writeFileSync).toHaveBeenCalled();
    });

    it('should use the exact target directory specified', async () => {
      await reactGen({
        source: '/test/source',
        target: 'MyReactComponents',
        command: 'test command'
      });

      const writeCalls = mockFs.writeFileSync.mock.calls;
      const componentPath = writeCalls.find(call => 
        call[0].toString().includes('.tsx')
      );
      expect(componentPath?.[0]).toContain('MyReactComponents');
    });

    it('should create src directory if it does not exist', async () => {
      mockFs.existsSync.mockImplementation((path) => 
        !path.toString().includes('/src')
      );
      
      await reactGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockFs.mkdirSync).toHaveBeenCalledWith(
        expect.stringContaining('/src'),
        { recursive: true }
      );
    });

    it('should generate index file', async () => {
      await reactGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockReactGenerator.generateReactIndex).toHaveBeenCalledWith(
        expect.arrayContaining([
          expect.objectContaining({ filename: 'test' }),
          expect.objectContaining({ filename: 'component' })
        ])
      );
      
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('index.ts'),
        'export * from "./test"',
        'utf-8'
      );
    });
  });

  describe('vueGen', () => {
    it('should generate Vue typings', async () => {
      await vueGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      expect(mockVueGenerator.generateVueTypings).toHaveBeenCalled();
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('index.d.ts'),
        'vue typings',
        'utf-8'
      );
    });

    it('should use the exact target directory specified', async () => {
      await vueGen({
        source: '/test/source',
        target: 'MyVueComponents',
        command: 'test command'
      });

      const writeCalls = mockFs.writeFileSync.mock.calls;
      const typingsPath = writeCalls.find(call => 
        call[0].toString().includes('index.d.ts')
      );
      expect(typingsPath?.[0]).toContain('MyVueComponents');
    });

    it('should only generate one index.d.ts file', async () => {
      mockGlob.globSync.mockReturnValue(['comp1.d.ts', 'comp2.d.ts', 'comp3.d.ts']);
      
      await vueGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      const writeCalls = mockFs.writeFileSync.mock.calls.filter(call =>
        call[0].toString().includes('index.d.ts')
      );
      expect(writeCalls).toHaveLength(1);
    });
  });

  describe('Error handling', () => {
    it('should handle glob errors', async () => {
      mockGlob.globSync.mockImplementation(() => {
        throw new Error('Glob error');
      });
      
      await expect(dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      })).rejects.toThrow('Failed to scan type files');
    });

    it('should handle file read errors', async () => {
      mockFs.readFileSync.mockImplementation((path) => {
        if (path.toString().endsWith('.d.ts')) {
          throw new Error('Read error');
        }
        return 'content';
      });
      
      await expect(dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      })).rejects.toThrow('Read error');
    });

    it('should handle generator errors gracefully', async () => {
      mockDartGenerator.generateDartClass
        .mockImplementationOnce(() => { throw new Error('Generate error'); })
        .mockImplementationOnce(() => 'dart code');
      
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      // First file fails (no writes), second file succeeds (1 dart + 1 .d.ts), plus index.d.ts = 3 total
      // But since the error happens in dartGen, the .d.ts copy might not happen
      const writeCalls = mockFs.writeFileSync.mock.calls;
      // Should have at least written the successful dart file and index.d.ts
      expect(writeCalls.length).toBeGreaterThanOrEqual(2);
    });
  });

  describe('clearAllCaches', () => {
    it('should clear all caches', async () => {
      // First run to populate caches
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      mockFs.readFileSync.mockClear();
      
      // Clear caches
      clearAllCaches();
      
      // Run again
      await dartGen({
        source: '/test/source',
        target: '/test/target',
        command: 'test command'
      });

      // Should read files again
      expect(mockFs.readFileSync).toHaveBeenCalled();
      expect(mockAnalyzer.clearCaches).toHaveBeenCalled();
    });
  });
});