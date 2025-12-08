import { analyzer, clearCaches, UnionTypeCollector, ParameterType } from '../src/analyzer';
import { generateDartClass } from '../src/dart';
import { IDLBlob } from '../src/IDLBlob';

describe('Dart nullable union properties', () => {
  beforeEach(() => {
    clearCaches();
  });

  it('handles boolean | null properties and maps "null" attribute to null', () => {
    const tsContent = `
interface FlutterCupertinoCheckboxProperties {
  /**
   * Whether the checkbox is checked.
   * Default: false.
   */
  checked?: boolean | null;
}

interface FlutterCupertinoCheckboxEvents {
  /**
   * Fired when the checkbox value changes.
   */
  change: CustomEvent<boolean>;
}
`;

    const blob = new IDLBlob('checkbox.d.ts', 'dist', 'checkbox', 'implement');
    blob.raw = tsContent;

    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>(),
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };

    analyzer(blob, definedPropertyCollector, unionTypeCollector);

    const dartCode = generateDartClass(blob, 'test');

    // Should generate bindings class for FlutterCupertinoCheckbox
    expect(dartCode).toContain('abstract class FlutterCupertinoCheckboxBindings extends WidgetElement {');

    // The checked property should be a nullable bool in Dart bindings.
    expect(dartCode).toContain('bool? get checked;');

    // Attribute setter should treat the literal "null" as a Dart null.
    expect(dartCode).toContain(
      "setter: (value) => checked = value == 'null' ? null : (value == 'true' || value == ''),"
    );

    // Deleting the attribute should reset to the default `false`.
    expect(dartCode).toContain(
      "deleter: () => checked = false"
    );
  });
});
