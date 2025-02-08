import fs from 'fs';
import path from 'path';
import _ from 'lodash';
import {getTemplateKind, TemplateKind} from '../generateHeader';
import {GenerateOptions, generateSupportedOptions} from '../generator';
import {IDLBlob} from '../IDLBlob';
import {ClassObject, FunctionArguments, FunctionArgumentType} from '../declaration';
import {getPointerType, isPointerType} from '../generateSource';
import {ParameterType} from '../analyzer';
import {isAnyType, isStringType} from './cppGen';

function readSourceTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../../templates/idl_templates/plugin_api_templates/' + name + '.rs.tpl'), {encoding: 'utf-8'});
}

function isVoidType(type: ParameterType) {
  return type.value === FunctionArgumentType.void;
}

function generatePublicReturnTypeValue(type: ParameterType) {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `RustValue<${pointerType}RustMethods>`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'i64';
    }
    case FunctionArgumentType.int32: {
      return 'i64';
    }
    case FunctionArgumentType.double: {
      return 'c_double';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.boolean: {
      return 'i32';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return '*const c_char';
    }
    case FunctionArgumentType.void:
      return 'c_void';
    default:
      return 'void*';
  }
}

function generateMethodReturnType(type: ParameterType) {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `${pointerType}`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'i64';
    }
    case FunctionArgumentType.int32: {
      return 'i64';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.double: {
      return 'f64';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return 'String';
    }
    case FunctionArgumentType.void:
      return '()';
    default:
      return 'void*';
  }
}

function generatePublicParameterType(type: ParameterType): string {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `${pointerType}*`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'i64';
    }
    case FunctionArgumentType.int32: {
      return 'i64';
    }
    case FunctionArgumentType.double: {
      return 'c_double';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.boolean: {
      return 'i32';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return '*const c_char';
    }
    default:
      return 'void*';
  }
}

function generatePublicParametersType(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generatePublicParameterType(param.type)}`;
  }).join(', ') + ', ';
}

function generatePublicParametersTypeWithName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generatePublicParameterType(param.type)} ${param.name}`;
  }).join(', ') + ', ';
}

function generatePublicParametersName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${param.name}`;
  }).join(', ') + ', ';
}

function generateMethodParameterType(type: ParameterType): string {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `${pointerType}*`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'i64';
    }
    case FunctionArgumentType.int32: {
      return 'i64';
    }
    case FunctionArgumentType.double: {
      return 'f64';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return '&str';
    }
    default:
      return 'void*';
  }
}

function generateMethodParametersType(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generateMethodParameterType(param.type)}`;
  }).join(', ') + ', ';
}

function generateMethodParametersTypeWithName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generateValidRustIdentifier(param.name)}: ${generateMethodParameterType(param.type)}`;
  }).join(', ') + ', ';
}

function generateMethodParametersName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    switch (param.type.value) {
      case FunctionArgumentType.dom_string:
      case FunctionArgumentType.legacy_dom_string: {
        return `CString::new(${generateValidRustIdentifier(param.name)}).unwrap().as_ptr()`;
      }
      case FunctionArgumentType.boolean: {
        return `i32::from(${generateValidRustIdentifier(param.name)})`;
      }
      case FunctionArgumentType.any:
        return `${param.name}`;
      default:
        return `${generateValidRustIdentifier(param.name)}`;
    }
  }).join(', ') + ', ';
}

function generateParentMethodParametersName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generateValidRustIdentifier(param.name)}`;
  }).join(', ') + ', ';
}

function getClassName(blob: IDLBlob) {
  let raw = _.camelCase(blob.filename[0].toUpperCase() + blob.filename.slice(1));
  if (raw.slice(0, 3) == 'dom') {
    return 'DOM' + raw.slice(3);
  }
  if (raw.slice(0, 4) == 'html') {
    // Legacy support names.
    if (raw === 'htmlIframeElement') {
      return `HTMLIFrameElement`;
    }
    return 'HTML' + raw.slice(4);
  }
  if (raw.slice(0, 6) == 'svgSvg') {
    // special for SVGSVGElement
    return 'SVGSVG' + raw.slice(6)
  }
  if (raw.slice(0, 3) == 'svg') {
    return 'SVG' + raw.slice(3)
  }
  if (raw.slice(0, 3) == 'css') {
    return 'CSS' + raw.slice(3);
  }
  if (raw.slice(0, 2) == 'ui') {
    return 'UI' + raw.slice(2);
  }

  return `${raw[0].toUpperCase() + raw.slice(1)}`;
}

function generateValidRustIdentifier(name: string) {
  const rustKeywords = [
    'type',
  ];
  let identifier = _.snakeCase(name);
  return rustKeywords.includes(identifier) ? `${identifier}_` : identifier;
}

function generateMethodReturnStatements(type: ParameterType) {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `Ok(${pointerType}::initialize(value.value, self.context(), value.method_pointer, value.status))`;
  }
  switch (type.value) {
    case FunctionArgumentType.boolean: {
      return 'Ok(value != 0)';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return `let value = unsafe { std::ffi::CStr::from_ptr(value) };
    Ok(value.to_str().unwrap().to_string())`;
    }
    default:
      return 'Ok(value)';
  }
}

function generatePropReturnStatements(type: ParameterType) {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `${pointerType}::initialize(value.value, self.context(), value.method_pointer, value.status)`;
  }
  switch (type.value) {
    case FunctionArgumentType.boolean: {
      return 'value != 0';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return `let value = unsafe { std::ffi::CStr::from_ptr(value) };
    value.to_str().unwrap().to_string()`;
    }
    case FunctionArgumentType.any: {
      return `value`;
    }
    default:
      return 'value';
  }
}

function generateRustSourceFile(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = readSourceTemplate('base');
  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null) return '';

    switch(templateKind) {
      case TemplateKind.Interface: {
        object = object as ClassObject;

        const inheritedObjects: ClassObject[] = [];

        let currentParentObject = object;
        while (currentParentObject.parent) {
          const parentObject = ClassObject.globalClassMap[currentParentObject.parent];
          inheritedObjects.push(parentObject);
          currentParentObject = parentObject;
        }

        const subClasses: string[] = [];

        function appendSubClasses(name: string) {
          ClassObject.globalClassRelationMap[name]?.forEach(subClass => {
            subClasses.push(subClass);
            appendSubClasses(subClass);
          });
        }

        if (object.name in ClassObject.globalClassRelationMap) {
          appendSubClasses(object.name);
        }

        return _.template(readSourceTemplate('interface'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          blob,
          object,
          inheritedObjects,
          isPointerType,
          generatePublicReturnTypeValue,
          generatePublicParametersType,
          generatePublicParametersTypeWithName,
          generateMethodReturnType,
          generateMethodParametersTypeWithName,
          generateMethodParametersName,
          generateParentMethodParametersName,
          generateMethodReturnStatements,
          generatePropReturnStatements,
          generateValidRustIdentifier,
          isVoidType,
          isStringType,
          subClasses: _.uniq(subClasses),
          options,
        });
      }
      case TemplateKind.Dictionary: {
        object = object as ClassObject;
        const parentObjects = [] as ClassObject[];

        let node = object;

        while (node && node.parent) {
          const parentObject = ClassObject.globalClassMap[node.parent];
          if (parentObject) {
            parentObjects.push(parentObject);
          }
          node = parentObject;
        }

        return _.template(readSourceTemplate('dictionary'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          parentObjects,
          blob,
          object,
          generatePublicReturnTypeValue,
          isStringType,
          options,
        });
      }
      case TemplateKind.globalFunction: {
        return '';
      }
    }
  });

  return _.template(baseTemplate)({
    content: contents.join('\n'),
    blob: blob
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n') + '\n';
}

export function generateRustSource(blob: IDLBlob) {
  let options = generateSupportedOptions();

  const source = generateRustSourceFile(blob, options);

  return source;
}
