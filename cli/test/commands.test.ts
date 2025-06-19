// Mock fs before importing commands
jest.mock('fs');
jest.mock('child_process');
jest.mock('../src/generator');
jest.mock('inquirer');
jest.mock('yaml');

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
  if (pathStr.includes('react.package.json.tpl')) return '<%= packageName %> <%= version %> <%= description %>';
  if (pathStr.includes('react.tsconfig.json.tpl')) return 'react tsconfig';
  if (pathStr.includes('react.tsup.config.ts.tpl')) return 'tsup config';
  if (pathStr.includes('react.createComponent.tpl')) return 'create component';
  if (pathStr.includes('react.index.ts.tpl')) return 'index template';
  if (pathStr.includes('vue.package.json.tpl')) return '<%= packageName %> <%= version %> <%= description %>';
  if (pathStr.includes('vue.tsconfig.json.tpl')) return 'vue tsconfig';
  // This should come after more specific checks
  if (pathStr.includes('tsconfig.json.tpl')) return 'tsconfig template';
  if (pathStr.includes('pubspec.yaml')) return 'name: test\nversion: 1.0.0\ndescription: Test description';
  return '';
});

// Now import commands after mocks are set up
import { generateCommand } from '../src/commands';
import * as generator from '../src/generator';
import inquirer from 'inquirer';
import yaml from 'yaml';

const mockGenerator = generator as jest.Mocked<typeof generator>;
const mockInquirer = inquirer as jest.Mocked<typeof inquirer>;
const mockYaml = yaml as jest.Mocked<typeof yaml>;

describe('Commands', () => {
  // Helper function to mock TypeScript environment validation
  const mockTypeScriptValidation = (path: string) => {
    mockFs.existsSync.mockImplementation((filePath) => {
      const pathStr = filePath.toString();
      if (pathStr === `${path}/tsconfig.json`) return true;
      if (pathStr === `${path}/lib`) return true;
      if (pathStr.includes('pubspec.yaml')) return true;
      return false;
    });
    
    mockFs.readdirSync.mockImplementation((dirPath: any) => {
      if (dirPath.toString() === `${path}/lib`) {
        return ['component.d.ts'] as any;
      }
      return [] as any;
    });
    
    mockFs.statSync.mockReturnValue({ isDirectory: () => false } as any);
  };

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
    // Default mock for inquirer
    mockInquirer.prompt.mockResolvedValue({});
    // Default mock for yaml
    mockYaml.parse.mockReturnValue({
      name: 'test_package',
      version: '1.0.0',
      description: 'Test Flutter package description'
    });
    // Default mock for readdirSync to avoid undefined
    mockFs.readdirSync.mockReturnValue([] as any);
  });


  describe('generateCommand with auto-creation', () => {
    let mockExit: jest.SpyInstance;
    let consoleSpy: jest.SpyInstance;
    
    beforeEach(() => {
      mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
        throw new Error('process.exit called');
      });
      consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    });
    
    afterEach(() => {
      mockExit.mockRestore();
      consoleSpy.mockRestore();
    });
    
    describe('React framework - new project', () => {
      it('should create React project structure when package.json is missing', async () => {
        const target = '/test/react-project';
        const options = { framework: 'react', packageName: 'test-package' };
        
        // Mock that required files don't exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          // The target directory exists but the required files don't
          if (pathStr === path.resolve(target)) return true;
          return false;
        });
        
        await generateCommand(target, options);

        // Should log creation message
        expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Creating new react project'));

        // Check directory creation for src folders (target already exists)
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(
          path.join(path.resolve(target), 'src'),
          { recursive: true }
        );
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(
          path.join(path.resolve(target), 'src', 'utils'),
          { recursive: true }
        );
      });

      it('should prompt for framework and package name when missing', async () => {
        const target = '/test/react-project';
        const options = {};
        
        // Mock that required files don't exist
        mockFs.existsSync.mockReturnValue(false);
        
        // Mock inquirer prompts
        mockInquirer.prompt
          .mockResolvedValueOnce({ framework: 'react' })
          .mockResolvedValueOnce({ packageName: 'test-package' });
        
        await generateCommand(target, options);
        
        // Should have prompted for framework and package name
        expect(mockInquirer.prompt).toHaveBeenCalledTimes(2);
        expect(mockInquirer.prompt).toHaveBeenCalledWith([{
          type: 'list',
          name: 'framework',
          message: 'Which framework would you like to use?',
          choices: ['react', 'vue']
        }]);
        expect(mockInquirer.prompt).toHaveBeenNthCalledWith(2, [{
          type: 'input',
          name: 'packageName',
          message: 'What is your package name?',
          default: 'react-project',
          validate: expect.any(Function)
        }]);

        // Check package.json was written with processed content
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          path.join(target, 'package.json'),
          'test-package 0.0.1 ',
          'utf-8'
        );
      });
      
      it('should use Flutter package name as default when available', async () => {
        const target = '/test/react-project';
        const options = { flutterPackageSrc: '/flutter/src' };
        
        // Mock that required files don't exist except pubspec.yaml and TypeScript files
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('pubspec.yaml')) return true;
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          return false;
        });
        
        // Mock .d.ts files exist
        mockFs.readdirSync.mockImplementation((dirPath: any) => {
          if (dirPath.toString() === '/flutter/src/lib') {
            return ['component.d.ts'] as any;
          }
          return [] as any;
        });
        
        mockFs.statSync.mockReturnValue({ isDirectory: () => false } as any);
        
        // Mock yaml parse to return Flutter package info
        mockYaml.parse.mockReturnValue({
          name: 'flutter_awesome_widget',
          version: '2.0.0',
          description: 'An awesome Flutter widget'
        });
        
        // Mock inquirer prompts
        mockInquirer.prompt
          .mockResolvedValueOnce({ framework: 'react' })
          .mockResolvedValueOnce({ packageName: 'flutter_awesome_widget' });
        
        await generateCommand(target, options);
        
        // Should have prompted with Flutter package name as default
        expect(mockInquirer.prompt).toHaveBeenNthCalledWith(2, [{
          type: 'input',
          name: 'packageName',
          message: 'What is your package name?',
          default: 'flutter_awesome_widget',
          validate: expect.any(Function)
        }]);
      });

      it('should run npm install when creating new project', async () => {
        const target = '/test/react-project';
        const options = { framework: 'react', packageName: 'test-package' };
        
        // Mock that required files don't exist
        mockFs.existsSync.mockReturnValue(false);
        
        await generateCommand(target, options);

        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['install', '--omit=peer'],
          { cwd: target, stdio: 'inherit' }
        );
      });
    });

    describe('Vue framework - new project', () => {
      it('should create Vue project structure when files are missing', async () => {
        const target = '/test/vue-project';
        const options = { framework: 'vue', packageName: 'test-vue-package' };
        
        // Mock that required files don't exist
        mockFs.existsSync.mockReturnValue(false);
        
        await generateCommand(target, options);

        // Check directory creation
        expect(mockFs.mkdirSync).toHaveBeenCalledWith(path.resolve(target), { recursive: true });
      });

      it('should write Vue configuration files', async () => {
        const target = '/test/vue-project';
        const options = { framework: 'vue', packageName: 'test-vue-package' };
        
        // Mock that required files don't exist
        mockFs.existsSync.mockReturnValue(false);
        
        await generateCommand(target, options);

        // Check package.json was written with processed content
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          path.join(target, 'package.json'),
          'test-vue-package 0.0.1 ',
          'utf-8'
        );

        // Check tsconfig.json
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          path.join(target, 'tsconfig.json'),
          'vue tsconfig',
          'utf-8'
        );
      });

      it('should run npm install commands for Vue', async () => {
        const target = '/test/vue-project';
        const options = { framework: 'vue', packageName: 'test-vue-package' };
        
        // Mock that required files don't exist
        mockFs.existsSync.mockReturnValue(false);
        
        await generateCommand(target, options);

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

    it('should detect existing project and skip creation', async () => {
      const target = '/test/project';
      const options = { framework: 'react', flutterPackageSrc: '/flutter/src' };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      // Mock all required files exist
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        // Project files exist
        if (pathStr.includes(target)) return true;
        // TypeScript validation files
        if (pathStr === '/flutter/src/tsconfig.json') return true;
        if (pathStr === '/flutter/src/lib') return true;
        if (pathStr.includes('pubspec.yaml')) return true;
        return true;
      });
      
      mockFs.readFileSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
          return JSON.stringify({ dependencies: { react: '^18.0.0' } });
        }
        return '';
      });
      
      await generateCommand(target, options);
      
      // Should detect existing React project
      expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Detected existing react project'));
      
      // Should not create new files
      const writeFileCallsForExisting = (mockFs.writeFileSync as jest.Mock).mock.calls;
      const projectFileCalls = writeFileCallsForExisting.filter(call => {
        const path = call[0].toString();
        return path.includes('package.json') && !path.includes('.tpl');
      });
      expect(projectFileCalls).toHaveLength(0);

    });

  });

  describe('generateCommand with code generation', () => {
    let mockExit: jest.SpyInstance;
    let consoleSpy: jest.SpyInstance;
    
    beforeEach(() => {
      mockGenerator.dartGen.mockResolvedValue(undefined);
      mockGenerator.reactGen.mockResolvedValue(undefined);
      mockGenerator.vueGen.mockResolvedValue(undefined);
      mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
        throw new Error('process.exit called');
      });
      consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    });
    
    afterEach(() => {
      mockExit.mockRestore();
      consoleSpy.mockRestore();
    });

    it('should show instructions when --flutter-package-src is missing', async () => {
      const options = { framework: 'react' };
      
      // Don't auto-detect Flutter package for this test
      const cwdSpy = jest.spyOn(process, 'cwd').mockReturnValue('/non-flutter-dir');
      
      // Mock all required files exist except pubspec.yaml
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        // No pubspec.yaml files should exist
        if (pathStr.includes('pubspec.yaml')) return false;
        // But other project files exist
        if (pathStr.includes('/dist')) return true;
        return true;
      });
      
      mockFs.readFileSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
          return JSON.stringify({ dependencies: { react: '^18.0.0' } });
        }
        return '';
      });
      
      await generateCommand('/dist', options);
      
      expect(consoleSpy).toHaveBeenCalledWith('\nProject is ready for code generation.');
      expect(consoleSpy).toHaveBeenCalledWith('To generate code, run:');
      expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('webf codegen generate'));
      
      cwdSpy.mockRestore();
    });

    it('should always call dartGen', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react',
        packageName: 'test-package'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
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
        framework: 'react',
        packageName: 'test-package'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      await generateCommand('/dist', options);

      expect(mockGenerator.reactGen).toHaveBeenCalledWith({
        source: '/flutter/src',
        target: path.resolve('/dist'),
        command: expect.stringContaining('webf codegen generate')
      });
    });

    it('should create new project if package.json not found', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react',
        packageName: 'new-project'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      await generateCommand('/dist', options);

      // Should create project files
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('package.json'),
        expect.any(String),
        'utf-8'
      );
      
      // Should still run code generation after creation
      expect(mockGenerator.dartGen).toHaveBeenCalled();
      expect(mockGenerator.reactGen).toHaveBeenCalled();
    });
    
    it('should detect framework from existing package.json', async () => {
      const options = { flutterPackageSrc: '/flutter/src' };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      // Mock all required files exist
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr === '/flutter/src/tsconfig.json') return true;
        if (pathStr === '/flutter/src/lib') return true;
        if (pathStr.includes('pubspec.yaml')) return true;
        return true;
      });
      
      mockFs.readFileSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
          return JSON.stringify({ dependencies: { vue: '^3.0.0' } });
        }
        return '';
      });
      
      await generateCommand('/dist', options);
      
      expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Detected existing vue project'));
      expect(mockGenerator.vueGen).toHaveBeenCalled();
    });
    
    it('should prompt for framework if cannot detect from package.json', async () => {
      const options = { flutterPackageSrc: '/flutter/src' };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      // Mock all required files exist
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr === '/flutter/src/tsconfig.json') return true;
        if (pathStr === '/flutter/src/lib') return true;
        if (pathStr.includes('pubspec.yaml')) return true;
        return true;
      });
      
      mockFs.readFileSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
          return JSON.stringify({ name: 'test-project' });
        }
        return '';
      });
      
      // Mock inquirer prompt
      mockInquirer.prompt.mockResolvedValueOnce({ framework: 'react' });
      
      await generateCommand('/dist', options);
      
      expect(mockInquirer.prompt).toHaveBeenCalledWith([{
        type: 'list',
        name: 'framework',
        message: 'Which framework are you using?',
        choices: ['react', 'vue']
      }]);
      expect(mockGenerator.reactGen).toHaveBeenCalled();
    });

    it('should call vueGen for Vue framework', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'vue',
        packageName: 'test-package'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      await generateCommand('/dist', options);

      expect(mockGenerator.vueGen).toHaveBeenCalledWith({
        source: '/flutter/src',
        target: path.resolve('/dist'),
        command: expect.stringContaining('webf codegen generate')
      });
    });

    it('should auto-initialize typings if not present', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react',
        packageName: 'test-package'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      // Mock that init files don't exist in dist but TypeScript validation passes
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        // TypeScript validation files
        if (pathStr === '/flutter/src/tsconfig.json') return true;
        if (pathStr === '/flutter/src/lib') return true;
        if (pathStr.includes('pubspec.yaml')) return true;
        // Dist files don't exist
        if (pathStr.includes('/dist') && (pathStr.includes('global.d.ts') || pathStr.includes('tsconfig.json'))) {
          return false;
        }
        return pathStr.includes('package.json');
      });
      
      await generateCommand('/dist', options);

      // Should create directory
      expect(mockFs.mkdirSync).toHaveBeenCalledWith(path.resolve('/dist'), { recursive: true });
      
      // Should write init files
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        path.join(path.resolve('/dist'), 'global.d.ts'),
        'global.d.ts content',
        'utf-8'
      );
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        path.join(path.resolve('/dist'), 'tsconfig.json'),
        'tsconfig template',
        'utf-8'
      );
    });

    it('should not re-initialize if typings already exist', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      // Mock that all files exist
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr === '/flutter/src/tsconfig.json') return true;
        if (pathStr === '/flutter/src/lib') return true;
        return true;
      });
      
      mockFs.readFileSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
          return JSON.stringify({ dependencies: { react: '^18.0.0' } });
        }
        return '';
      });
      
      await generateCommand('/dist', options);

      // Should not create directory or write init files
      const writeFileCalls = (mockFs.writeFileSync as jest.Mock).mock.calls;
      const initFileCalls = writeFileCalls.filter(call => {
        const path = call[0].toString();
        return path.includes('global.d.ts') || (path.includes('tsconfig.json') && !path.includes('.tpl'));
      });
      
      expect(initFileCalls).toHaveLength(0);
    });
    
    it('should use Flutter package metadata when creating project', async () => {
      const options = {
        flutterPackageSrc: '/flutter/src',
        framework: 'react',
        packageName: 'test-package'
      };
      
      // Mock TypeScript validation
      mockTypeScriptValidation('/flutter/src');
      
      // Mock that required files don't exist to trigger creation
      mockFs.existsSync.mockImplementation((filePath) => {
        const pathStr = filePath.toString();
        if (pathStr.includes('pubspec.yaml')) return true;
        if (pathStr === '/flutter/src/tsconfig.json') return true;
        if (pathStr === '/flutter/src/lib') return true;
        return false;
      });
      
      await generateCommand('/dist', options);
      
      // Check that package.json was written with metadata
      expect(mockFs.writeFileSync).toHaveBeenCalledWith(
        expect.stringContaining('package.json'),
        expect.stringContaining('test-package 1.0.0 Test Flutter package description'),
        'utf-8'
      );
    });
    
    describe('npm publishing', () => {
      it('should build and publish package when --publish-to-npm is set', async () => {
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package',
          publishToNpm: true
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock all required files exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          if (pathStr.includes('pubspec.yaml')) return true;
          if (pathStr.includes('package.json')) return true;
          if (pathStr.includes('global.d.ts')) return true;
          if (pathStr.includes('tsconfig.json')) return true;
          return false;
        });
        
        // Mock package.json with build script
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              dependencies: { react: '^18.0.0' },
              scripts: { build: 'tsup' }
            });
          }
          return '';
        });
        
        // Mock npm whoami success
        mockSpawnSync.mockImplementation((command, args) => {
          if (args && args[0] === 'whoami') {
            return {
              pid: 1234,
              output: ['testuser'],
              stdout: Buffer.from('testuser'),
              stderr: Buffer.from(''),
              status: 0,
              signal: null,
            };
          }
          // Default mock for other commands
          return {
            pid: 1234,
            output: [],
            stdout: Buffer.from(''),
            stderr: Buffer.from(''),
            status: 0,
            signal: null,
          };
        });
        
        await generateCommand('/dist', options);
        
        // Should run build
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['run', 'build'],
          expect.objectContaining({ cwd: path.resolve('/dist') })
        );
        
        // Should check whoami
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['whoami'],
          expect.objectContaining({ cwd: path.resolve('/dist') })
        );
        
        // Should publish
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['publish'],
          expect.objectContaining({ cwd: path.resolve('/dist') })
        );
      });
      
      it('should use custom npm registry when provided', async () => {
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package',
          publishToNpm: true,
          npmRegistry: 'https://custom.registry.com/'
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock all required files exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          return true;
        });
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              dependencies: { react: '^18.0.0' }
            });
          }
          return '';
        });
        
        // Mock npm commands success
        mockSpawnSync.mockReturnValue({
          pid: 1234,
          output: ['testuser'],
          stdout: Buffer.from('testuser'),
          stderr: Buffer.from(''),
          status: 0,
          signal: null,
        });
        
        await generateCommand('/dist', options);
        
        // Should set custom registry
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['config', 'set', 'registry', 'https://custom.registry.com/'],
          expect.objectContaining({ cwd: path.resolve('/dist') })
        );
        
        // Should delete registry config after publish
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['config', 'delete', 'registry'],
          expect.objectContaining({ cwd: path.resolve('/dist') })
        );
      });
      
      it('should handle npm publish errors gracefully', async () => {
        const mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
          throw new Error('process.exit called');
        });
        const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
        
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package',
          publishToNpm: true
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock all required files exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          return true;
        });
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              dependencies: { react: '^18.0.0' }
            });
          }
          return '';
        });
        
        // Mock npm whoami failure (not logged in)
        mockSpawnSync.mockImplementation((command, args) => {
          if (args && args[0] === 'whoami') {
            return {
              pid: 1234,
              output: [],
              stdout: Buffer.from(''),
              stderr: Buffer.from('npm ERR! not logged in'),
              status: 1,
              signal: null,
            };
          }
          return {
            pid: 1234,
            output: [],
            stdout: Buffer.from(''),
            stderr: Buffer.from(''),
            status: 0,
            signal: null,
          };
        });
        
        await expect(async () => {
          await generateCommand('/dist', options);
        }).rejects.toThrow('process.exit called');
        
        expect(consoleSpy).toHaveBeenCalledWith(
          '\nError during npm publish:',
          expect.any(Error)
        );
        expect(mockExit).toHaveBeenCalledWith(1);
        
        mockExit.mockRestore();
        consoleSpy.mockRestore();
      });
      
      it('should prompt for npm publishing when not specified in options', async () => {
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock all required files exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          return true;
        });
        
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              dependencies: { react: '^18.0.0' }
            });
          }
          return '';
        });
        
        // Mock user says yes to publish
        mockInquirer.prompt
          .mockResolvedValueOnce({ publish: true })
          .mockResolvedValueOnce({ registry: 'https://custom.registry.com/' });
        
        // Mock npm commands success
        mockSpawnSync.mockReturnValue({
          pid: 1234,
          output: ['testuser'],
          stdout: Buffer.from('testuser'),
          stderr: Buffer.from(''),
          status: 0,
          signal: null,
        });
        
        await generateCommand('/dist', options);
        
        // Should have prompted for publishing
        expect(mockInquirer.prompt).toHaveBeenCalledWith([{
          type: 'confirm',
          name: 'publish',
          message: 'Would you like to publish this package to npm?',
          default: false
        }]);
        
        // Should have prompted for registry
        expect(mockInquirer.prompt).toHaveBeenCalledWith([{
          type: 'input',
          name: 'registry',
          message: 'NPM registry URL (leave empty for default npm registry):',
          default: '',
          validate: expect.any(Function)
        }]);
        
        // Should have published with custom registry
        expect(mockSpawnSync).toHaveBeenCalledWith(
          expect.stringMatching(/npm(\.cmd)?/),
          ['config', 'set', 'registry', 'https://custom.registry.com/'],
          expect.objectContaining({ cwd: path.resolve('/dist') })
        );
      });
      
      it('should skip publishing if user says no', async () => {
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock all required files exist
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          return true;
        });
        
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              dependencies: { react: '^18.0.0' }
            });
          }
          return '';
        });
        
        // Mock user says no to publish
        mockInquirer.prompt.mockResolvedValueOnce({ publish: false });
        
        await generateCommand('/dist', options);
        
        // Should have prompted for publishing
        expect(mockInquirer.prompt).toHaveBeenCalledWith([{
          type: 'confirm',
          name: 'publish',
          message: 'Would you like to publish this package to npm?',
          default: false
        }]);
        
        // Should not have prompted for registry
        expect(mockInquirer.prompt).toHaveBeenCalledTimes(1);
        
        // Should not have published
        const publishCalls = (mockSpawnSync as jest.Mock).mock.calls.filter(
          call => call[1] && call[1].includes('publish')
        );
        expect(publishCalls).toHaveLength(0);
      });
    });
    
    describe('Flutter package detection and TypeScript validation', () => {
      it('should auto-detect Flutter package from current directory', async () => {
        const cwdSpy = jest.spyOn(process, 'cwd').mockReturnValue('/test/flutter-package');
        const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
        
        const options = {
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock Flutter package structure
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/test/flutter-package/pubspec.yaml') return true;
          if (pathStr.includes('tsconfig.json')) return true;
          if (pathStr.includes('/lib')) return true;
          return false;
        });
        
        // Mock .d.ts files exist
        mockFs.readdirSync.mockImplementation((dirPath: any) => {
          if (dirPath.toString().includes('/lib')) {
            return ['component.d.ts'] as any;
          }
          return [] as any;
        });
        
        mockFs.statSync.mockReturnValue({ isDirectory: () => false } as any);
        
        await generateCommand('/dist', options);
        
        expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Detected Flutter package at: /test/flutter-package'));
        
        cwdSpy.mockRestore();
        consoleSpy.mockRestore();
      });
      
      it('should prompt to create tsconfig.json if missing', async () => {
        const mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
          throw new Error('process.exit called');
        });
        
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock tsconfig.json doesn't exist in Flutter package but everything else is valid
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          // tsconfig.json missing in Flutter package
          if (pathStr === '/flutter/src/tsconfig.json') return false;
          // But exists in dist (after creation)
          if (pathStr.includes('/dist') && pathStr.includes('tsconfig.json')) return true;
          if (pathStr.includes('/lib')) return true;
          if (pathStr.includes('package.json')) return true;
          if (pathStr.includes('global.d.ts')) return true;
          return true;
        });
        
        // Mock .d.ts files exist
        mockFs.readdirSync.mockImplementation((dirPath: any) => {
          if (dirPath.toString().includes('/lib')) {
            return ['component.d.ts'] as any;
          }
          return [] as any;
        });
        
        mockFs.statSync.mockReturnValue({ isDirectory: () => false } as any);
        
        // Mock user says yes to create tsconfig
        mockInquirer.prompt.mockResolvedValueOnce({ createTsConfig: true });
        
        // After tsconfig is created, mock it exists
        let tsconfigCreated = false;
        const originalWriteFileSync = mockFs.writeFileSync;
        mockFs.writeFileSync = jest.fn().mockImplementation((path, content, encoding) => {
          originalWriteFileSync(path, content, encoding);
          if (path.toString().includes('tsconfig.json')) {
            tsconfigCreated = true;
          }
        });
        
        // Update existsSync to return true for tsconfig after it's created
        const originalExistsSync = mockFs.existsSync as jest.Mock;
        mockFs.existsSync = jest.fn().mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json' && tsconfigCreated) return true;
          return originalExistsSync(filePath);
        });
        
        await generateCommand('/dist', options);
        
        // Should have prompted about tsconfig
        expect(mockInquirer.prompt).toHaveBeenCalledWith([{
          type: 'confirm',
          name: 'createTsConfig',
          message: 'No tsconfig.json found. Would you like me to create one for you?',
          default: true
        }]);
        
        // Should have created tsconfig.json
        expect(mockFs.writeFileSync).toHaveBeenCalledWith(
          '/flutter/src/tsconfig.json',
          expect.stringContaining('"target": "ES2020"'),
          'utf-8'
        );
        
        mockExit.mockRestore();
      });
      
      it('should fail validation if no .d.ts files found', async () => {
        const mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
          throw new Error('process.exit called');
        });
        const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
        
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock everything exists except .d.ts files
        mockFs.existsSync.mockReturnValue(true);
        mockFs.readdirSync.mockReturnValue(['file.ts', 'package.json'] as any);
        mockFs.statSync.mockReturnValue({ isDirectory: () => false } as any);
        
        await expect(async () => {
          await generateCommand('/dist', options);
        }).rejects.toThrow('process.exit called');
        
        expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('No TypeScript definition files (.d.ts) found'));
        
        mockExit.mockRestore();
        consoleSpy.mockRestore();
      });
    });
    
    describe('Automatic build after generation', () => {
      it('should automatically run npm run build after code generation', async () => {
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock package.json exists
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          if (pathStr.includes('pubspec.yaml')) return true;
          if (pathStr.includes('package.json')) return true;
          return true;
        });
        
        // Mock package.json with build script
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              scripts: {
                build: 'tsup'
              },
              dependencies: { react: '^18.0.0' }
            });
          }
          return '';
        });
        
        await generateCommand('/dist', options);
        
        // Should have called npm run build
        const buildCalls = (mockSpawnSync as jest.Mock).mock.calls.filter(
          call => call[1] && call[1].includes('build') && call[1].includes('run')
        );
        expect(buildCalls).toHaveLength(1);
        expect(buildCalls[0][0]).toMatch(/npm(\.cmd)?$/);
        expect(buildCalls[0][1]).toEqual(['run', 'build']);
      });
      
      it('should handle build failure gracefully', async () => {
        const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
        
        const options = {
          flutterPackageSrc: '/flutter/src',
          framework: 'react',
          packageName: 'test-package'
        };
        
        // Mock TypeScript validation
        mockTypeScriptValidation('/flutter/src');
        
        // Mock package.json exists
        mockFs.existsSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr === '/flutter/src/tsconfig.json') return true;
          if (pathStr === '/flutter/src/lib') return true;
          if (pathStr.includes('pubspec.yaml')) return true;
          if (pathStr.includes('package.json')) return true;
          return true;
        });
        
        // Mock package.json with build script
        mockFs.readFileSync.mockImplementation((filePath) => {
          const pathStr = filePath.toString();
          if (pathStr.includes('package.json') && !pathStr.includes('.tpl')) {
            return JSON.stringify({ 
              name: 'test-package',
              version: '1.0.0',
              scripts: {
                build: 'tsup'
              },
              dependencies: { react: '^18.0.0' }
            });
          }
          return '';
        });
        
        // Mock build failure
        mockSpawnSync.mockImplementation((command: any, args: any) => {
          if (args && args.includes('build')) {
            return {
              pid: 1234,
              output: [],
              stdout: Buffer.from(''),
              stderr: Buffer.from('Build error'),
              status: 1,
              signal: null,
            };
          }
          return {
            pid: 1234,
            output: [],
            stdout: Buffer.from(''),
            stderr: Buffer.from(''),
            status: 0,
            signal: null,
          };
        });
        
        await generateCommand('/dist', options);
        
        // Should have logged warning about build failure
        expect(consoleSpy).toHaveBeenCalledWith('\nWarning: Build failed:', expect.any(Error));
        
        // Should still complete successfully (generation worked)
        expect(mockGenerator.dartGen).toHaveBeenCalled();
        expect(mockGenerator.reactGen).toHaveBeenCalled();
        
        consoleSpy.mockRestore();
      });
    });
  });
});