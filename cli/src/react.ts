import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {ParameterType} from "./analyzer";
import {ClassObject, FunctionArgumentType, FunctionDeclaration} from "./declaration";
import {IDLBlob} from "./IDLBlob";
import {getPointerType, isPointerType} from "./utils";

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
    return `EventHandler<SyntheticEvent<Element>>`;
  }
  if (pointerType === 'CustomEvent') {
    return `EventHandler<SyntheticEvent<Element, CustomEvent>>`;
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

function toReactEventName(name: string) {
  const eventName = 'on-' + name;
  return _.camelCase(eventName);
}

export function generateReactComponent(blob: IDLBlob) {
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

  const content = _.template(readTemplate('react.component.tsx'))({
    className: className,
    properties: componentProperties,
    events: componentEvents,
    classObjectDictionary,
    dependencies,
    blob,
    toReactEventName,
    generateReturnType,
    generateMethodDeclaration,
    generateEventHandlerType,
  });

  const result = content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');

  return result;
}

export function generateReactIndex(blobs: IDLBlob[]) {
  const components = blobs.map(blob => {
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
    return {
      className: className,
      fileName: blob.filename,
    }
  }).filter(name => {
    return name.className.length > 0;
  });
  const content = _.template(readTemplate('react.index.ts'))({
    components,
  });

  return content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
