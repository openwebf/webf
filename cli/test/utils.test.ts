import {
  addIndent,
  getClassName,
  getWrapperTypeInfoNameOfClassName,
  getMethodName,
  trimNullTypeFromType,
  isUnionType,
  isPointerType,
  getPointerType
} from '../src/utils';
import { FunctionArgumentType } from '../src/declaration';
import { IDLBlob } from '../src/IDLBlob';

describe('Utils', () => {
  describe('addIndent', () => {
    it('should add specified spaces to each line', () => {
      const input = 'line1\nline2\nline3';
      const result = addIndent(input, 2);
      expect(result).toBe('  line1\n  line2\n  line3');
    });

    it('should handle empty string', () => {
      const result = addIndent('', 4);
      expect(result).toBe('');
    });

    it('should handle single line', () => {
      const result = addIndent('hello', 3);
      expect(result).toBe('   hello');
    });

    it('should handle zero indent', () => {
      const input = 'line1\nline2';
      const result = addIndent(input, 0);
      expect(result).toBe('line1\nline2');
    });
  });

  describe('getClassName', () => {
    it('should handle DOM prefixed names', () => {
      const blob = new IDLBlob('', '', 'domElement', '');
      expect(getClassName(blob)).toBe('DOMElement');
    });

    it('should handle DOMMatrixReadonly special case', () => {
      const blob = new IDLBlob('', '', 'domMatrixReadonly', '');
      expect(getClassName(blob)).toBe('DOMMatrixReadOnly');
    });

    it('should handle DOMPointReadonly special case', () => {
      const blob = new IDLBlob('', '', 'domPointReadonly', '');
      expect(getClassName(blob)).toBe('DOMPointReadOnly');
    });

    it('should handle HTML prefixed names', () => {
      const blob = new IDLBlob('', '', 'htmlDivElement', '');
      expect(getClassName(blob)).toBe('HTMLDivElement');
    });

    it('should handle HTMLIFrameElement special case', () => {
      const blob = new IDLBlob('', '', 'htmlIframeElement', '');
      expect(getClassName(blob)).toBe('HTMLIFrameElement');
    });

    it('should handle SVG prefixed names', () => {
      const blob = new IDLBlob('', '', 'svgCircleElement', '');
      expect(getClassName(blob)).toBe('SVGCircleElement');
    });

    it('should handle SVGSVGElement special case', () => {
      const blob = new IDLBlob('', '', 'svgSvgElement', '');
      expect(getClassName(blob)).toBe('SVGSVGElement');
    });

    it('should handle CSS prefixed names', () => {
      const blob = new IDLBlob('', '', 'cssStyleDeclaration', '');
      expect(getClassName(blob)).toBe('CSSStyleDeclaration');
    });

    it('should handle UI prefixed names', () => {
      const blob = new IDLBlob('', '', 'uiEvent', '');
      expect(getClassName(blob)).toBe('UIEvent');
    });

    it('should handle WebF special cases', () => {
      const blob1 = new IDLBlob('', '', 'webfTouchAreaElement', '');
      expect(getClassName(blob1)).toBe('WebFTouchAreaElement');

      const blob2 = new IDLBlob('', '', 'webfRouterLinkElement', '');
      expect(getClassName(blob2)).toBe('WebFRouterLinkElement');
    });

    it('should handle regular names', () => {
      const blob = new IDLBlob('', '', 'customElement', '');
      expect(getClassName(blob)).toBe('CustomElement');
    });
  });

  describe('getWrapperTypeInfoNameOfClassName', () => {
    it('should convert SVGSVGElement correctly', () => {
      const result = getWrapperTypeInfoNameOfClassName('SVGSVGElement');
      expect(result).toBe('SVG_SVG_ELEMENT');
    });

    it('should convert SVGGElement correctly', () => {
      const result = getWrapperTypeInfoNameOfClassName('SVGGElement');
      expect(result).toBe('SVG_G_ELEMENT');
    });

    it('should convert regular class names to snake case', () => {
      expect(getWrapperTypeInfoNameOfClassName('HTMLDivElement')).toBe('HTML_DIV_ELEMENT');
      expect(getWrapperTypeInfoNameOfClassName('CustomElement')).toBe('CUSTOM_ELEMENT');
    });
  });

  describe('getMethodName', () => {
    it('should capitalize first letter', () => {
      expect(getMethodName('method')).toBe('Method');
      expect(getMethodName('getValue')).toBe('GetValue');
    });

    it('should handle single character', () => {
      expect(getMethodName('a')).toBe('A');
    });

    it('should handle empty string', () => {
      expect(getMethodName('')).toBe('');
    });
  });

  describe('trimNullTypeFromType', () => {
    it('should remove null from union types', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: FunctionArgumentType.dom_string },
          { isArray: false, value: FunctionArgumentType.null },
          { isArray: false, value: FunctionArgumentType.double }
        ]
      };

      const result = trimNullTypeFromType(type);
      expect(result.value).toHaveLength(2);
      expect(result.value).not.toContainEqual(
        expect.objectContaining({ value: FunctionArgumentType.null })
      );
    });

    it('should return single type if only one remains after trimming', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: FunctionArgumentType.dom_string },
          { isArray: false, value: FunctionArgumentType.null }
        ]
      };

      const result = trimNullTypeFromType(type);
      expect(result).toEqual({
        isArray: false,
        value: FunctionArgumentType.dom_string
      });
    });

    it('should return type unchanged if not an array', () => {
      const type = {
        isArray: false,
        value: FunctionArgumentType.dom_string
      };

      const result = trimNullTypeFromType(type);
      expect(result).toBe(type);
    });

    it('should handle array types', () => {
      const type = {
        isArray: true,
        value: { isArray: false, value: FunctionArgumentType.dom_string }
      };

      const result = trimNullTypeFromType(type);
      expect(result).toBe(type);
    });
  });

  describe('isUnionType', () => {
    it('should return true for union types', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: FunctionArgumentType.dom_string },
          { isArray: false, value: FunctionArgumentType.double }
        ]
      };

      expect(isUnionType(type)).toBe(true);
    });

    it('should return false for array types', () => {
      const type = {
        isArray: true,
        value: { isArray: false, value: FunctionArgumentType.dom_string }
      };

      expect(isUnionType(type)).toBe(false);
    });

    it('should return false for single types', () => {
      const type = {
        isArray: false,
        value: FunctionArgumentType.dom_string
      };

      expect(isUnionType(type)).toBe(false);
    });

    it('should check trimmed type for unions', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: FunctionArgumentType.dom_string },
          { isArray: false, value: FunctionArgumentType.null }
        ]
      };

      // After trimming null, only one type remains, so not a union
      expect(isUnionType(type)).toBe(false);
    });
  });

  describe('isPointerType', () => {
    it('should return true for string value types', () => {
      const type = {
        isArray: false,
        value: 'CustomClass'
      };

      expect(isPointerType(type)).toBe(true);
    });

    it('should return false for array types', () => {
      const type = {
        isArray: true,
        value: 'CustomClass'
      };

      expect(isPointerType(type)).toBe(false);
    });

    it('should return false for function argument types', () => {
      const type = {
        isArray: false,
        value: FunctionArgumentType.dom_string
      };

      expect(isPointerType(type)).toBe(false);
    });

    it('should return true if union contains string type', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: FunctionArgumentType.dom_string },
          { isArray: false, value: 'CustomClass' }
        ]
      };

      expect(isPointerType(type)).toBe(true);
    });
  });

  describe('getPointerType', () => {
    it('should return string value directly', () => {
      const type = {
        isArray: false,
        value: 'CustomClass'
      };

      expect(getPointerType(type)).toBe('CustomClass');
    });

    it('should find string value in union type', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: FunctionArgumentType.dom_string },
          { isArray: false, value: 'CustomClass' },
          { isArray: false, value: FunctionArgumentType.double }
        ]
      };

      expect(getPointerType(type)).toBe('CustomClass');
    });

    it('should return empty string if no string type found', () => {
      const type = {
        isArray: false,
        value: FunctionArgumentType.dom_string
      };

      expect(getPointerType(type)).toBe('');
    });

    it('should return first string type in union', () => {
      const type = {
        isArray: false,
        value: [
          { isArray: false, value: 'FirstClass' },
          { isArray: false, value: 'SecondClass' }
        ]
      };

      expect(getPointerType(type)).toBe('FirstClass');
    });
  });
});