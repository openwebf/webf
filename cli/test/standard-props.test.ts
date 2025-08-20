import { generateReactComponent } from '../src/react';
import { generateVueTypings } from '../src/vue';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind, PropsDeclaration } from '../src/declaration';

describe('Standard HTML Props Generation', () => {
  describe('React Components', () => {
    it('should generate id prop in the correct position within the interface', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestButton', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestButtonProperties';
      properties.kind = ClassObjectKind.interface;
      const labelProp = new PropsDeclaration();
      labelProp.name = 'label';
      labelProp.type = { value: 'dom_string' };
      labelProp.optional = false;
      labelProp.readonly = false;
      labelProp.typeMode = {};
      
      const variantProp = new PropsDeclaration();
      variantProp.name = 'variant';
      variantProp.type = { value: 'dom_string' };
      variantProp.optional = true;
      variantProp.readonly = false;
      variantProp.typeMode = {};
      
      properties.props = [labelProp, variantProp];
      
      const events = new ClassObject();
      events.name = 'TestButtonEvents';
      events.kind = ClassObjectKind.interface;
      const clickProp = new PropsDeclaration();
      clickProp.name = 'click';
      clickProp.type = { value: 'Event', isArray: false };
      clickProp.optional = true;
      clickProp.readonly = false;
      clickProp.typeMode = {};
      
      events.props = [clickProp];
      
      blob.objects = [properties, events];
      
      const result = generateReactComponent(blob);
      
      // Verify the props interface structure - extract full content including newlines
      const propsStart = result.indexOf('export interface TestButtonProps {');
      const propsEnd = result.indexOf('}', propsStart) + 1;
      const propsContent = result.substring(propsStart, propsEnd);
      
      // Verify order: custom props, event handlers, then standard HTML props
      const labelIndex = propsContent.indexOf('label: dom_string;');
      const variantIndex = propsContent.indexOf('variant?: dom_string;');
      const onClickIndex = propsContent.indexOf('onClick?: (event: Event) => void;');
      const idIndex = propsContent.indexOf('id?: string;');
      const styleIndex = propsContent.indexOf('style?: React.CSSProperties;');
      const childrenIndex = propsContent.indexOf('children?: React.ReactNode;');
      const classNameIndex = propsContent.indexOf('className?: string;');
      
      // All props should exist
      expect(labelIndex).toBeGreaterThan(-1);
      expect(variantIndex).toBeGreaterThan(-1);
      expect(onClickIndex).toBeGreaterThan(-1);
      expect(idIndex).toBeGreaterThan(-1);
      expect(styleIndex).toBeGreaterThan(-1);
      expect(childrenIndex).toBeGreaterThan(-1);
      expect(classNameIndex).toBeGreaterThan(-1);
      
      // Verify order
      expect(labelIndex).toBeLessThan(variantIndex);
      expect(variantIndex).toBeLessThan(onClickIndex);
      expect(onClickIndex).toBeLessThan(idIndex);
      expect(idIndex).toBeLessThan(styleIndex);
      expect(styleIndex).toBeLessThan(childrenIndex);
      expect(childrenIndex).toBeLessThan(classNameIndex);
    });

    it('should properly type the standard props', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'SimpleComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'SimpleComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateReactComponent(blob);
      
      // Verify exact type definitions
      expect(result).toMatch(/id\?: string;/);
      expect(result).toMatch(/style\?: React\.CSSProperties;/);
      expect(result).toMatch(/children\?: React\.ReactNode;/);
      expect(result).toMatch(/className\?: string;/);
    });
  });

  describe('Vue Components', () => {
    it('should generate standard HTML props with correct Vue naming conventions', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'VueButton', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'VueButtonProperties';
      properties.kind = ClassObjectKind.interface;
      const labelProp = new PropsDeclaration();
      labelProp.name = 'label';
      labelProp.type = { value: 'dom_string' };
      labelProp.optional = false;
      labelProp.readonly = false;
      labelProp.typeMode = {};
      
      const isDisabledProp = new PropsDeclaration();
      isDisabledProp.name = 'isDisabled';
      isDisabledProp.type = { value: 'boolean' };
      isDisabledProp.optional = true;
      isDisabledProp.readonly = false;
      isDisabledProp.typeMode = {};
      
      properties.props = [labelProp, isDisabledProp];
      
      blob.objects = [properties];
      
      const result = generateVueTypings([blob]);
      
      // Verify Props type includes custom and standard props - extract full content
      const propsStart = result.indexOf('export type VueButtonProps = {');
      const propsEnd = result.indexOf('}', propsStart) + 1;
      const propsContent = result.substring(propsStart, propsEnd);
      
      // Custom props should be kebab-case (dom_string is not converted)
      expect(propsContent).toContain("'label': dom_string;");
      expect(propsContent).toContain("'is-disabled'?: boolean;");
      
      // Standard HTML props
      expect(propsContent).toContain("'id'?: string;");
      expect(propsContent).toContain("'class'?: string;");
      expect(propsContent).toContain("'style'?: string | Record<string, any>;");
    });

    it('should handle Vue style prop with both string and object types', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'StyledComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'StyledComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateVueTypings([blob]);
      
      // Vue style prop should accept both string and object
      expect(result).toMatch(/'style'\?: string \| Record<string, any>;/);
    });
  });

  describe('Cross-framework consistency', () => {
    it('should generate equivalent props for both React and Vue', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'CrossFrameworkComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'CrossFrameworkComponentProperties';
      properties.kind = ClassObjectKind.interface;
      const titleProp = new PropsDeclaration();
      titleProp.name = 'title';
      titleProp.type = { value: 'dom_string' };
      titleProp.optional = false;
      titleProp.readonly = false;
      titleProp.typeMode = {};
      
      properties.props = [titleProp];
      blob.objects = [properties];
      
      const reactResult = generateReactComponent(blob);
      const vueResult = generateVueTypings([blob]);
      
      // Both should have id prop
      expect(reactResult).toContain('id?: string;');
      expect(vueResult).toContain("'id'?: string;");
      
      // Both should have style prop (with appropriate types)
      expect(reactResult).toContain('style?: React.CSSProperties;');
      expect(vueResult).toContain("'style'?: string | Record<string, any>;");
      
      // React has className, Vue has class
      expect(reactResult).toContain('className?: string;');
      expect(vueResult).toContain("'class'?: string;");
      
      // React has children, Vue uses slots (not in props)
      expect(reactResult).toContain('children?: React.ReactNode;');
      expect(vueResult).not.toContain('children');
    });
  });
});