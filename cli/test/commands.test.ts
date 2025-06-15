// Mock fs before importing commands
jest.mock('fs');
jest.mock('child_process');
jest.mock('../src/generator');

import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';

const mockFs = fs as jest.Mocked<typeof fs>;
const mockSpawnSync = spawnSync as jest.MockedFunction<typeof spawnSync>;

// Set up default mocks before importing commands
mockFs.readFileSync = jest.fn().mockImplementation((filePath: any) => {
  const pathStr = filePath.toString();
  if (pathStr.includes('global.d.ts')) return 'global.d.ts content';
  if (pathStr.includes('gitignore.tpl')) return 'gitignore template';
  if (pathStr.includes('react.package.json.tpl')) return '<%= packageName %>';
  if (pathStr.includes('react.tsconfig.json.tpl')) return 'react tsconfig';
  if (pathStr.includes('react.tsup.config.ts.tpl')) return 'tsup config';
  if (pathStr.includes('react.createComponent.tpl')) return 'create component';
  if (pathStr.includes('react.index.ts.tpl')) return 'index template';
  if (pathStr.includes('vue.package.json.tpl')) return '<%= packageName %>';
  if (pathStr.includes('vue.tsconfig.json.tpl')) return 'vue tsconfig';
  // This should come after more specific checks
  if (pathStr.includes('tsconfig.json.tpl')) return 'tsconfig template';
  return '';
});

// Now import commands after mocks are set up
import { initCommand, createCommand, generateCommand } from '../src/commands';
import * as generator from '../src/generator';

const mockGenerator = generator as jest.Mocked<typeof generator>;

describe('Commands', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Setup default mocks
    mockFs.existsSync.mockReturnValue(false);
    mockFs.mkdirSync.mockImplementation(() => undefined);
    mockFs.writeFileSync.mockImplementation(() => undefined);
    mockSpawnSync.mockReturnValue({
      pid: 1234,
      output: [],
      stdout: Buffer.from(''),
      stderr: Buffer.from(''),
      status: 0,
      signal: null,
    });
  });

  describe('initCommand', () => {
    it('should create typings directory and write files', () => {
      const targetPath = '/test/path';
      
      initCommand(targetPath);

      expect(mockFs.mkdirSync).toHaveBeenCalledWith(
        path.resolve(targetPath),
        { recursive: true }
      );
      // Just check that writeFileSync was called with the correct paths
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('global.d.ts'),
        'global.d.ts content',
        'utf-8'
      );
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('tsconfig.json'),
        'tsconfig template',
        'utf-8'
      );
    });

    it('should log success message', () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
      const targetPath = '/test/path';
      
      initCommand(targetPath);

      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('WebF typings initialized:')
      );
      
      consoleSpy.mockRestore();
    });
  });

  describe('createCommand', () => {
    describe('React framework', () => {
      it('should create React project structure', () => {
        const target = '/test/react-project';
        const options = { framework: 'react', packageName: 'test-package' };
        
        createCommand(target, options);

        // Check directory creation
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(target, { recursive: true });
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(
          path.join(target, 'src'),
          { recursive: true }
        );
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(
          path.join(target, 'src', 'utils'),
          { recursive: true }
        );
      });

      it('should write React configuration files', () => {
        const target = '/test/react-project';
        const options = { framework: 'react', packageName: 'test-package' };
        
        // Mock file doesn't exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === target) return false;
          if (pathStr.includes('/src')) return false;
          return true;
        });
        
        createCommand(target, options);

        // Check package.json was written with processed content
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          path.join(target, 'package.json'),
          'test-package',
          'utf-8'
        );
      });

      it('should run npm install', () => {
        const target = '/test/react-project';
        const options = { framework: 'react', packageName: 'test-package' };
        
        createCommand(target, options);

        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['install', '--omit=peer'],
          { cwd: target, stdio: 'inherit' }
        );
      });
    });

    describe('Vue framework', () => {
      it('should create Vue project structure', () => {
        const target = '/test/vue-project';
        const options = { framework: 'vue', packageName: 'test-vue-package' };
        
        createCommand(target, options);

        // Check directory creation
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(target, { recursive: true });
      });

      it('should write Vue configuration files', () => {
        const target = '/test/vue-project';
        const options = { framework: 'vue', packageName: 'test-vue-package' };
        
        createCommand(target, options);

        // Check package.json was written with processed content
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          path.join(target, 'package.json'),
          'test-vue-package',
          'utf-8'
        );

        // Check tsconfig.json
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          path.join(target, 'tsconfig.json'),
          'vue tsconfig',
          'utf-8'
        );
      });

      it('should run npm install commands for Vue', () => {
        const target = '/test/vue-project';
        const options = { framework: 'vue', packageName: 'test-vue-package' };
        
        createCommand(target, options);

        // Should install WebF typings
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['install', '@openwebf/webf-enterprise-typings'],
          { cwd: target, stdio: 'inherit' }
        );

        // Should install Vue types as dev dependency
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['install', '@types/vue', '-D'],
          { cwd: target, stdio: 'inherit' }
        );
      });
    });

    it('should skip writing files that already have same content', () => {
      const target = '/test/project';
      const options = { framework: 'react', packageName: 'test-package' };
      
      // Mock file exists with same content
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        // Package.json exists, but other files don't
        return pathStr.includes('package.json') && !pathStr.includes('.tpl');
      });
      const originalReadFileSync = mockFs.readFileSync;
      mockFs.readFileSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
          return 'test-package'; // Same as generated content
        }
        // Use original mock for template files
        return originalReadFileSync(filePath);
      });
      
      createCommand(target, options);

      // Check that some files were written but not the ones that already exist with same content
      const writeFileCalls = (mockFs.writeFileSync as jest.Mock).mock.calls;
      // At least some files should be written (index.ts, createComponent.ts, etc.)
      expect(writeFileCalls.length).toBeGreaterThan(0);
      // But none should be package.json since it already exists with same content
      const packageJsonCalls = writeFileCalls.filter(call => 
        call[0].toString().includes('package.json') && !call[0].toString().includes('.tpl')
      );
      expect(packageJsonCalls).toHaveLength(0);
    });
  });

  describe('generateCommand', () => {
    beforeEach(() => {
      mockGenerator.dartGen.mockResolvedValue(undefined);
      mockGenerator.reactGen.mockResolvedValue(undefined);
      mockGenerator.vueGen.mockResolvedValue(undefined);
    });

    it('should always call dartGen', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react'
      };
      
      await generateCommand('/dist', options);

      expect(mockGenerator.dartGen).toHaveBeenCalledWith({
        source: '/flutter/src',
        target: '/flutter/src',
        command: expect.stringContaining('webf codegen generate')
      });
    });

    it('should call reactGen for React framework', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react'
      };
      
      // Mock package.json exists
      mockFs.existsSync.mockImplementation((filePath) => 
        filePath.toString().includes('package.json')
      );
      
      await generateCommand('/dist', options);

      expect(mockGenerator.reactGen).toHaveBeenCalledWith({
        source: '/flutter/src',
        target: '/dist',
        command: expect.stringContaining('webf codegen generate')
      });
    });

    it('should error if package.json not found for React', async () => {
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react'
      };
      
      // Mock package.json doesn't exist
      mockFs.existsSync.mockReturnValue(false);
      
      await generateCommand('/dist', options);

      expect(mockGenerator.reactGen).not.toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('package.json not found')
      );
      
      consoleSpy.mockRestore();
    });

    it('should call vueGen for Vue framework', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'vue'
      };
      
      await generateCommand('/dist', options);

      expect(mockGenerator.vueGen).toHaveBeenCalledWith({
        source: '/flutter/src',
        target: '/dist',
        command: expect.stringContaining('webf codegen generate')
      });
    });
  });
});