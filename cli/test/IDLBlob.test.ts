import fs from 'fs';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, FunctionObject } from '../src/declaration';

jest.mock('fs');

const mockFs = fs as jest.Mocked<typeof fs>;

describe('IDLBlob', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFs.readFileSync.mockReturnValue('interface Test { prop: string; }');
  });

  describe('constructor', () => {
    it('should initialize with provided parameters', () => {
      const blob = new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      expect(blob.source).toBe('/source/test.d.ts');
      expect(blob.dist).toBe('/target');
      expect(blob.filename).toBe('test');
      expect(blob.implement).toBe('src/test');
    });

    it('should initialize raw as empty string', () => {
      const blob = new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      expect(blob.raw).toBe('');
    });

    it('should initialize objects array as empty', () => {
      const blob = new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      expect(blob.objects).toEqual([]);
    });
  });

  describe('properties', () => {
    it('should allow setting and getting raw content', () => {
      const blob = new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      blob.raw = 'new content';
      expect(blob.raw).toBe('new content');
    });

    it('should allow setting and getting objects', () => {
      const blob = new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      const classObj = new ClassObject();
      classObj.name = 'TestClass';
      
      const funcObj = new FunctionObject();
      
      blob.objects = [classObj, funcObj];
      expect(blob.objects).toHaveLength(2);
      expect(blob.objects[0]).toBe(classObj);
      expect(blob.objects[1]).toBe(funcObj);
    });

    it('should allow modifying dist path', () => {
      const blob = new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      blob.dist = '/new/target';
      expect(blob.dist).toBe('/new/target');
    });
  });

  describe('file operations', () => {
    it('should not read file on construction', () => {
      new IDLBlob('/source/test.d.ts', '/target', 'test', 'src/test');
      
      expect(mockFs.readFileSync).not.toHaveBeenCalled();
    });
  });
});