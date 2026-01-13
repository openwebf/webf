import fs from 'fs';
import path from 'path';
import { generateModuleArtifacts } from '../src/module';
import { writeFileIfChanged } from '../src/generator';

jest.mock('fs');
jest.mock('../src/generator', () => ({
  writeFileIfChanged: jest.fn(),
}));

const mockFs = fs as jest.Mocked<typeof fs>;
const mockWriteFileIfChanged = writeFileIfChanged as jest.MockedFunction<typeof writeFileIfChanged>;

describe('module-codegen events', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFs.existsSync.mockReturnValue(true);
    mockFs.mkdirSync.mockImplementation(() => undefined);
  });

  it('generates typed module event listener + Dart emit helpers', () => {
    const moduleInterfacePath = '/tmp/demo.module.d.ts';
    const npmTargetDir = '/out/npm';
    const flutterPackageDir = '/out/flutter';

    mockFs.readFileSync.mockReturnValue(`
interface Payload {
  id: string;
}

interface WebFDemoModuleEvents {
  scanResult: [Event, Payload];
  click: CustomEvent<string>;
}

interface WebFDemo {
  ping(): Promise<boolean>;
}
`);

    generateModuleArtifacts({
      moduleInterfacePath,
      npmTargetDir,
      flutterPackageDir,
      command: 'webf module-codegen',
    });

    const typesPath = path.join(npmTargetDir, 'src', 'types.ts');
    const indexPath = path.join(npmTargetDir, 'src', 'index.ts');
    const dartBindingsPath = path.join(
      flutterPackageDir,
      'lib',
      'src',
      'demo_module_bindings_generated.dart'
    );

    const writes = mockWriteFileIfChanged.mock.calls.reduce<Record<string, string>>(
      (acc, [filePath, content]) => {
        acc[filePath] = content;
        return acc;
      },
      {}
    );

    expect(writes[typesPath]).toContain('export interface WebFDemoModuleEvents');
    expect(writes[typesPath]).toContain(
      'export type WebFDemoModuleEventName = Extract<keyof WebFDemoModuleEvents, string>;'
    );
    expect(writes[typesPath]).toContain('export type WebFDemoModuleEventListener');

    expect(writes[indexPath]).toContain(
      'static addListener<K extends WebFDemoModuleEventName>(type: K, listener: (...args: WebFDemoModuleEventArgs<K>) => any): () => void'
    );
    expect(writes[indexPath]).toContain('private static _moduleListenerInstalled = false;');
    expect(writes[indexPath]).toContain("addWebfModuleListener('Demo'");
    expect(writes[indexPath]).toContain('static removeListener(): void');

    expect(writes[dartBindingsPath]).toContain("import 'package:webf/dom.dart';");
    expect(writes[dartBindingsPath]).toContain('dynamic emitScanResult({Event? event, Payload? data})');
    expect(writes[dartBindingsPath]).toContain('final mapped = data?.toMap();');
    expect(writes[dartBindingsPath]).not.toContain('class WebFDemoModuleEvents');
  });
});
