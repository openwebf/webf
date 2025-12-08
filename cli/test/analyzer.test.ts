import ts from 'typescript';
import { analyzer, buildClassRelationship, clearCaches, ParameterType } from '../src/analyzer';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, FunctionArgumentType } from '../src/declaration';

describe('Analyzer', () => {
  beforeEach(() => {
    // Clear caches and global state before each test
    clearCaches();
    ClassObject.globalClassMap = Object.create(null);
    ClassObject.globalClassRelationMap = Object.create(null);
  });

  describe('analyzer function', () => {
    it('should analyze interface declaration', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          name: string;
          age: number;
          isActive?: boolean;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      expect(blob.objects).toHaveLength(1);
      expect(blob.objects[0]).toBeInstanceOf(ClassObject);
      
      const classObj = blob.objects[0] as ClassObject;
      expect(classObj.name).toBe('TestInterface');
      expect(classObj.props).toHaveLength(3);
      expect(classObj.props[0].name).toBe('name');
      expect(classObj.props[1].name).toBe('age');
      expect(classObj.props[2].name).toBe('isActive');
      expect(classObj.props[2].optional).toBe(true);
    });

    it('should handle interface inheritance', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface ParentInterface {
          parentProp: string;
        }
        
        interface ChildInterface extends ParentInterface {
          childProp: number;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      expect(blob.objects).toHaveLength(2);
      
      const childObj = blob.objects.find(o => (o as ClassObject).name === 'ChildInterface') as ClassObject;
      expect(childObj.parent).toBe('ParentInterface');
    });

    it('should handle method signatures', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          getName(): string;
          setAge(age: number): void;
          calculate(a: number, b: number): number;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      const classObj = blob.objects[0] as ClassObject;
      expect(classObj.methods).toHaveLength(3);
      
      const getName = classObj.methods[0];
      expect(getName.name).toBe('getName');
      expect(getName.args).toHaveLength(0);
      expect(getName.returnType?.value).toBe(FunctionArgumentType.dom_string);
      
      const setAge = classObj.methods[1];
      expect(setAge.name).toBe('setAge');
      expect(setAge.args).toHaveLength(1);
      expect(setAge.args[0].name).toBe('age');
      expect(setAge.returnType?.value).toBe(FunctionArgumentType.void);
    });

    it('should handle union types', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          value: string | number | null;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      const classObj = blob.objects[0] as ClassObject;
      const prop = classObj.props[0];
      expect(Array.isArray(prop.type.value)).toBe(true);
      expect(prop.type.value).toHaveLength(3);
      expect(unionTypeCollector.types.size).toBeGreaterThan(0);
    });

    it('should handle array types', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          items: string[];
          numbers: number[];
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      const classObj = blob.objects[0] as ClassObject;
      expect(classObj.props[0].type.isArray).toBe(true);
      expect(classObj.props[1].type.isArray).toBe(true);
    });

    it('should handle function types as properties', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          onClick: Function;
          onChange: Function;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      const classObj = blob.objects[0] as ClassObject;
      // Function type properties are stored as props with function type
      expect(classObj.props).toHaveLength(2);
      expect(classObj.props[0].name).toBe('onClick');
      expect(classObj.props[0].type.value).toBe(FunctionArgumentType.function);
      expect(classObj.props[1].name).toBe('onChange');
      expect(classObj.props[1].type.value).toBe(FunctionArgumentType.function);
    });

    it('should handle errors gracefully', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          // This is invalid TypeScript
          prop: 
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      // Should not throw, but objects array will be empty or contain partial results
      expect(() => analyzer(blob, propertyCollector, unionTypeCollector)).not.toThrow();
    });

    it('should cache parsed source files', () => {
      const blob1 = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob1.raw = `interface Test1 { prop: string; }`;
      
      const blob2 = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob2.raw = `interface Test2 { prop: number; }`; // Different content, same path
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob1, propertyCollector, unionTypeCollector);
      analyzer(blob2, propertyCollector, unionTypeCollector);

      // Second analyzer should use cached source file (with first content)
      const classObj = blob2.objects[0] as ClassObject;
      expect(classObj.name).toBe('Test1'); // Not Test2, because it used cached version
    });
  });

  describe('buildClassRelationship', () => {
    it('should build parent-child relationships', () => {
      ClassObject.globalClassMap = {
        Parent: { name: 'Parent', parent: null } as any,
        Child1: { name: 'Child1', parent: 'Parent' } as any,
        Child2: { name: 'Child2', parent: 'Parent' } as any,
        GrandChild: { name: 'GrandChild', parent: 'Child1' } as any,
      };

      buildClassRelationship();

      expect(ClassObject.globalClassRelationMap['Parent']).toEqual(['Child1', 'Child2']);
      expect(ClassObject.globalClassRelationMap['Child1']).toEqual(['GrandChild']);
      expect(ClassObject.globalClassRelationMap['Child2']).toBeUndefined();
    });

    it('should handle empty class map', () => {
      ClassObject.globalClassMap = {};
      
      expect(() => buildClassRelationship()).not.toThrow();
      expect(ClassObject.globalClassRelationMap).toEqual({});
    });
  });

  describe('clearCaches', () => {
    it('should clear all caches', () => {
      // First add some data to cache by analyzing
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `interface Test { prop: string; }`;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);
      
      // Clear caches
      clearCaches();
      
      // Analyze again with different content
      blob.raw = `interface Test { prop: number; }`;
      analyzer(blob, propertyCollector, unionTypeCollector);
      
      // Should get new result, not cached
      const classObj = blob.objects[0] as ClassObject;
      expect(classObj.props[0].type.value).toBe(FunctionArgumentType.double);
    });
  });

  describe('Type mapping', () => {
    it('should map basic types correctly', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          str: string;
          num: number;
          bool: boolean;
          obj: object;
          any: any;
          void: void;
          undef: undefined;
          nil: null;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      const classObj = blob.objects[0] as ClassObject;
      // Note: void properties might be filtered out or handled differently
      expect(classObj.props.length).toBeGreaterThanOrEqual(7);
      expect(classObj.props[0].type.value).toBe(FunctionArgumentType.dom_string);
      expect(classObj.props[1].type.value).toBe(FunctionArgumentType.double);
      expect(classObj.props[2].type.value).toBe(FunctionArgumentType.boolean);
      expect(classObj.props[3].type.value).toBe(FunctionArgumentType.object);
      expect(classObj.props[4].type.value).toBe(FunctionArgumentType.any);
      // void type might be at index 5
      const voidProp = classObj.props.find(p => p.name === 'void');
      if (voidProp) {
        expect(voidProp.type.value).toBe(FunctionArgumentType.void);
      }
      const undefProp = classObj.props.find(p => p.name === 'undef');
      expect(undefProp?.type.value).toBe(FunctionArgumentType.undefined);
      const nilProp = classObj.props.find(p => p.name === 'nil');
      expect(nilProp).toBeDefined();
      if (nilProp) {
        expect(nilProp.type.value).toBe(FunctionArgumentType.null);
      }
    });

    it('should handle special type references', () => {
      const blob = new IDLBlob('/test/source.d.ts', '/test/target', 'test', 'test');
      blob.raw = `
        interface TestInterface {
          func: Function;
          promise: Promise<string>;
          int: int;
        }
      `;
      
      const propertyCollector = {
        properties: new Set<string>(),
        files: new Set<string>(),
        interfaces: new Set<string>()
      };
      const unionTypeCollector = {
        types: new Set<ParameterType[]>()
      };

      analyzer(blob, propertyCollector, unionTypeCollector);

      const classObj = blob.objects[0] as ClassObject;
      expect(classObj.props[0].type.value).toBe(FunctionArgumentType.function);
      expect(classObj.props[1].type.value).toBe(FunctionArgumentType.promise);
      expect(classObj.props[2].type.value).toBe(FunctionArgumentType.int);
    });
  });
});