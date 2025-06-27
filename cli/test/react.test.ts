import { generateReactComponent } from '../src/react';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind } from '../src/declaration';

describe('React Generator', () => {
  describe('generateReactComponent', () => {
    it('should import createWebFComponent from @openwebf/webf-react-core-ui', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', 'components/ui');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should import from npm package, not relative path
      expect(result).toContain('import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui"');
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
  });
});