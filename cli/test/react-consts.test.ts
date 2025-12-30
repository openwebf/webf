import { generateReactComponent } from '../src/react';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject, ClassObjectKind, ConstObject, EnumObject, EnumMemberObject } from '../src/declaration';

describe('React generator - declare const support', () => {
  it('emits export declare const for constants from typings', () => {
    const blob = new IDLBlob('/test/source', '/test/target', 'ConstOnly', 'test', '');
    const properties = new ClassObject();
    properties.name = 'TestComponentProperties';
    properties.kind = ClassObjectKind.interface;
    const constObj = new ConstObject();
    constObj.name = 'WEBF_CUPERTINO_SYMBOL';
    constObj.type = 'unique symbol';

    blob.objects = [properties, constObj as any];

    const output = generateReactComponent(blob);
    expect(output).toContain('export declare const WEBF_CUPERTINO_SYMBOL: unique symbol;');
  });

  it('emits export declare enum for enums from typings', () => {
    const blob = new IDLBlob('/test/source', '/test/target', 'EnumOnly', 'test', '');
    const properties = new ClassObject();
    properties.name = 'TestComponentProperties';
    properties.kind = ClassObjectKind.interface;
    const eo = new EnumObject();
    eo.name = 'CupertinoColors';
    const m1 = new EnumMemberObject(); m1.name = "'red'"; m1.initializer = '0x0f';
    const m2 = new EnumMemberObject(); m2.name = "'bbb'"; m2.initializer = '0x00';
    eo.members = [m1, m2];
    blob.objects = [properties, eo as any];

    const output = generateReactComponent(blob);
    expect(output).toContain("export enum CupertinoColors { 'red' = 0x0f, 'bbb' = 0x00 }");
  });
});
