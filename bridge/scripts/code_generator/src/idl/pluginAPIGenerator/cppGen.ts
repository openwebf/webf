import fs from 'fs';
import path from 'path';
import { IDLBlob } from '../IDLBlob';
import { getTemplateKind, TemplateKind } from '../generateHeader';
import _ from 'lodash';
import { ClassObject, FunctionArguments, FunctionArgumentType, PropsDeclaration } from '../declaration';
import { GenerateOptions, generateSupportedOptions } from '../generator';
import { ParameterType } from '../analyzer';
import { getPointerType, isPointerType } from '../generateSource';

function readHeaderTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../../templates/idl_templates/plugin_api_templates/' + name + '.h.tpl'), {encoding: 'utf-8'});
}

function readSourceTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../../templates/idl_templates/plugin_api_templates/' + name + '.cc.tpl'), {encoding: 'utf-8'});
}

function getClassName(blob: IDLBlob) {
  let raw = _.camelCase(blob.filename[11].toUpperCase() + blob.filename.slice(12));
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

export function isStringType(type: ParameterType): boolean {
  return type.value === FunctionArgumentType.dom_string
    || type.value === FunctionArgumentType.legacy_dom_string;
}

function generatePublicReturnTypeValue(type: ParameterType, is32Bit: boolean = false): string {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `WebFValue<${pointerType}, ${pointerType}PublicMethods>`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int64_t';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      if (is32Bit) {
        return 'const char*';
      }

      return 'SharedNativeString*';
    }
    case FunctionArgumentType.void:
      return 'void';
    default:
      if (is32Bit) {
        return 'int64_t';
      }
      return 'void*';
  }
}

function generatePublicParameterType(type: ParameterType, is32Bit: boolean = false): string {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `${pointerType}*`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int64_t';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      if (is32Bit) {
        return 'const char*';
      }

      return 'SharedNativeString*';
    }
    default:
      if (is32Bit) {
        return 'int64_t';
      }
      return 'void*';
  }
}

function generatePublicParametersType(parameters: FunctionArguments[], is32Bit: boolean = false): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generatePublicParameterType(param.type, is32Bit)}`;
  }).join(', ') + ', ';
}

function generatePublicParametersTypeWithName(parameters: FunctionArguments[], is32Bit: boolean = false): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generatePublicParameterType(param.type, is32Bit)} ${_.snakeCase(param.name)}`;
  }).join(', ') + ', ';
}

function generatePublicParametersName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    const name = _.snakeCase(param.name);
    return `${isStringType(param.type) ? name + '_atomic' : name}`;
  }).join(', ') + ', ';
}

function generatePluginAPIHeaderFile(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = readHeaderTemplate('base');
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

        return _.template(readHeaderTemplate('interface'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          blob: blob,
          object,
          generatePublicReturnTypeValue,
          generatePublicParametersType,
          generatePublicParametersTypeWithName,
          isStringType,
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

function generatePluginAPISourceFile(blob: IDLBlob, options: GenerateOptions) {
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
          generatePublicReturnTypeValue,
          generatePublicParametersType,
          generatePublicParametersTypeWithName,
          generatePublicParametersName,
          generatePublicParameterType,
          isPointerType,
          getPointerType,
          isStringType,
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

export function generatePluginAPI(blob: IDLBlob) {
  let options = generateSupportedOptions();

  const header = generatePluginAPIHeaderFile(blob, options);
  const source = generatePluginAPISourceFile(blob, options);

  return {
    header,
    source
  };
}
