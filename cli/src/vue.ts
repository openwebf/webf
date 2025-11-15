import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {ParameterType} from "./analyzer";
import {ClassObject, FunctionArgumentType, FunctionDeclaration, ConstObject, EnumObject} from "./declaration";
import {IDLBlob} from "./IDLBlob";
import { debug } from './logger';
import {getPointerType, isPointerType} from "./utils";

function readTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../templates/' + name + '.tpl'), {encoding: 'utf-8'});
}

function generateReturnType(type: ParameterType) {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    // Map Dart's `Type` (from TS typeof) to TS `any`
    if (pointerType === 'Type') return 'any';
    if (typeof pointerType === 'string' && pointerType.startsWith('typeof ')) {
      const ident = pointerType.substring('typeof '.length).trim();
      return `typeof __webfTypes.${ident}`;
    }
    return pointerType;
  }
  if (type.isArray && typeof type.value === 'object' && !Array.isArray(type.value)) {
    const elemType = getPointerType(type.value);
    if (elemType === 'Type') return 'any[]';
    if (typeof elemType === 'string' && elemType.startsWith('typeof ')) {
      const ident = elemType.substring('typeof '.length).trim();
      return `(typeof __webfTypes.${ident})[]`;
    }
    return `${elemType}[]`;
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

function generateVueComponent(blob: IDLBlob) {
  const classObjects = blob.objects as ClassObject[];
  
  // Skip if no class objects
  if (!classObjects || classObjects.length === 0) {
    return '';
  }
  const classObjectDictionary = Object.fromEntries(
    classObjects.map(object => {
      return [object.name, object];
    })
  );

  const properties = classObjects.filter(object => {
    return object.name.endsWith('Properties');
  });
  const events = classObjects.filter(object => {
    return object.name.endsWith('Events');
  });

  const others = classObjects.filter(object => {
    return !object.name.endsWith('Properties')
      && !object.name.endsWith('Events');
  });

  const dependencies = others.map(object => {
    if (!object || !object.props || object.props.length === 0) {
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

    interfaceLines.push(`interface ${object.name} {`);

    const propLines = object.props.map(prop => {
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
    interfaceLines.push('}');

    return interfaceLines.join('\n');
  }).filter(dep => dep.trim() !== '').join('\n\n');

  const componentProperties = properties.length > 0 ? properties[0] : undefined;
  const componentEvents = events.length > 0 ? events[0] : undefined;
  const className = (() => {
    if (componentProperties) {
      return componentProperties.name.replace(/Properties$/, '');
    }
    if (componentEvents) {
      return componentEvents.name.replace(/Events$/, '');
    }
    return '';
  })();

  if (!className) {
    return '';
  }

  const content = _.template(readTemplate('vue.component.partial'))({
    className: className,
    properties: componentProperties,
    events: componentEvents,
    classObjectDictionary,
    dependencies,
    blob,
    generateReturnType,
    generateMethodDeclaration,
    generateEventHandlerType,
  });

  const result = content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');

  return result;
}

function toVueTagName(className: string): string {
  if (className.startsWith('WebF')) {
    const withoutPrefix = className.substring(4);
    return 'web-f-' + _.kebabCase(withoutPrefix);
  } else if (className.startsWith('Flutter')) {
    const withoutPrefix = className.substring(7);
    return 'flutter-' + _.kebabCase(withoutPrefix);
  }
  return _.kebabCase(className);
}

export function generateVueTypings(blobs: IDLBlob[]) {
  const componentNames = blobs.map(blob => {
    const classObjects = blob.objects as ClassObject[];

    const properties = classObjects.filter(object => {
      return object.name.endsWith('Properties');
    });
    const events = classObjects.filter(object => {
      return object.name.endsWith('Events');
    });

    const componentProperties = properties.length > 0 ? properties[0] : undefined;
    const componentEvents = events.length > 0 ? events[0] : undefined;
    const className = (() => {
      if (componentProperties) {
        return componentProperties.name.replace(/Properties$/, '');
      }
      if (componentEvents) {
        return componentEvents.name.replace(/Events$/, '');
      }
      return '';
    })();
    return className;
  }).filter(name => {
    return name.length > 0;
  });
  const components = blobs.map(blob => {
    return generateVueComponent(blob);
  }).filter(component => {
    return component.length > 0;
  }).join('\n\n');

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
    .map(c => `export declare const ${c.name}: ${c.type};`)
    .join('\n');

  // Collect declare enums across blobs
  const enums = blobs
    .flatMap(blob => blob.objects)
    .filter(obj => obj instanceof EnumObject) as EnumObject[];

  const enumDeclarations = enums.map(e => {
    const members = e.members.map(m => m.initializer ? `${m.name} = ${m.initializer}` : `${m.name}`).join(', ');
    return `export declare enum ${e.name} { ${members} }`;
  }).join('\n');

  // Always import the types namespace to support typeof references
  const typesImport = `import * as __webfTypes from './src/types';`;
  debug(`[vue] Generating typings; importing types from ./src/types`);

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
    typesImport,
  });

  return content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
