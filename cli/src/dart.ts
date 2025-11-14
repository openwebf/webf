import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {ParameterType} from "./analyzer";
import {ClassObject, FunctionArgumentType, FunctionDeclaration, TypeAliasObject, PropsDeclaration, EnumObject} from "./declaration";
import {IDLBlob} from "./IDLBlob";
import {getPointerType, isPointerType} from "./utils";

function readTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../templates/' + name + '.tpl'), {encoding: 'utf-8'});
}

// Generate enum name from property name
function getEnumName(className: string, propName: string): string {
  // Remove 'Properties' or 'Bindings' suffix from className
  const baseName = className.replace(/Properties$|Bindings$/, '');
  // Convert to PascalCase
  return baseName + _.upperFirst(_.camelCase(propName));
}

// Check if a type is a union of string literals
function isStringUnionType(type: ParameterType): boolean {
  if (!Array.isArray(type.value)) return false;
  
  // For now, we'll consider any union type as potentially a string union
  // and let getUnionStringValues determine if it actually contains string literals
  return type.value.length > 1;
}

// Extract string literal values from union type
function getUnionStringValues(prop: PropsDeclaration, blob: IDLBlob): string[] | null {
  if (!isStringUnionType(prop.type)) return null;
  
  // Try to get the actual string values from the source TypeScript file
  const sourceContent = blob.raw;
  if (!sourceContent) return null;
  
  // Look for the property definition in the source
  // Need to escape special characters in property names (like value-color)
  const escapedPropName = prop.name.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
  const propPattern = new RegExp(`['"]?${escapedPropName}['"]?\\s*\\?\\s*:\\s*([^;]+);`);
  const match = sourceContent.match(propPattern);
  if (!match) return null;
  
  // Extract string literals from union type
  const unionType = match[1];
  const literalPattern = /'([^']+)'|"([^"]+)"/g;
  const values: string[] = [];
  let literalMatch;
  
  while ((literalMatch = literalPattern.exec(unionType)) !== null) {
    values.push(literalMatch[1] || literalMatch[2]);
  }
  
  return values.length > 0 ? values : null;
}

// Generate Dart enum from string values
function generateDartEnum(enumName: string, values: string[]): string {
  const enumValues = values.map(value => {
    // Convert kebab-case to camelCase for enum values
    const enumValue = _.camelCase(value);
    return `  ${enumValue}('${value}')`;
  }).join(',\n');
  
  return `enum ${enumName} {
${enumValues};

  final String value;
  const ${enumName}(this.value);
  
  static ${enumName}? parse(String? value) {
    if (value == null) return null;
    return ${enumName}.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid ${enumName} value: $value'),
    );
  }
  
  @override
  String toString() => value;
}`
}

function generateReturnType(type: ParameterType, enumName?: string) {
  // Handle union types first (e.g., 'left' | 'center' | 'right')
  // so we don't incorrectly treat string literal unions as pointer types.
  if (Array.isArray(type.value)) {
    // If we have an enum name, use it; otherwise fall back to String
    return enumName || 'String';
  }

  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    // Map TS typeof expressions to Dart dynamic
    if (typeof pointerType === 'string' && pointerType.startsWith('typeof ')) {
      return 'dynamic';
    }
    // Map references to known string enums to String in Dart
    if (typeof pointerType === 'string' && EnumObject.globalEnumSet.has(pointerType)) {
      return 'String';
    }
    return pointerType;
  }
  if (type.isArray && typeof type.value === 'object' && !Array.isArray(type.value)) {
    const elem = getPointerType(type.value);
    if (typeof elem === 'string' && elem.startsWith('typeof ')) {
      return `dynamic[]`;
    }
    if (typeof elem === 'string' && EnumObject.globalEnumSet.has(elem)) {
      return 'String[]';
    }
    return `${elem}[]`;
  }
  
  // Handle when type.value is a ParameterType object (nested type)
  if (typeof type.value === 'object' && !Array.isArray(type.value) && type.value !== null) {
    // This might be a nested ParameterType, recurse
    return generateReturnType(type.value as ParameterType, enumName);
  }
  
  switch (type.value) {
    case FunctionArgumentType.int: {
      return 'int';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.any: {
      // Dart doesn't have `any`; use `dynamic`.
      return 'dynamic';
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

function generateAttributeSetter(propName: string, type: ParameterType, enumName?: string): string {
  // Attributes from HTML are always strings, so we need to convert them
  
  // Handle enum types
  if (enumName && Array.isArray(type.value)) {
    return `${propName} = ${enumName}.parse(value)`;
  }
  
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

function generateAttributeGetter(propName: string, type: ParameterType, optional: boolean, enumName?: string): string {
  // Handle enum types
  if (enumName && Array.isArray(type.value)) {
    return optional ? `${propName}?.value` : `${propName}.value`;
  }
  
  // Handle nullable properties - they should return null if the value is null
  if (optional && type.value !== FunctionArgumentType.boolean) {
    // For nullable properties, we need to handle null values properly
    return `${propName}?.toString()`;
  }
  // For non-nullable properties (including booleans), always convert to string
  return `${propName}.toString()`;
}

function generateAttributeDeleter(propName: string, type: ParameterType, optional: boolean): string {
  // When deleting an attribute, we should reset it to its default value
  switch (type.value) {
    case FunctionArgumentType.boolean:
      // Booleans default to false
      return `${propName} = false`;
    case FunctionArgumentType.int:
      // Integers default to 0
      return `${propName} = 0`;
    case FunctionArgumentType.double:
      // Doubles default to 0.0
      return `${propName} = 0.0`;
    case FunctionArgumentType.dom_string:
      // Strings default to empty string or null for optional
      if (optional) {
        return `${propName} = null`;
      }
      return `${propName} = ''`;
    default:
      // For other types, set to null if optional, otherwise empty string
      if (optional) {
        return `${propName} = null`;
      }
      return `${propName} = ''`;
  }
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
  // Dynamic (any) should not use nullable syntax; dynamic already allows null
  if (prop.type.value === FunctionArgumentType.any) {
    return false;
  }
  // Other optional properties remain nullable
  return prop.optional;
}

// Export for testing
export { isStringUnionType, getUnionStringValues };

export function generateDartClass(blob: IDLBlob, command: string): string {
  const classObjects = blob.objects.filter(obj => obj instanceof ClassObject) as ClassObject[];
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
  
  // Generate enums for union types
  const enums: { name: string; definition: string }[] = [];
  const enumMap: Map<string, string> = new Map(); // camelCase prop name -> enum name
  
  if (componentProperties) {
    for (const prop of componentProperties.props) {
      if (isStringUnionType(prop.type)) {
        const values = getUnionStringValues(prop, blob);
        if (values && values.length > 0) {
          const enumName = getEnumName(componentProperties.name, prop.name);
          enums.push({
            name: enumName,
            definition: generateDartEnum(enumName, values)
          });
          // Store by camelCase prop name to match template usage
          enumMap.set(_.camelCase(prop.name), enumName);
        }
      }
    }
  }

  const content = _.template(readTemplate('class.dart'))({
    className: className,
    properties: componentProperties,
    events: componentEvents,
    classObjectDictionary,
    dependencies,
    blob,
    generateReturnType: (type: ParameterType, propName?: string) => {
      // If we have a prop name, check if it has an enum
      if (propName && enumMap.has(propName)) {
        return enumMap.get(propName)!;
      }
      return generateReturnType(type);
    },
    generateMethodDeclaration,
    generateEventHandlerType,
    generateAttributeSetter: (propName: string, type: ParameterType) => {
      return generateAttributeSetter(propName, type, enumMap.get(propName));
    },
    generateAttributeGetter: (propName: string, type: ParameterType, optional: boolean) => {
      return generateAttributeGetter(propName, type, optional, enumMap.get(propName));
    },
    generateAttributeDeleter,
    shouldMakeNullable,
    command,
    enums,
    enumMap,
  });

  return content.split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
