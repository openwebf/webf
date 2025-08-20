import { generateVueTypings } from '../src/vue';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind, PropsDeclaration } from '../src/declaration';

describe('Vue Generator', () => {
  describe('generateVueTypings', () => {
    it('should generate Vue component types with standard HTML props', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateVueTypings([blob]);
      
      // Should include standard HTML props in Props type
      expect(result).toContain("'id'?: string;");
      expect(result).toContain("'class'?: string;");
      expect(result).toContain("'style'?: string | Record<string, any>;");
      
      // Should generate proper type exports
      expect(result).toContain('export type TestComponentProps = {');
      expect(result).toContain('export interface TestComponentElement {');
      expect(result).toContain('export type TestComponentEvents = {');
    });

    it('should include standard HTML props along with custom properties', () => {
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
      
      const isActiveProp = new PropsDeclaration();
      isActiveProp.name = 'isActive';
      isActiveProp.type = { value: 'boolean' };
      isActiveProp.optional = true;
      isActiveProp.documentation = 'Whether the component is active';
      isActiveProp.readonly = false;
      isActiveProp.typeMode = {};
      
      properties.props = [titleProp, isActiveProp];
      blob.objects = [properties];
      
      const result = generateVueTypings([blob]);
      
      // Should include custom props with kebab-case (dom_string is not converted in type definitions)
      expect(result).toContain("'title': dom_string;");
      expect(result).toContain("'is-active'?: boolean;");
      
      // And still include standard HTML props
      expect(result).toContain("'id'?: string;");
      expect(result).toContain("'class'?: string;");
      expect(result).toContain("'style'?: string | Record<string, any>;");
    });

    it('should generate proper Vue component declarations', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'WebFListView', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'WebFListViewProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateVueTypings([blob]);
      
      // Should generate proper component declarations
      expect(result).toContain("declare module 'vue' {");
      expect(result).toContain("interface GlobalComponents {");
      expect(result).toContain("'web-f-list-view': DefineCustomElement<");
      expect(result).toContain("WebFListViewProps,");
      expect(result).toContain("WebFListViewEvents");
    });

    it('should handle multiple components', () => {
      const blob1 = new IDLBlob('/test/source', '/test/target', 'ComponentOne', 'test', '');
      const properties1 = new ClassObject();
      properties1.name = 'ComponentOneProperties';
      properties1.kind = ClassObjectKind.interface;
      blob1.objects = [properties1];

      const blob2 = new IDLBlob('/test/source', '/test/target', 'ComponentTwo', 'test', '');
      const properties2 = new ClassObject();
      properties2.name = 'ComponentTwoProperties';
      properties2.kind = ClassObjectKind.interface;
      blob2.objects = [properties2];
      
      const result = generateVueTypings([blob1, blob2]);
      
      // Should include both components
      expect(result).toContain('export type ComponentOneProps = {');
      expect(result).toContain('export type ComponentTwoProps = {');
      
      // Both should have standard HTML props
      const componentOneMatch = result.match(/export type ComponentOneProps = \{[^}]+\}/);
      const componentTwoMatch = result.match(/export type ComponentTwoProps = \{[^}]+\}/);
      
      // Extract content including newlines
      const componentOneSection = result.substring(result.indexOf('export type ComponentOneProps'), result.indexOf('export interface ComponentOneElement'));
      const componentTwoSection = result.substring(result.indexOf('export type ComponentTwoProps'), result.indexOf('export interface ComponentTwoElement'));
      
      expect(componentOneSection).toContain("'id'?: string;");
      expect(componentTwoSection).toContain("'id'?: string;");
    });

    it('should handle components with events', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TestComponent', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'TestComponentProperties';
      properties.kind = ClassObjectKind.interface;
      
      const events = new ClassObject();
      events.name = 'TestComponentEvents';
      events.kind = ClassObjectKind.interface;
      const closeProp = new PropsDeclaration();
      closeProp.name = 'close';
      closeProp.type = { value: 'Event', isArray: false };
      closeProp.optional = true;
      closeProp.documentation = 'Close event';
      closeProp.readonly = false;
      closeProp.typeMode = {};
      
      const refreshProp = new PropsDeclaration();
      refreshProp.name = 'refresh';
      refreshProp.type = { value: 'CustomEvent', isArray: false };
      refreshProp.optional = true;
      refreshProp.documentation = 'Refresh event';
      refreshProp.readonly = false;
      refreshProp.typeMode = {};
      
      events.props = [closeProp, refreshProp];
      
      blob.objects = [properties, events];
      
      const result = generateVueTypings([blob]);
      
      // Should include event types
      expect(result).toContain('export type TestComponentEvents = {');
      expect(result).toContain('close?: Event;');
      expect(result).toContain('refresh?: CustomEvent;');
      
      // Props should still have standard HTML props
      expect(result).toContain("'id'?: string;");
      expect(result).toContain("'class'?: string;");
      expect(result).toContain("'style'?: string | Record<string, any>;");
    });
  });
});