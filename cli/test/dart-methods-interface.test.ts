import { analyzer, clearCaches, UnionTypeCollector, ParameterType } from '../src/analyzer';
import { generateDartClass } from '../src/dart';
import { IDLBlob } from '../src/IDLBlob';

describe('Dart Methods interface bindings', () => {
  beforeEach(() => {
    clearCaches();
  });

  function analyze(tsContent: string): string {
    const blob = new IDLBlob('form.d.ts', 'dist', 'form', 'implement');
    blob.raw = tsContent;

    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>(),
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };

    analyzer(blob, definedPropertyCollector, unionTypeCollector);
    return generateDartClass(blob, 'test');
  }

  it('generates methods when declared in a dedicated <Component>Methods interface', () => {
    const tsContent = `
interface FlutterShadcnFormProperties {}

/**
 * Methods available on <flutter-shadcn-form>
 */
interface FlutterShadcnFormMethods {
  validate(): boolean;
  submit(): boolean;
  reset(): void;
  getFieldValue(fieldId: string): any;
}
`;

    const dartCode = analyze(tsContent);

    expect(dartCode).toContain('abstract class FlutterShadcnFormBindings extends WidgetElement {');
    expect(dartCode).toContain('bool validate(List<dynamic> args);');
    expect(dartCode).toContain('bool submit(List<dynamic> args);');
    expect(dartCode).toContain('void reset(List<dynamic> args);');
    expect(dartCode).toContain('dynamic getFieldValue(List<dynamic> args);');
    expect(dartCode).toContain("'validate': StaticDefinedSyncBindingObjectMethod(");
  });

  it('can derive the component name from a <Component>Methods interface when Properties/Events are absent', () => {
    const tsContent = `
interface FlutterShadcnFormMethods {
  validate(): boolean;
}
`;

    const dartCode = analyze(tsContent);

    expect(dartCode).toContain('abstract class FlutterShadcnFormBindings extends WidgetElement {');
    expect(dartCode).toContain('bool validate(List<dynamic> args);');
  });
});

