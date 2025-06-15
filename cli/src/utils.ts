import { ParameterType } from './analyzer';
import { FunctionArgumentType } from './declaration';
import {IDLBlob} from './IDLBlob';
import {camelCase, snakeCase} from 'lodash';

export function addIndent(str: string, space: number) {
  if (!str) return str;
  let lines = str.split('\n');
  lines = lines.map(l => {
    for (let i = 0; i < space; i ++) {
      l = ' ' + l;
    }
    return l;
  });
  return lines.join('\n');
}

export function getClassName(blob: IDLBlob) {
  let raw = camelCase(blob.filename);
  if (raw.slice(0, 3) == 'dom') {
    if (raw === 'domMatrixReadonly') {
      return `DOMMatrixReadOnly`;
    } else if (raw === 'domPointReadonly') {
      return `DOMPointReadOnly`;
    }
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

  if (raw == 'webfTouchAreaElement') {
    return 'WebFTouchAreaElement';
  }
  if (raw == 'webfRouterLinkElement') {
    return 'WebFRouterLinkElement';
  }

  return `${raw[0].toUpperCase() + raw.slice(1)}`;
}

export function getWrapperTypeInfoNameOfClassName(className: string) {
  if (className.slice(0, 6) === 'SVGSVG') {
    // special for SVGSVGElement
    className = `SVGSvg${className.slice(6)}`
  } else if (className === 'SVGGElement') {
    // TODO: use more better way
    className = `SVG_G_Element`
  }

  return snakeCase(className).toUpperCase()
}

export function getMethodName(name: string) {
  if (!name || name.length === 0) return '';
  return name[0].toUpperCase() + name.slice(1);
}

export function trimNullTypeFromType(type: ParameterType): ParameterType {
  let types = type.value;
  if (!Array.isArray(types)) return type;
  let trimed = types.filter(t => t.value != FunctionArgumentType.null);

  if (trimed.length === 1) {
    return {
      isArray: false,
      value: trimed[0].value
    }
  }

  return {
    isArray: type.isArray,
    value: trimed
  };
}

export function isUnionType(type: ParameterType): boolean {
  if (type.isArray || !Array.isArray(type.value)) {
    return false;
  }

  const trimedType = trimNullTypeFromType(type);
  return Array.isArray(trimedType.value);
}

export function isPointerType(type: ParameterType): boolean {
  if (type.isArray) return false;
  if (typeof type.value === 'string') {
    return true;
  }
  if (Array.isArray(type.value)) {
    return type.value.some(t => typeof t.value === 'string');
  }
  return false;
}

export function getPointerType(type: ParameterType): string {
  if (typeof type.value === 'string') {
    return type.value;
  }
  if (Array.isArray(type.value)) {
    for (let i = 0; i < type.value.length; i++) {
      let childValue = type.value[i];
      if (typeof childValue.value === 'string') {
        return childValue.value;
      }
    }
  }
  return '';
}
