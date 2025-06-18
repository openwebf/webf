import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {ParameterType} from "./analyzer";
import {ClassObject, FunctionArgumentType, FunctionDeclaration} from "./declaration";
import {IDLBlob} from "./IDLBlob";
import {getClassName, getPointerType, isPointerType} from "./utils";

function readTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../templates/' + name + '.tpl'), {encoding: 'utf-8'});
}

function generateReturnType(type: ParameterType) {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return pointerType;
  }
  if (type.isArray && typeof type.value === 'object' && !Array.isArray(type.value)) {
    return `${getPointerType(type.value)}[]`;
  }
  switch (type.value) {
    case FunctionArgumentType.int: {
      return 'int';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.any: {
      return 'any';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
    }
    case FunctionArgumentType.dom_string: {
      return 'String';
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
    return `EventHandler`;
  }
  if (pointerType === 'CustomEvent') {
    return `EventHandler<CustomEvent>`;
  }
  throw new Error('Unknown event type: ' + pointerType);
}

function generateAttributeSetter(propName: string, type: ParameterType): string {
  // Attributes from HTML are always strings, so we need to convert them
  switch (type.value) {
    case FunctionArgumentType.boolean:
      return `${propName} = value == 'true' || value == ''`;
    case FunctionArgumentType.int:
      return `${propName} = int.tryParse(value) ?? 0`;
    case FunctionArgumentType.double:
      return `${propName} = double.tryParse(value) ?? 0.0`;
    default:
      // String and other types can be assigned directly
      return `${propName} = value`;
  }
}

function generateAttributeGetter(propName: string, type: ParameterType, optional: boolean): string {
  // For non-nullable types, we might need to handle null values
  if (type.value === FunctionArgumentType.boolean && optional) {
    // For optional booleans that are non-nullable in Dart, default to false
    return `${propName}.toString()`;
  }
  return `${propName}.toString()`;
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

function shouldMakeNullable(prop: any): boolean {
  // Boolean properties should never be nullable in Dart, even if optional in TypeScript
  if (prop.type.value === FunctionArgumentType.boolean) {
    return false;
  }
  // Other optional properties remain nullable
  return prop.optional;
}

export function generateDartClass(blob: IDLBlob, command: string): string {
  const classObjects = blob.objects as ClassObject[];
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
    const props = object.props.map(prop => {
      if (prop.optional) {
        return `${prop.name}?: ${generateReturnType(prop.type)};`;
      }
      return `${prop.name}: ${generateReturnType(prop.type)};`;
    }).join('\n  ');

    return `
interface ${object.name} {
  ${props}
}`;
  }).join('\n\n');

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

  const content = _.template(readTemplate('class.dart'))({
    className: className,
    properties: componentProperties,
    events: componentEvents,
    classObjectDictionary,
    dependencies,
    blob,
    generateReturnType,
    generateMethodDeclaration,
    generateEventHandlerType,
    generateAttributeSetter,
    shouldMakeNullable,
    command,
  });

  return content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
