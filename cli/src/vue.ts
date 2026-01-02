import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {ParameterType} from "./analyzer";
import {ClassObject, FunctionArgumentType, FunctionDeclaration, ConstObject, EnumObject, TypeAliasObject} from "./declaration";
import {IDLBlob} from "./IDLBlob";
import {getPointerType, isPointerType, isUnionType} from "./utils";

function readTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../templates/' + name + '.tpl'), {encoding: 'utf-8'});
}

function generateReturnType(type: ParameterType): string {
  if (isUnionType(type)) {
    const values = type.value as ParameterType[];
    return values.map(v => {
      if (v.value === FunctionArgumentType.null) {
        return 'null';
      }
      if (typeof v.value === 'string') {
        return `'${v.value}'`;
      }
      return 'any';
    }).join(' | ');
  }

  // Handle unions like boolean | null, number | null, CustomType | null
  if (Array.isArray(type.value)) {
    const values = type.value as ParameterType[];
    const hasNull = values.some(v => v.value === FunctionArgumentType.null);
    if (hasNull) {
      const nonNulls = values.filter(v => v.value !== FunctionArgumentType.null);
      if (nonNulls.length === 0) {
        return 'null';
      }
      const parts: string[] = nonNulls.map(v => generateReturnType(v));
      const unique: string[] = Array.from(new Set(parts));
      unique.push('null');
      return unique.join(' | ');
    }
    // Complex non-null unions are rare; fall back to any
    return 'any';
  }

  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    // Map Dart's `Type` (from TS typeof) to TS `any`
    if (pointerType === 'Type') return 'any';
    if (typeof pointerType === 'string' && pointerType.startsWith('typeof ')) {
      const ident = pointerType.substring('typeof '.length).trim();
      return `typeof ${ident}`;
    }
    return pointerType;
  }
  if (type.isArray && typeof type.value === 'object' && !Array.isArray(type.value)) {
    const elemType = generateReturnType(type.value);
    if (!elemType) return 'any[]';
    if (/^[A-Za-z_][A-Za-z0-9_]*(?:\\.[A-Za-z_][A-Za-z0-9_]*)*$/.test(elemType)) {
      return `${elemType}[]`;
    }
    return `(${elemType})[]`;
  }
  switch (type.value) {
    case FunctionArgumentType.int:
    case FunctionArgumentType.double: {
      return 'number';
    }
    case FunctionArgumentType.any: {
      return 'any';
    }
    case FunctionArgumentType.boolean: {
      return 'boolean';
    }
    case FunctionArgumentType.dom_string: {
      return 'string';
    }
    case FunctionArgumentType.void:
      return 'void';
    default:
      return 'void';
  }
}

function generateEventHandlerType(type: ParameterType) {
  if (!isPointerType(type)) {
    throw new Error('Event type must be an instance of Event');
  }
  const pointerType = getPointerType(type);
  if (pointerType === 'Event') {
    return 'Event';
  }
  if (pointerType === 'CustomEvent') {
    return 'CustomEvent';
  }
  // Handle generic types like CustomEvent<T>
  if (pointerType.startsWith('CustomEvent<')) {
    return pointerType;
  }
  throw new Error('Unknown event type: ' + pointerType);
}

function generateMethodDeclaration(method: FunctionDeclaration) {
  var methodName = method.name;
  var args = method.args.map(arg => {
    var argName = arg.name;
    var argType = generateReturnType(arg.type);
    return `${argName}: ${argType}`;
  }).join(', ');
  var returnType = generateReturnType(method.returnType);
  return `${methodName}(${args}): ${returnType};`;
}

type VueComponentSpec = {
  className: string;
  properties?: ClassObject;
  events?: ClassObject;
  methods?: ClassObject;
};

function getVueComponentSpecs(blob: IDLBlob): VueComponentSpec[] {
  const classObjects = blob.objects.filter(obj => obj instanceof ClassObject) as ClassObject[];
  if (classObjects.length === 0) return [];

  const properties = classObjects.filter(object => object.name.endsWith('Properties'));
  const events = classObjects.filter(object => object.name.endsWith('Events'));
  const methods = classObjects.filter(object => object.name.endsWith('Methods'));

  const componentMap = new Map<string, VueComponentSpec>();

  properties.forEach(prop => {
    const className = prop.name.replace(/Properties$/, '');
    if (!componentMap.has(className)) componentMap.set(className, { className });
    componentMap.get(className)!.properties = prop;
  });

  events.forEach(ev => {
    const className = ev.name.replace(/Events$/, '');
    if (!componentMap.has(className)) componentMap.set(className, { className });
    componentMap.get(className)!.events = ev;
  });

  methods.forEach(m => {
    const className = m.name.replace(/Methods$/, '');
    if (!componentMap.has(className)) componentMap.set(className, { className });
    componentMap.get(className)!.methods = m;
  });

  return Array.from(componentMap.values())
    .filter(spec => spec.className.trim().length > 0)
    .sort((a, b) => a.className.localeCompare(b.className));
}

function renderSupportingInterface(object: ClassObject): string {
  const hasProps = !!object.props && object.props.length > 0;
  const hasMethods = !!object.methods && object.methods.length > 0;
  if (!hasProps && !hasMethods) {
    return '';
  }

  const interfaceLines: string[] = [];

  if (object.documentation && object.documentation.trim().length > 0) {
    interfaceLines.push('/**');
    object.documentation.split('\n').forEach(line => {
      interfaceLines.push(` * ${line}`);
    });
    interfaceLines.push(' */');
  }

  interfaceLines.push(`export interface ${object.name} {`);

  const propLines = (object.props || []).map(prop => {
    const lines: string[] = [];

    if (prop.documentation && prop.documentation.trim().length > 0) {
      lines.push('  /**');
      prop.documentation.split('\n').forEach(line => {
        lines.push(`   * ${line}`);
      });
      lines.push('   */');
    }

    const optionalToken = prop.optional ? '?' : '';
    lines.push(`  ${prop.name}${optionalToken}: ${generateReturnType(prop.type)};`);

    return lines.join('\n');
  });

  interfaceLines.push(propLines.join('\n'));

  if (object.methods && object.methods.length > 0) {
    const methodLines = object.methods.map(method => {
      return `  ${generateMethodDeclaration(method)}`;
    });
    interfaceLines.push(methodLines.join('\n'));
  }

  interfaceLines.push('}');

  return interfaceLines.join('\n');
}

function toVueTagName(rawClassName: string): string {
  const className = rawClassName.trim();

  if (className.startsWith('WebF')) {
    const withoutPrefix = className.substring(4);
    const suffix = _.kebabCase(withoutPrefix);
    return suffix.length > 0 ? 'webf-' + suffix : 'webf';
  }

  if (className.startsWith('Flutter')) {
    const withoutPrefix = className.substring(7);
    const suffix = _.kebabCase(withoutPrefix);
    return suffix.length > 0 ? 'flutter-' + suffix : 'flutter';
  }

  const kebab = _.kebabCase(className);
  return kebab.replace(/^web-f-/, 'webf-');
}

export function generateVueTypings(blobs: IDLBlob[]) {
  const componentSpecMap = new Map<string, VueComponentSpec>();
  blobs
    .flatMap(blob => getVueComponentSpecs(blob))
    .forEach(spec => {
      if (!componentSpecMap.has(spec.className)) componentSpecMap.set(spec.className, spec);
    });

  const componentSpecs = Array.from(componentSpecMap.values()).sort((a, b) => a.className.localeCompare(b.className));
  const componentNames = componentSpecs.map(spec => spec.className);

  const components = componentSpecs.map(spec => {
    const content = _.template(readTemplate('vue.component.partial'))({
      className: spec.className,
      properties: spec.properties,
      events: spec.events,
      methods: spec.methods,
      generateReturnType,
      generateMethodDeclaration,
      generateEventHandlerType,
    });

    return content.split('\n').filter(str => str.trim().length > 0).join('\n');
  }).filter(Boolean).join('\n\n');

  // Collect declare consts across blobs and render as exported ambient declarations
  const consts = blobs
    .flatMap(blob => blob.objects)
    .filter(obj => obj instanceof ConstObject) as ConstObject[];

  // Deduplicate by name keeping first occurrence
  const uniqueConsts = new Map<string, ConstObject>();
  consts.forEach(c => {
    if (!uniqueConsts.has(c.name)) uniqueConsts.set(c.name, c);
  });

  const constDeclarations = Array.from(uniqueConsts.values())
    .sort((a, b) => a.name.localeCompare(b.name))
    .map(c => `export declare const ${c.name}: ${c.type};`)
    .join('\n');

  // Collect declare enums across blobs
  const enums = blobs
    .flatMap(blob => blob.objects)
    .filter(obj => obj instanceof EnumObject) as EnumObject[];

  const uniqueEnums = new Map<string, EnumObject>();
  enums.forEach(e => {
    if (!uniqueEnums.has(e.name)) uniqueEnums.set(e.name, e);
  });

  const enumDeclarations = Array.from(uniqueEnums.values())
    .sort((a, b) => a.name.localeCompare(b.name))
    .map(e => {
      const members = e.members.map(m => m.initializer ? `${m.name} = ${m.initializer}` : `${m.name}`).join(', ');
      return `export declare enum ${e.name} { ${members} }`;
    })
    .join('\n');

  // Collect type aliases across blobs and render as exported declarations.
  const typeAliases = blobs
    .flatMap(blob => blob.objects)
    .filter(obj => obj instanceof TypeAliasObject) as TypeAliasObject[];

  const uniqueTypeAliases = new Map<string, TypeAliasObject>();
  typeAliases.forEach(t => {
    if (!uniqueTypeAliases.has(t.name)) uniqueTypeAliases.set(t.name, t);
  });

  const typeAliasDeclarations = Array.from(uniqueTypeAliases.values())
    .sort((a, b) => a.name.localeCompare(b.name))
    .map(t => `export type ${t.name} = ${t.type};`)
    .join('\n');

  // Collect supporting interfaces (non-component interfaces) so referenced types exist.
  const supportingInterfaces = blobs
    .flatMap(blob => blob.objects)
    .filter(obj => obj instanceof ClassObject) as ClassObject[];

  const supporting = supportingInterfaces.filter(obj => {
    return !obj.name.endsWith('Properties') && !obj.name.endsWith('Events') && !obj.name.endsWith('Methods');
  });

  const uniqueSupporting = new Map<string, ClassObject>();
  supporting.forEach(obj => {
    if (!uniqueSupporting.has(obj.name)) uniqueSupporting.set(obj.name, obj);
  });

  const supportingDeclarations = Array.from(uniqueSupporting.values())
    .sort((a, b) => a.name.localeCompare(b.name))
    .map(obj => renderSupportingInterface(obj))
    .filter(Boolean)
    .join('\n\n');

  // Build mapping of template tag names to class names for GlobalComponents
  const componentMetas = componentNames.map(className => ({
    className,
    tagName: toVueTagName(className),
  }));

  const content = _.template(readTemplate('vue.components.d.ts'), {
    interpolate: /<%=([\s\S]+?)%>/g,
    evaluate: /<%([\s\S]+?)%>/g,
    escape: /<%-([\s\S]+?)%>/g
  })({
    componentNames,
    componentMetas,
    components,
    consts: constDeclarations,
    enums: enumDeclarations,
    typeAliases: typeAliasDeclarations,
    dependencies: supportingDeclarations,
  });

  return content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
