import fs from 'fs';
import path from 'path';
import ts from 'typescript';
import _ from 'lodash';
import { writeFileIfChanged as writeIfChangedFromGenerator } from './generator';

interface ModuleMethodSpec {
  name: string;
  jsName: string;
  params: { name: string; text: string; typeText: string }[];
  returnTypeText: string;
  documentation?: string;
}

interface ModuleEventSpec {
  name: string;
  eventTypeText: string;
  extraTypeText: string;
  documentation?: string;
}

interface ModuleDefinition {
  interfaceName: string;
  moduleName: string;
  methods: ModuleMethodSpec[];
  events?: {
    interfaceName: string;
    eventNameTypeName: string;
    eventArgsTypeName: string;
    listenerTypeName: string;
    events: ModuleEventSpec[];
  };
  supportingStatements: ts.Statement[];
  sourceFile: ts.SourceFile;
}

function parseModuleDefinition(modulePath: string): ModuleDefinition {
  const sourceText = fs.readFileSync(modulePath, 'utf-8');
  const sourceFile = ts.createSourceFile(
    modulePath,
    sourceText,
    ts.ScriptTarget.ES2020,
    true,
    ts.ScriptKind.TS
  );

  let interfaceDecl: ts.InterfaceDeclaration | undefined;
  const supporting: ts.Statement[] = [];
  const webfInterfaceDecls: ts.InterfaceDeclaration[] = [];

  for (const stmt of sourceFile.statements) {
    if (ts.isInterfaceDeclaration(stmt)) {
      const name = stmt.name.text;
      if (name.startsWith('WebF')) webfInterfaceDecls.push(stmt);
      supporting.push(stmt);
    } else if (
      ts.isTypeAliasDeclaration(stmt) ||
      ts.isEnumDeclaration(stmt) ||
      ts.isVariableStatement(stmt)
    ) {
      supporting.push(stmt);
    }
  }

  // Prefer the "main module interface": first WebF* interface that declares methods.
  if (!interfaceDecl) {
    interfaceDecl = webfInterfaceDecls.find(decl =>
      decl.members.some(member => ts.isMethodSignature(member))
    );
  }

  if (!interfaceDecl) {
    interfaceDecl = webfInterfaceDecls[0];
  }

  if (!interfaceDecl) {
    throw new Error(
      `No interface starting with "WebF" found in module interface file: ${modulePath}`
    );
  }

  const interfaceName = interfaceDecl.name.text;
  const moduleName = interfaceName.startsWith('WebF')
    ? interfaceName.substring('WebF'.length)
    : interfaceName;

  const printer = ts.createPrinter();
  const methods: ModuleMethodSpec[] = [];

  for (const member of interfaceDecl.members) {
    if (!ts.isMethodSignature(member)) continue;

    const nameNode = member.name;
    const methodName = nameNode.getText(sourceFile);
    if (!methodName || methodName === 'constructor') continue;

    const params = member.parameters.map(param => ({
      name: param.name.getText(sourceFile),
      text: printer.printNode(ts.EmitHint.Unspecified, param, sourceFile),
      typeText: param.type
        ? printer.printNode(ts.EmitHint.Unspecified, param.type, sourceFile)
        : 'any',
    }));

    const returnTypeText = member.type
      ? printer.printNode(ts.EmitHint.Unspecified, member.type, sourceFile)
      : 'Promise<any>';

    let documentation: string | undefined;
    const jsDocs = (member as any).jsDoc as ts.JSDoc[] | undefined;
    if (jsDocs && jsDocs.length > 0) {
      documentation = jsDocs
        .map(doc => doc.comment)
        .filter(Boolean)
        .join('\n');
    }

    methods.push({
      name: methodName,
      jsName: methodName,
      params,
      returnTypeText,
      documentation,
    });
  }

  // Optional module events declaration:
  // `interface WebF<ModuleName>ModuleEvents { scanResult: [Event, Payload]; }`
  const eventsInterfaceName = `${interfaceName}ModuleEvents`;
  const eventsDecl = sourceFile.statements.find(
    stmt => ts.isInterfaceDeclaration(stmt) && stmt.name.text === eventsInterfaceName
  ) as ts.InterfaceDeclaration | undefined;

  let events:
    | {
        interfaceName: string;
        eventNameTypeName: string;
        eventArgsTypeName: string;
        listenerTypeName: string;
        events: ModuleEventSpec[];
      }
    | undefined;

  if (eventsDecl) {
    const eventSpecs: ModuleEventSpec[] = [];
    for (const member of eventsDecl.members) {
      if (!ts.isPropertySignature(member) || !member.name) continue;

      const rawName = member.name.getText(sourceFile);
      const eventName = rawName.replace(/['"]/g, '');

      let eventTypeText = 'Event';
      let extraTypeText = 'any';

      if (member.type) {
        if (ts.isTupleTypeNode(member.type) && member.type.elements.length === 2) {
          eventTypeText = printer.printNode(
            ts.EmitHint.Unspecified,
            member.type.elements[0],
            sourceFile
          );
          extraTypeText = printer.printNode(
            ts.EmitHint.Unspecified,
            member.type.elements[1],
            sourceFile
          );
        } else {
          eventTypeText = printer.printNode(ts.EmitHint.Unspecified, member.type, sourceFile);
        }
      }

      let documentation: string | undefined;
      const jsDocs = (member as any).jsDoc as ts.JSDoc[] | undefined;
      if (jsDocs && jsDocs.length > 0) {
        documentation = jsDocs
          .map(doc => doc.comment)
          .filter(Boolean)
          .join('\n');
      }

      eventSpecs.push({
        name: eventName,
        eventTypeText,
        extraTypeText,
        documentation,
      });
    }

    if (eventSpecs.length > 0) {
      events = {
        interfaceName: eventsInterfaceName,
        eventNameTypeName: `${interfaceName}ModuleEventName`,
        eventArgsTypeName: `${interfaceName}ModuleEventArgs`,
        listenerTypeName: `${interfaceName}ModuleEventListener`,
        events: eventSpecs,
      };
    }
  }

  if (methods.length === 0) {
    throw new Error(
      `Interface ${interfaceName} in ${modulePath} does not declare any methods`
    );
  }

  return {
    interfaceName,
    moduleName,
    methods,
    events,
    supportingStatements: supporting,
    sourceFile,
  };
}

function buildTypesFile(def: ModuleDefinition): string {
  const printer = ts.createPrinter();
  const lines: string[] = [];

  lines.push('// AUTO GENERATED FILE, DO NOT EDIT.');
  lines.push('//');
  lines.push('// Generated by `webf module-codegen`');
  lines.push('');

  for (const stmt of def.supportingStatements) {
    // Skip the main module interface (e.g. WebFShare); we only want supporting types.
    if (ts.isInterfaceDeclaration(stmt) && stmt.name.text === def.interfaceName) {
      continue;
    }

    let printed = printer.printNode(ts.EmitHint.Unspecified, stmt, def.sourceFile);

    // Ensure declarations are exported so types.ts is a proper module.
    if (
      ts.isInterfaceDeclaration(stmt) ||
      ts.isTypeAliasDeclaration(stmt) ||
      ts.isEnumDeclaration(stmt)
    ) {
      const trimmed = printed.trimStart();
      if (!trimmed.startsWith('export ')) {
        const leadingLength = printed.length - trimmed.length;
        const leading = printed.slice(0, leadingLength);
        printed = `${leading}export ${trimmed}`;
      }
    }

    lines.push(printed);
  }

  lines.push('');

  if (def.events) {
    const { interfaceName, eventNameTypeName, eventArgsTypeName, listenerTypeName } = def.events;

    lines.push(`export type ${eventNameTypeName} = Extract<keyof ${interfaceName}, string>;`);
    lines.push(
      `export type ${eventArgsTypeName}<K extends ${eventNameTypeName} = ${eventNameTypeName}> =`
    );
    lines.push(`  ${interfaceName}[K] extends readonly [infer E, infer X]`);
    lines.push(`    ? [event: (E & { type: K }), extra: X]`);
    lines.push(`    : [event: (${interfaceName}[K] & { type: K }), extra: any];`);
    lines.push('');
    lines.push(`export type ${listenerTypeName} = (...args: {`);
    lines.push(`  [K in ${eventNameTypeName}]: ${eventArgsTypeName}<K>;`);
    lines.push(`}[${eventNameTypeName}]) => any;`);
    lines.push('');
  }

  // Ensure file is treated as a module even if no declarations were emitted.
  lines.push('export {};');
  return lines.join('\n');
}

function buildIndexFile(def: ModuleDefinition): string {
  const lines: string[] = [];

  lines.push('/**');
  lines.push(
    ` * Auto-generated WebF module wrapper for "${def.moduleName}".`
  );
  lines.push(' *');
  lines.push(
    ' * This file is generated from a TypeScript interface that describes'
  );
  lines.push(
    ' * the module API. It forwards calls to `webf.invokeModuleAsync` at runtime.'
  );
  lines.push(' */');
  lines.push('');
  lines.push(`import { webf } from '@openwebf/webf-enterprise-typings';`);

  // Import option/result types purely as types so this stays tree-shake friendly.
  const typeImportNames = new Set<string>();
  for (const stmt of def.supportingStatements) {
    if (
      ts.isInterfaceDeclaration(stmt) ||
      ts.isTypeAliasDeclaration(stmt) ||
      ts.isEnumDeclaration(stmt)
    ) {
      const name = stmt.name.text;
      if (name === def.interfaceName) continue;
      typeImportNames.add(name);
    }
  }
  if (def.events) {
    typeImportNames.add(def.events.eventNameTypeName);
    typeImportNames.add(def.events.eventArgsTypeName);
  }
  const typeImportsSorted = Array.from(typeImportNames).sort();
  if (typeImportsSorted.length > 0) {
    lines.push(
      `import type { ${typeImportsSorted.join(', ')} } from './types';`
    );
  }
  lines.push('');

  lines.push(
    `export class ${def.interfaceName} {`
  );
  lines.push(
    '  static isAvailable(): boolean {'
  );
  lines.push(
    "    return typeof webf !== 'undefined' && typeof (webf as any).invokeModuleAsync === 'function';"
  );
  lines.push('  }');
  lines.push('');

  if (def.events) {
    lines.push('  private static _moduleListenerInstalled = false;');
    lines.push(
      '  private static _listeners: Record<string, Set<(event: Event, extra: any) => any>> = Object.create(null);'
    );
    lines.push('');

    lines.push(
      `  static addListener<K extends ${def.events.eventNameTypeName}>(type: K, listener: (...args: ${def.events.eventArgsTypeName}<K>) => any): () => void {`
    );
    lines.push(
      "    if (typeof webf === 'undefined' || typeof (webf as any).addWebfModuleListener !== 'function') {"
    );
    lines.push(
      "      throw new Error('WebF module event API is not available. Make sure you are running in WebF runtime.');"
    );
    lines.push('    }');
    lines.push('');
    lines.push('    if (!this._moduleListenerInstalled) {');
    lines.push(
      `      (webf as any).addWebfModuleListener('${def.moduleName}', (event: Event, extra: any) => {`
    );
    lines.push('        const set = this._listeners[event.type];');
    lines.push('        if (!set) return;');
    lines.push('        for (const fn of set) { fn(event, extra); }');
    lines.push('      });');
    lines.push('      this._moduleListenerInstalled = true;');
    lines.push('    }');
    lines.push('');
    lines.push('    (this._listeners[type] ??= new Set()).add(listener as any);');
    lines.push('');
    lines.push('    const cls = this;');
    lines.push('    return () => {');
    lines.push('      const set = cls._listeners[type];');
    lines.push('      if (!set) return;');
    lines.push('      set.delete(listener as any);');
    lines.push('      if (set.size === 0) { delete cls._listeners[type]; }');
    lines.push('');
    lines.push('      if (Object.keys(cls._listeners).length === 0) {');
    lines.push('        cls.removeListener();');
    lines.push('      }');
    lines.push('    };');
    lines.push('  }');
    lines.push('');

    lines.push('  static removeListener(): void {');
    lines.push('    this._listeners = Object.create(null);');
    lines.push('    this._moduleListenerInstalled = false;');
    lines.push(
      "    if (typeof webf === 'undefined' || typeof (webf as any).removeWebfModuleListener !== 'function') {"
    );
    lines.push('      return;');
    lines.push('    }');
    lines.push(`    (webf as any).removeWebfModuleListener('${def.moduleName}');`);
    lines.push('  }');
    lines.push('');
  }

  for (const method of def.methods) {
    if (method.documentation) {
      lines.push('  /**');
      for (const line of method.documentation.split('\n')) {
        lines.push('   * ' + line);
      }
      lines.push('   */');
    }

    const paramsText = method.params.map(p => p.text).join(', ');
    const argNames = method.params.map(p => p.name).join(', ');

    lines.push(
      `  static async ${method.name}(${paramsText}): ${method.returnTypeText} {`
    );
    lines.push('    if (!this.isAvailable()) {');
    lines.push(
      `      throw new Error('WebF module "${def.moduleName}" is not available. Make sure it is registered via WebF.defineModule().');`
    );
    lines.push('    }');

    const argsPart = argNames ? `, ${argNames}` : '';
    lines.push(
      `    return webf.invokeModuleAsync('${def.moduleName}', '${method.jsName}'${argsPart});`
    );
    lines.push('  }');
    lines.push('');
  }

  lines.push('}');
  lines.push('');
  lines.push(`export type {`);
  const typeExportNames = new Set<string>();
  for (const stmt of def.supportingStatements) {
    if (
      ts.isInterfaceDeclaration(stmt) ||
      ts.isTypeAliasDeclaration(stmt) ||
      ts.isEnumDeclaration(stmt)
    ) {
      const name = stmt.name.text;
      // Do not re-export the main module interface (e.g. WebFShare) to avoid clashes
      // with the generated class of the same name.
      if (name === def.interfaceName) continue;
      typeExportNames.add(stmt.name.text);
    }
  }
  if (def.events) {
    typeExportNames.add(def.events.eventNameTypeName);
    typeExportNames.add(def.events.eventArgsTypeName);
    typeExportNames.add(def.events.listenerTypeName);
  }
  const sorted = Array.from(typeExportNames).sort();
  if (sorted.length) {
    lines.push('  ' + sorted.join(','));
  }
  lines.push(`} from './types';`);
  lines.push('');

  return lines.join('\n');
}

function mapTsReturnTypeToDart(typeText: string): string {
  const raw = typeText.trim();

  // Expect Promise<...> for async module methods
  const promiseMatch = raw.match(/^Promise<(.+)>$/);
  if (!promiseMatch) {
    return 'Future<dynamic>';
  }

  const inner = promiseMatch[1].trim();
  const innerLower = inner.toLowerCase();

  if (innerLower === 'boolean' || innerLower === 'bool') {
    return 'Future<bool>';
  }

  return 'Future<dynamic>';
}

function isTsByteArrayUnion(typeText: string): boolean {
  if (!typeText) return false;
  // Remove parentheses and whitespace
  const cleaned = typeText.replace(/[()]/g, '').trim();
  if (!cleaned) return false;

  const parts = cleaned.split('|').map(p => p.trim()).filter(Boolean);
  if (parts.length === 0) return false;

  const byteTypes = new Set(['ArrayBuffer', 'Uint8Array']);
  const nullable = new Set(['null', 'undefined']);

  let hasByte = false;
  for (const part of parts) {
    if (byteTypes.has(part)) {
      hasByte = true;
      continue;
    }
    if (nullable.has(part)) continue;
    return false;
  }
  return hasByte;
}

function getBaseTypeName(typeText: string): string | null {
  if (!typeText) return null;
  const cleaned = typeText.replace(/[()]/g, '').trim();
  if (!cleaned) return null;

  const parts = cleaned.split('|').map(p => p.trim()).filter(Boolean);
  const nullable = new Set(['null', 'undefined', 'void', 'never']);

  const nonNullable = parts.filter(p => !nullable.has(p));
  if (nonNullable.length !== 1) return null;

  const candidate = nonNullable[0];
  if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(candidate)) {
    return candidate;
  }
  return null;
}

function mapTsParamTypeToDart(
  typeText: string,
  optionNames: Set<string>
): { dartType: string; isByteData: boolean; optionClassName?: string } {
  const raw = typeText.trim();

  if (isTsByteArrayUnion(raw)) {
    return { dartType: 'NativeByteData', isByteData: true };
  }

  const base = getBaseTypeName(raw);
  if (base && optionNames.has(base)) {
    return { dartType: `${base}?`, isByteData: false, optionClassName: base };
  }

  return { dartType: 'dynamic', isByteData: false };
}

function mapTsPropertyTypeToDart(type: ts.TypeNode, optional: boolean): string {
  switch (type.kind) {
    case ts.SyntaxKind.StringKeyword:
      return optional ? 'String?' : 'String';
    case ts.SyntaxKind.NumberKeyword:
      return optional ? 'num?' : 'num';
    case ts.SyntaxKind.BooleanKeyword:
      return optional ? 'bool?' : 'bool';
    default:
      return 'dynamic';
  }
}

function buildDartBindings(def: ModuleDefinition, command: string): string {
  const dartClassBase = `${def.moduleName}Module`;
  const dartBindingsClass = `${dartClassBase}Bindings`;

  const lines: string[] = [];

  lines.push('// AUTO GENERATED FILE, DO NOT EDIT.');
  lines.push('//');
  lines.push('// Generated by `webf module-codegen`');
  lines.push('');
  lines.push("import 'package:webf/module.dart';");
  if (def.events) {
    lines.push("import 'package:webf/dom.dart';");
  }
  if (
    def.methods.some(m =>
      m.params.some(p => isTsByteArrayUnion(p.typeText))
    )
  ) {
    lines.push("import 'package:webf/bridge.dart';");
  }
  lines.push('');

  // Generate Dart classes for supporting TS interfaces (compound option types).
  const optionInterfaces: ts.InterfaceDeclaration[] = [];
  for (const stmt of def.supportingStatements) {
    if (
      ts.isInterfaceDeclaration(stmt) &&
      stmt.name.text !== def.interfaceName &&
      stmt.name.text !== def.events?.interfaceName
    ) {
      optionInterfaces.push(stmt);
    }
  }

  const optionTypeNames = new Set<string>(optionInterfaces.map(i => i.name.text));

  for (const iface of optionInterfaces) {
    const name = iface.name.text;
    const propInfos: { fieldName: string; key: string; dartType: string; optional: boolean }[] = [];

    for (const member of iface.members) {
      if (!ts.isPropertySignature(member) || !member.name) continue;

      const key = member.name.getText(def.sourceFile).replace(/['"]/g, '');
      const fieldName = key;
      const optional = !!member.questionToken;
      const dartType = member.type ? mapTsPropertyTypeToDart(member.type, optional) : 'dynamic';

      propInfos.push({ fieldName, key, dartType, optional });
    }

    lines.push(`class ${name} {`);
    for (const prop of propInfos) {
      lines.push(`  final ${prop.dartType} ${prop.fieldName};`);
    }
    lines.push('');

    const ctorParams = propInfos.map(p => {
      if (p.optional || p.dartType === 'dynamic') {
        return `this.${p.fieldName}`;
      }
      return `required this.${p.fieldName}`;
    }).join(', ');
    lines.push(`  const ${name}({${ctorParams}});`);
    lines.push('');

    lines.push(`  factory ${name}.fromMap(Map<String, dynamic> map) {`);
    lines.push(`    return ${name}(`);
    for (const prop of propInfos) {
      const isString = prop.dartType.startsWith('String');
      const isBool = prop.dartType.startsWith('bool');
      const isNum = prop.dartType.startsWith('num');

      if (isString) {
        if (prop.optional) {
          lines.push(`      ${prop.fieldName}: map['${prop.key}']?.toString(),`);
        } else {
          lines.push(
            `      ${prop.fieldName}: map['${prop.key}']?.toString() ?? '',`
          );
        }
      } else if (isBool) {
        if (prop.optional) {
          lines.push(
            `      ${prop.fieldName}: map['${prop.key}'] is bool ? map['${prop.key}'] as bool : null,`
          );
        } else {
          lines.push(
            `      ${prop.fieldName}: map['${prop.key}'] is bool ? map['${prop.key}'] as bool : false,`
          );
        }
      } else if (isNum) {
        if (prop.optional) {
          lines.push(
            `      ${prop.fieldName}: map['${prop.key}'] is num ? map['${prop.key}'] as num : null,`
          );
        } else {
          lines.push(
            `      ${prop.fieldName}: map['${prop.key}'] is num ? map['${prop.key}'] as num : 0,`
          );
        }
      } else {
        lines.push(`      ${prop.fieldName}: map['${prop.key}'],`);
      }
    }
    lines.push('    );');
    lines.push('  }');
    lines.push('');

    lines.push('  Map<String, dynamic> toMap() {');
    lines.push('    final map = <String, dynamic>{};');
    for (const prop of propInfos) {
      if (!prop.optional && (prop.dartType === 'String' || prop.dartType === 'bool' || prop.dartType === 'num')) {
        lines.push(`    map['${prop.key}'] = ${prop.fieldName};`);
      } else {
        lines.push(
          `    if (${prop.fieldName} != null) { map['${prop.key}'] = ${prop.fieldName}; }`
        );
      }
    }
    lines.push('    return map;');
    lines.push('  }');
    lines.push('');
    lines.push('  Map<String, dynamic> toJson() => toMap();');
    lines.push('}');
    lines.push('');
  }

  lines.push(`abstract class ${dartBindingsClass} extends WebFBaseModule {`);
  lines.push(`  ${dartBindingsClass}(super.moduleManager);`);
  lines.push('');
  lines.push(`  @override`);
  lines.push(`  String get name => '${def.moduleName}';`);
  lines.push('');

  if (def.events) {
    for (const evt of def.events.events) {
      const methodName = `emit${_.upperFirst(_.camelCase(evt.name))}`;

      const mappedExtra = mapTsParamTypeToDart(evt.extraTypeText, optionTypeNames);
      const dataParamType = mappedExtra.optionClassName
        ? `${mappedExtra.optionClassName}?`
        : 'dynamic';

      lines.push(`  dynamic ${methodName}({Event? event, ${dataParamType} data}) {`);
      if (mappedExtra.optionClassName) {
        lines.push('    final mapped = data?.toMap();');
        lines.push(`    return dispatchEvent(event: event ?? Event('${evt.name}'), data: mapped);`);
      } else {
        lines.push(`    return dispatchEvent(event: event ?? Event('${evt.name}'), data: data);`);
      }
      lines.push('  }');
      lines.push('');
    }
  }

  for (const method of def.methods) {
    const dartMethodName = _.camelCase(method.name);
    let dartReturnType = mapTsReturnTypeToDart(method.returnTypeText);

    // If the Promise inner type is one of the option interfaces, map return type to that Dart class.
    const promiseMatch = method.returnTypeText.trim().match(/^Promise<(.+)>$/);
    if (promiseMatch) {
      const inner = promiseMatch[1].trim();
      const baseInner = getBaseTypeName(inner);
      if (baseInner && optionTypeNames.has(baseInner)) {
        dartReturnType = `Future<${baseInner}>`;
      }
    }
    const paramInfos: { name: string; index: number; dartType: string; optionClass?: string }[] = [];

    method.params.forEach((p, index) => {
      const mapped = mapTsParamTypeToDart(p.typeText, optionTypeNames);
      paramInfos.push({
        name: p.name,
        index,
        dartType: mapped.dartType,
        optionClass: mapped.optionClassName,
      });
    });

    const dartParams = paramInfos
      .map(info => `${info.dartType} ${info.name}`)
      .join(', ');
    lines.push(
      `  ${dartReturnType} ${dartMethodName}(${dartParams});`
    );
  }

  lines.push('');
  lines.push('  @override');
  lines.push(
    '  Future<dynamic> invoke(String method, List<dynamic> params) async {'
  );
  lines.push('    switch (method) {');

  for (const method of def.methods) {
    const dartMethodName = _.camelCase(method.name);
    const paramInfos: { name: string; index: number; dartType: string; optionClass?: string }[] = [];

    method.params.forEach((p, index) => {
      const mapped = mapTsParamTypeToDart(p.typeText, optionTypeNames);
      paramInfos.push({
        name: p.name,
        index,
        dartType: mapped.dartType,
        optionClass: mapped.optionClassName,
      });
    });

    // Detect if this method returns a structured Dart class (from TS interface),
    // in which case we should convert the result back to a Map for JS.
    let structuredReturnClass: string | null = null;
    const retMatch = method.returnTypeText.trim().match(/^Promise<(.+)>$/);
    if (retMatch) {
      const inner = retMatch[1].trim();
      const baseInner = getBaseTypeName(inner);
      if (baseInner && optionTypeNames.has(baseInner)) {
        structuredReturnClass = baseInner;
      }
    }

    lines.push(`      case '${method.jsName}': {`);

    // Preprocess option-type parameters (Map -> Dart class instance)
    for (const info of paramInfos) {
      if (!info.optionClass) continue;
      const rawVar = `_raw${info.index}`;
      lines.push(
        `        final ${rawVar} = params.length > ${info.index} ? params[${info.index}] : null;`
      );
      lines.push(
        `        final ${info.name} = ${rawVar} is Map`
        + ` ? ${info.optionClass}.fromMap(Map<String, dynamic>.from(${rawVar} as Map))`
        + ` : (${rawVar} as ${info.optionClass}?);`
      );
    }

    if (paramInfos.length === 0) {
      if (structuredReturnClass) {
        lines.push(`        final result = await ${dartMethodName}();`);
        lines.push('        return result.toMap();');
      } else {
        lines.push(`        return ${dartMethodName}();`);
      }
    } else {
      const callArgs = paramInfos
        .map(info =>
          info.optionClass
            ? info.name
            : `params.length > ${info.index} ? params[${info.index}] : null`
        )
        .join(', ');

      if (structuredReturnClass) {
        lines.push(`        final result = await ${dartMethodName}(${callArgs});`);
        lines.push('        return result.toMap();');
      } else {
        lines.push(`        return ${dartMethodName}(${callArgs});`);
      }
    }

    lines.push('      }');
  }

  lines.push('      default:');
  lines.push(
    "        throw Exception('Unknown method for module ${name}: $method');"
  );
  lines.push('    }');
  lines.push('  }');
  lines.push('}');
  lines.push('');

  return lines.join('\n');
}

export function generateModuleArtifacts(params: {
  moduleInterfacePath: string;
  npmTargetDir: string;
  flutterPackageDir: string;
  command: string;
}): { indexPath: string; typesPath: string; dartBindingsPath: string } {
  const def = parseModuleDefinition(params.moduleInterfacePath);

  const srcDir = path.join(params.npmTargetDir, 'src');
  if (!fs.existsSync(srcDir)) {
    fs.mkdirSync(srcDir, { recursive: true });
  }

  const typesContent = buildTypesFile(def);
  const typesPath = path.join(srcDir, 'types.ts');
  writeIfChangedFromGenerator(typesPath, typesContent);

  const indexContent = buildIndexFile(def);
  const indexPath = path.join(srcDir, 'index.ts');
  writeIfChangedFromGenerator(indexPath, indexContent);

  const dartBindingsContent = buildDartBindings(def, params.command);
  const dartDir = path.join(params.flutterPackageDir, 'lib', 'src');
  if (!fs.existsSync(dartDir)) {
    fs.mkdirSync(dartDir, { recursive: true });
  }
  const dartFileName = `${_.snakeCase(def.moduleName)}_module_bindings_generated.dart`;
  const dartBindingsPath = path.join(dartDir, dartFileName);
  writeIfChangedFromGenerator(dartBindingsPath, dartBindingsContent);

  return { indexPath, typesPath, dartBindingsPath };
}
