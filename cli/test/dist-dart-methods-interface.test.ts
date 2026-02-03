describe('dist/dart generateDartClass parity', () => {
  const distAnalyzer = require('../dist/analyzer');
  const distDart = require('../dist/dart');
  const { IDLBlob } = require('../dist/IDLBlob');

  beforeEach(() => {
    distAnalyzer.clearCaches();
  });

  function analyzeWithDist(tsContent: string): string {
    const blob = new IDLBlob('form.d.ts', 'dist', 'form', 'implement');
    blob.raw = tsContent;

    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>(),
    };
    const unionTypeCollector = { types: new Set() };

    distAnalyzer.analyzer(blob, definedPropertyCollector, unionTypeCollector);
    return distDart.generateDartClass(blob, 'test');
  }

  it('generates methods when declared in a dedicated <Component>Methods interface (dist)', () => {
    const tsContent = `
interface FlutterShadcnFormProperties {}

interface FlutterShadcnFormMethods {
  validate(): boolean;
  submit(): boolean;
  reset(): void;
  getFieldValue(fieldId: string): any;
}
`;

    const dartCode = analyzeWithDist(tsContent);

    expect(dartCode).toContain('abstract class FlutterShadcnFormBindings extends WidgetElement {');
    expect(dartCode).toContain('bool validate(List<dynamic> args);');
    expect(dartCode).toContain('bool submit(List<dynamic> args);');
    expect(dartCode).toContain('void reset(List<dynamic> args);');
    expect(dartCode).toContain('dynamic getFieldValue(List<dynamic> args);');
    expect(dartCode).toContain("'validate': StaticDefinedSyncBindingObjectMethod(");
  });

  it('can derive the component name from a <Component>Methods interface when Properties/Events are absent (dist)', () => {
    const tsContent = `
interface FlutterShadcnFormMethods {
  validate(): boolean;
}
`;

    const dartCode = analyzeWithDist(tsContent);

    expect(dartCode).toContain('abstract class FlutterShadcnFormBindings extends WidgetElement {');
    expect(dartCode).toContain('bool validate(List<dynamic> args);');
  });
});

