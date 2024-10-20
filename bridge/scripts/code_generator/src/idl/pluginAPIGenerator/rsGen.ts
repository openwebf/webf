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
      return 'f64';
    }
    case FunctionArgumentType.any: {
      return 'RustValue<ScriptValueRefRustMethods>';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
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
      return 'ScriptValueRef';
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
      return 'f64';
    }
    case FunctionArgumentType.any: {
      return '*const OpaquePtr';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
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
      return '&ScriptValueRef';
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
    if (isStringType(param.type)) {
      return `CString::new(${generateValidRustIdentifier(param.name)}).unwrap().as_ptr()`;
    } else if (isAnyType(param.type)) {
      return `${param.name}.ptr`;
    } else {
      return param.name;
    }
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
  return rustKeywords.includes(name) ? `${name}_` : name;
}

function generateRustSourceFile(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = readSourceTemplate('base');
  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null) return '';

    switch(templateKind) {
      case TemplateKind.Interface: {
        object = object as ClassObject;

        let dependentTypes = new Set<string>();

        object.props.forEach(prop => {
          if (isPointerType(prop.type)) {
            dependentTypes.add(getPointerType(prop.type));
          }
        });

        object.methods.forEach(method => {
          method.args.forEach(param => {
            if (isPointerType(param.type)) {
              dependentTypes.add(getPointerType(param.type));
            }
          });
          if (isPointerType(method.returnType)) {
            dependentTypes.add(getPointerType(method.returnType));
          }
        });

        return _.template(readSourceTemplate('interface'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          blob: blob,
          object,
          isPointerType,
          generatePublicReturnTypeValue,
          generatePublicParametersType,
          generatePublicParametersTypeWithName,
          generatePublicParametersName,
          generateMethodReturnType,
          generateMethodParametersType,
          generateMethodParametersTypeWithName,
          generateMethodParametersName,
          generateValidRustIdentifier,
          isStringType,
          isAnyType,
          isVoidType,
          dependentTypes: Array.from(dependentTypes),
          options,
        });
      }
      case TemplateKind.Dictionary: {
        return '';
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
  }).join('\n');
}

export function generateRustSource(blob: IDLBlob) {
  let options = generateSupportedOptions();

  const source = generateRustSourceFile(blob, options);

  return source;
}