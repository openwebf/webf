/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
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

export function getClassName(blob: IDLBlob) {
  let raw = camelCase(blob.filename[4].toUpperCase() + blob.filename.slice(5));
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
    // Handle HTML elements with uppercase abbreviations
    if (raw === 'htmlLiElement') {
      return `HTMLLIElement`;
    }
    if (raw === 'htmlUlistElement') {
      return `HTMLUListElement`;
    }
    if (raw === 'htmlOlistElement') {
      return `HTMLOListElement`;
    }
    if (raw === 'htmlHrElement') {
      return `HTMLHRElement`;
    }
    if (raw === 'htmlDlElement') {
      return `HTMLDLElement`;
    }
    if (raw === 'htmlDtElement') {
      return `HTMLDTElement`;
    }
    if (raw === 'htmlDdElement') {
      return `HTMLDDElement`;
    }
    if (raw === 'htmlFigcaptionElement') {
      return `HTMLFigCaptionElement`;
    }
    if (raw === 'htmlNoscriptElement') {
      return `HTMLNoScriptElement`;
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

  // Handle HTML elements with uppercase abbreviations
  if (className === 'HTMLLIElement') {
    return 'HTML_LI_ELEMENT';
  }
  if (className === 'HTMLUListElement') {
    return 'HTML_U_LIST_ELEMENT';
  }
  if (className === 'HTMLOListElement') {
    return 'HTML_O_LIST_ELEMENT';
  }
  if (className === 'HTMLHRElement') {
    return 'HTML_HR_ELEMENT';
  }
  if (className === 'HTMLDLElement') {
    return 'HTML_DL_ELEMENT';
  }
  if (className === 'HTMLDTElement') {
    return 'HTML_DT_ELEMENT';
  }
  if (className === 'HTMLDDElement') {
    return 'HTML_DD_ELEMENT';
  }
  if (className === 'HTMLFigCaptionElement') {
    return 'HTML_FIG_CAPTION_ELEMENT';
  }
  if (className === 'HTMLNoScriptElement') {
    return 'HTML_NO_SCRIPT_ELEMENT';
  }

  return snakeCase(className).toUpperCase()
}

export function getMethodName(name: string) {
  return name[0].toUpperCase() + name.slice(1);
}
