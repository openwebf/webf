import { generateReactComponent } from '../src/react';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind, PropsDeclaration } from '../src/declaration';

// Import the toWebFTagName function for testing
import { toWebFTagName } from '../src/react';

describe('React Generator', () => {
  describe('toWebFTagName', () => {
    it('should convert WebF prefixed components correctly', () => {
      expect(toWebFTagName('WebFTable')).toBe('webf-table');
      expect(toWebFTagName('WebFTableCell')).toBe('webf-table-cell');
      expect(toWebFTagName('WebFListView')).toBe('webf-list-view');
      expect(toWebFTagName('WebFTouchArea')).toBe('webf-touch-area');
    });
    
    it('should convert Flutter prefixed components correctly', () => {
      expect(toWebFTagName('FlutterShimmer')).toBe('flutter-shimmer');
      expect(toWebFTagName('FlutterShimmerText')).toBe('flutter-shimmer-text');
      expect(toWebFTagName('FlutterShimmerAvatar')).toBe('flutter-shimmer-avatar');
    });
    
    it('should handle components without special prefixes', () => {
      expect(toWebFTagName('CustomComponent')).toBe('custom-component');
      expect(toWebFTagName('MyElement')).toBe('my-element');
    });
  });

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
    
    it('should generate correct tagName for WebF components', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'WebFTableCell', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'WebFTableCellProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should generate correct tagName
      expect(result).toContain('tagName: \'webf-table-cell\'');
      expect(result).not.toContain('tagName: \'web-f-table-cell\'');
    });
    
    it('should generate correct tagName for Flutter components', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'FlutterShimmerText', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'FlutterShimmerTextProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should generate correct tagName
      expect(result).toContain('tagName: \'flutter-shimmer-text\'');
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

    it('should include standard HTML props (id, className, style) in component interface', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should include standard HTML props
      expect(result).toContain('id?: string;');
      expect(result).toContain('style?: React.CSSProperties;');
      expect(result).toContain('children?: React.ReactNode;');
      expect(result).toContain('className?: string;');
      
      // Props should have proper JSDoc comments
      expect(result).toMatch(/\/\*\*\s*\n\s*\*\s*HTML id attribute\s*\n\s*\*\/\s*\n\s*id\?: string;/);
      expect(result).toMatch(/\/\*\*\s*\n\s*\*\s*Additional CSS styles\s*\n\s*\*\/\s*\n\s*style\?: React\.CSSProperties;/);
      expect(result).toMatch(/\/\*\*\s*\n\s*\*\s*Children elements\s*\n\s*\*\/\s*\n\s*children\?: React\.ReactNode;/);
      expect(result).toMatch(/\/\*\*\s*\n\s*\*\s*Additional CSS class names\s*\n\s*\*\/\s*\n\s*className\?: string;/);
    });

    it('should include standard HTML props even when component has custom properties', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      const titleProp = new PropsDeclaration();
      titleProp.name = 'title';
      titleProp.type = { value: 'dom_string' };
      titleProp.optional = false;
      titleProp.documentation = 'The component title';
      titleProp.readonly = false;
      titleProp.typeMode = {};
      
      const disabledProp = new PropsDeclaration();
      disabledProp.name = 'disabled';
      disabledProp.type = { value: 'boolean' };
      disabledProp.optional = true;
      disabledProp.documentation = 'Whether the component is disabled';
      disabledProp.readonly = false;
      disabledProp.typeMode = {};
      
      properties.props = [titleProp, disabledProp];
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Should include custom props with generated TS types
      expect(result).toContain('title: __webfTypes.dom_string;');
      expect(result).toContain('disabled?: __webfTypes.boolean;');
      
      // And still include standard HTML props
      expect(result).toContain('id?: string;');
      expect(result).toContain('style?: React.CSSProperties;');
      expect(result).toContain('children?: React.ReactNode;');
      expect(result).toContain('className?: string;');
    });

    it('should preserve JSDoc for supporting option interfaces', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;

      const options = new ClassObject();
      options.name = 'TestComponentOptions';
      options.kind = ClassObjectKind.interface;

      const titleProp = new PropsDeclaration();
      titleProp.name = 'title';
      titleProp.type = { value: 'string' } as any;
      titleProp.optional = true;
      titleProp.documentation = 'Optional override title for this show() call.';
      titleProp.readonly = false;
      titleProp.typeMode = {};

      const messageProp = new PropsDeclaration();
      messageProp.name = 'message';
      messageProp.type = { value: 'string' } as any;
      messageProp.optional = true;
      messageProp.documentation = 'Optional override message for this show() call.';
      messageProp.readonly = false;
      messageProp.typeMode = {};

      options.props = [titleProp, messageProp];

      blob.objects = [properties, options];
      
      const result = generateReactComponent(blob);

      expect(result).toContain('interface TestComponentOptions');
      expect(result).toMatch(
        /interface TestComponentOptions[\s\S]*?\/\*\*[\s\S]*?Optional override title for this show\(\) call\.[\s\S]*?\*\/\s*\n\s*title\?:/
      );
      expect(result).toMatch(
        /interface TestComponentOptions[\s\S]*?\/\*\*[\s\S]*?Optional override message for this show\(\) call\.[\s\S]*?\*\/\s*\n\s*message\?:/
      );
    });
  });
});
