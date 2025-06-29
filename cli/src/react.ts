import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {ParameterType} from "./analyzer";
import {ClassObject, FunctionArgumentType, FunctionDeclaration, TypeAliasObject} from "./declaration";
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

function getEventType(type: ParameterType) {
  if (!isPointerType(type)) {
    return 'Event';
  }
  const pointerType = getPointerType(type);
  if (pointerType === 'CustomEvent') {
    return 'CustomEvent';
  }
  // For specific event types like MouseEvent, TouchEvent, etc.
  if (pointerType.endsWith('Event')) {
    return pointerType;
  }
  return 'Event';
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

export function generateReactComponent(blob: IDLBlob, packageName?: string, relativeDir?: string) {
  const classObjects = blob.objects.filter(obj => obj instanceof ClassObject) as ClassObject[];
  const typeAliases = blob.objects.filter(obj => obj instanceof TypeAliasObject) as TypeAliasObject[];
  
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

  // Include type aliases
  const typeAliasDeclarations = typeAliases.map(typeAlias => {
    return `type ${typeAlias.name} = ${typeAlias.type};`;
  }).join('\n');
  
  const dependencies = [
    typeAliasDeclarations,
    others.map(object => {
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
    }).join('\n\n')
  ].filter(Boolean).join('\n\n');

  // Generate all components from this file
  const components: string[] = [];
  
  // Create a map of component names to their properties and events
  const componentMap = new Map<string, { properties?: ClassObject, events?: ClassObject }>();
  
  // Process all Properties interfaces
  properties.forEach(prop => {
    const componentName = prop.name.replace(/Properties$/, '');
    if (!componentMap.has(componentName)) {
      componentMap.set(componentName, {});
    }
    componentMap.get(componentName)!.properties = prop;
  });
  
  // Process all Events interfaces
  events.forEach(event => {
    const componentName = event.name.replace(/Events$/, '');
    if (!componentMap.has(componentName)) {
      componentMap.set(componentName, {});
    }
    componentMap.get(componentName)!.events = event;
  });
  
  // If we have multiple components, we need to generate a combined file
  const componentEntries = Array.from(componentMap.entries());
  
  if (componentEntries.length === 0) {
    return '';
  }
  
  if (componentEntries.length === 1) {
    // Single component - use existing template
    const [className, component] = componentEntries[0];
    
    // Determine the import path for createWebFComponent
    const isReactCoreUI = packageName === '@openwebf/react-core-ui';
    let createWebFComponentImport: string;
    
    if (isReactCoreUI && relativeDir) {
      // Calculate relative path from current file to utils/createWebFComponent
      // Files are generated in src/<relativeDir>/ and need to import from src/utils/
      const depth = relativeDir.split('/').filter(p => p).length;
      const upPath = '../'.repeat(depth);
      createWebFComponentImport = `import { createWebFComponent, WebFElementWithMethods } from "${upPath}utils/createWebFComponent";`;
    } else {
      createWebFComponentImport = `import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";`;
    }
    
    const templateContent = readTemplate('react.component.tsx')
      .replace(
        'import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";',
        createWebFComponentImport
      );
    
    const content = _.template(templateContent)({
      className: className,
      properties: component.properties,
      events: component.events,
      classObjectDictionary,
      dependencies,
      blob,
      toReactEventName,
      generateReturnType,
      generateMethodDeclaration,
      generateEventHandlerType,
      getEventType,
    });

    return content.split('\n').filter(str => {
      return str.trim().length > 0;
    }).join('\n');
  }
  
  // Multiple components - generate with shared imports
  const componentDefinitions: string[] = [];
  
  // Determine the import path for createWebFComponent
  const isReactCoreUI = packageName === '@openwebf/react-core-ui';
  let createWebFComponentImport: string;
  
  if (isReactCoreUI && relativeDir) {
    // Calculate relative path from current file to utils/createWebFComponent
    // Files are generated in src/<relativeDir>/ and need to import from src/utils/
    const depth = relativeDir.split('/').filter(p => p).length;
    const upPath = '../'.repeat(depth);
    createWebFComponentImport = `import { createWebFComponent, WebFElementWithMethods } from "${upPath}utils/createWebFComponent";`;
  } else {
    createWebFComponentImport = `import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";`;
  }
  
  componentEntries.forEach(([className, component]) => {
    const content = _.template(readTemplate('react.component.tsx'))({
      className: className,
      properties: component.properties,
      events: component.events,
      classObjectDictionary,
      dependencies: '', // Dependencies will be at the top
      blob,
      toReactEventName,
      generateReturnType,
      generateMethodDeclaration,
      generateEventHandlerType,
      getEventType,
    });
    
    // Remove the import statements from all but the first component
    const lines = content.split('\n');
    const withoutImports = lines.filter(line => {
      return !line.startsWith('import ');
    }).join('\n');
    
    componentDefinitions.push(withoutImports);
  });
  
  // Combine with shared imports at the top
  const result = [
    'import React from "react";',
    createWebFComponentImport,
    '',
    dependencies,
    '',
    ...componentDefinitions
  ].filter(line => line !== undefined).join('\n');
  
  return result.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function generateReactIndex(blobs: IDLBlob[]) {
  const components = blobs.flatMap(blob => {
    const classObjects = blob.objects.filter(obj => obj instanceof ClassObject) as ClassObject[];

    const properties = classObjects.filter(object => {
      return object.name.endsWith('Properties');
    });
    const events = classObjects.filter(object => {
      return object.name.endsWith('Events');
    });

    // Create a map of component names
    const componentMap = new Map<string, boolean>();
    
    // Add all components from Properties interfaces
    properties.forEach(prop => {
      const componentName = prop.name.replace(/Properties$/, '');
      componentMap.set(componentName, true);
    });
    
    // Add all components from Events interfaces
    events.forEach(event => {
      const componentName = event.name.replace(/Events$/, '');
      componentMap.set(componentName, true);
    });
    
    // Return an array of all components from this file
    return Array.from(componentMap.keys()).map(className => ({
      className: className,
      fileName: blob.filename,
      relativeDir: blob.relativeDir,
    }));
  }).filter(component => {
    return component.className.length > 0;
  });
  
  const content = _.template(readTemplate('react.index.ts'))({
    components,
  });

  return content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
