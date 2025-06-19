import { generateReactComponent } from '../src/react';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind } from '../src/declaration';

describe('React Generator', () => {
  describe('generateReactComponent', () => {
    it('should use correct import path for createComponent in subdirectories', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'components/ui');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Component in components/ui/ needs to go up 2 levels
      expect(result).toContain('import { createComponent } from "../../utils/createComponent"');
    });
    
    it('should use correct import path for createComponent in root directory', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Component in root needs simple relative path
      expect(result).toContain('import { createComponent } from "./utils/createComponent"');
    });
    
    it('should use correct import path for single level subdirectory', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'widgets');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Component in widgets/ needs to go up 1 level
      expect(result).toContain('import { createComponent } from "../utils/createComponent"');
    });
  });
});