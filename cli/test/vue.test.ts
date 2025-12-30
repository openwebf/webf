import { generateVueTypings } from '../src/vue';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind, PropsDeclaration, ConstObject, TypeAliasObject } from '../src/declaration';

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
      expect(result).toContain("'class'?: ClassValue;");
      expect(result).toContain("'style'?: StyleValue;");
      
      // Should generate proper type exports
      expect(result).toContain('export type TestComponentProps = {');
      expect(result).toContain('export interface TestComponentElement {');
      expect(result).toContain('export type TestComponentEvents = {');

      // Should not rely on a non-existent internal __webfTypes import
      expect(result).not.toContain('__webfTypes');
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
      expect(result).toContain("'class'?: ClassValue;");
      expect(result).toContain("'style'?: StyleValue;");
    });

    it('should generate proper Vue component declarations', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'WebFListView', 'test', '');
      
      const properties = new ClassObject();
      properties.name = 'WebFListViewProperties';
      properties.kind = ClassObjectKind.interface;
      blob.objects = [properties];
      
      const result = generateVueTypings([blob]);
      
      // Should generate proper component declarations
      expect(result).toContain("declare module '@vue/runtime-core' {");
      expect(result).toContain("interface GlobalComponents {");
      expect(result).toContain("'webf-list-view': DefineCustomElement<");
      expect(result).not.toContain("'web-f-list-view': DefineCustomElement<");
      expect(result).toContain("WebFListViewElement,");
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
      expect(result).toContain('close: Event;');
      expect(result).toContain('refresh: CustomEvent;');
      
      // Props should still have standard HTML props
      expect(result).toContain("'id'?: string;");
      expect(result).toContain("'class'?: ClassValue;");
      expect(result).toContain("'style'?: StyleValue;");
    });

    it('should include declare const variables as exported declarations', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'ConstOnly', 'test', '');

      const constObj = new ConstObject();
      constObj.name = 'WEBF_UNIQUE';
      constObj.type = 'unique symbol';

      blob.objects = [constObj as any];

      const result = generateVueTypings([blob]);

      expect(result).toContain('export declare const WEBF_UNIQUE: unique symbol;');
    });

    it('should include type aliases as exported declarations', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'TypeAliasOnly', 'test', '');

      const typeAlias = new TypeAliasObject();
      typeAlias.name = 'MyAlias';
      typeAlias.type = 'string | number';

      blob.objects = [typeAlias as any];

      const result = generateVueTypings([blob]);
      expect(result).toContain('export type MyAlias = string | number;');
    });

    it('should include declare enum as exported declaration', () => {
      const blob = new IDLBlob('/test/source', '/test/target', 'EnumOnly', 'test', '');
      // Build a minimal faux EnumObject via analyzer by simulating ast is heavy; create a shape
      // We'll reuse analyzer classes by importing EnumObject is cumbersome in test; instead
      // craft an object literal compatible with instanceof check by constructing real class.
      const { EnumObject, EnumMemberObject } = require('../src/declaration');
      const e = new EnumObject();
      e.name = 'CupertinoColors';
      const m1 = new EnumMemberObject(); m1.name = "'red'"; m1.initializer = '0x0f';
      const m2 = new EnumMemberObject(); m2.name = "'bbb'"; m2.initializer = '0x00';
      e.members = [m1, m2];

      blob.objects = [e as any];

      const result = generateVueTypings([blob]);
      expect(result).toContain("export declare enum CupertinoColors { 'red' = 0x0f, 'bbb' = 0x00 }");
    });
  });
});
