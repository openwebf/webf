import {IDLBlob} from './IDLBlob';
import {camelCase, snakeCase} from 'lodash';

export function addIndent(str: String, space: number) {
  let lines = str.split('\n');
  lines = lines.map(l => {
    for (let i = 0; i < space; i ++) {
      l = ' ' + l;
    }
    return l;
  });
  return lines.join('\n');
}

function getUniversalPlatformFilename(blob: IDLBlob) {
  const prefix = blob.platformPrefix + '_';
  if (blob.filename.startsWith(prefix)) {
      return blob.filename.substring(prefix.length);
  }
  return blob.filename;
}

export function getClassName(blob: IDLBlob) {
  let raw = camelCase(getUniversalPlatformFilename(blob));
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
  return name[0].toUpperCase() + name.slice(1);
}
