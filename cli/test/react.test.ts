import { generateReactComponent } from '../src/react';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind } from '../src/declaration';

describe('React Generator', () => {
  describe('generateReactComponent', () => {
    it('should import createWebFComponent from @openwebf/react-core-ui', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'components/ui');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should import from npm package by default
      expect(result).toContain('import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui"');
    });
    
    it('should generate component using createWebFComponent', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should use createWebFComponent
      expect(result).toContain('export const TestComponent = createWebFComponent<TestComponentElement, TestComponentProps>({');
      expect(result).toContain('tagName: \'test-component\'');
      expect(result).toContain('displayName: \'TestComponent\'');
    });
    
    it('should generate proper TypeScript interfaces', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'widgets');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should have proper interfaces
      expect(result).toContain('export interface TestComponentProps {');
      expect(result).toContain('export interface TestComponentElement extends WebFElementWithMethods<{');
    });
    
    it('should use relative import for @openwebf/react-core-ui package', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'lib/src/html');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob, '@openwebf/react-core-ui', 'lib/src/html');
      
      // Should use relative import for react-core-ui package itself
      // From src/lib/src/html to src/utils: ../../../utils
      expect(result).toContain('import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent"');
    });
    
    it('should use relative import for nested directories in @openwebf/react-core-ui', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'lib/src/html/shimmer');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob, '@openwebf/react-core-ui', 'lib/src/html/shimmer');
      
      // Should use relative import with correct depth
      // From src/lib/src/html/shimmer to src/utils: ../../../../utils
      expect(result).toContain('import { createWebFComponent, WebFElementWithMethods } from "../../../../utils/createWebFComponent"');
    });
  });
});