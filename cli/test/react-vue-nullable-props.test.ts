import { analyzer, clearCaches, UnionTypeCollector, ParameterType } from '../src/analyzer';
import { generateReactComponent } from '../src/react';
import { generateVueTypings } from '../src/vue';
import { IDLBlob } from '../src/IDLBlob';

describe('React/Vue nullable union props', () => {
  beforeEach(() => {
    clearCaches();
  });

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

  it('emits boolean | null for React props', () => {
    const blob = new IDLBlob('checkbox.d.ts', 'dist', 'checkbox', 'implement');
    blob.raw = tsContent;

    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>(),
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };

    analyzer(blob, definedPropertyCollector, unionTypeCollector);

    const reactCode = generateReactComponent(blob);

    // Prop should allow both undefined and null
    expect(reactCode).toContain('checked?: boolean | null;');
  });

  it('emits boolean | null for Vue props', () => {
    const blob = new IDLBlob('checkbox.d.ts', 'dist', 'checkbox', 'implement');
    blob.raw = tsContent;

    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>(),
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };

    analyzer(blob, definedPropertyCollector, unionTypeCollector);

    const vueCode = generateVueTypings([blob]);

    // Vue prop name is kebab-cased and should allow null explicitly
    expect(vueCode).toContain(`'checked'?: boolean | null;`);
  });
});

