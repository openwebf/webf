
const SPECIAL_TOKENS: string[] = [
  'WebCodecs',
  'WebSocket',
  'String16',
  'Float32',
  'Float64',
  'Base64',
  'IFrame',
  'Latin1',
  'MathML',
  'PlugIn',
  'SQLite',
  'Uint16',
  'Uint32',
  'WebGL2',
  'webgl2',
  'WebGPU',
  'ASCII',
  'CSSOM',
  'CType',
  'DList',
  'Int16',
  'Int32',
  'MPath',
  'OList',
  'TSpan',
  'UList',
  'UTF16',
  'Uint8',
  'WebGL',
  'XPath',
  'ETC1',
  'etc1',
  'HTML',
  'Int8',
  'S3TC',
  's3tc',
  'SPv2',
  'UTF8',
  'sRGB',
  'URLs',
  'API',
  'CSS',
  'DNS',
  'DOM',
  'EXT',
  'RTC',
  'SVG',
  'XSS',
  '2D',
  'AX',
  'FE',
  'JS',
  'V0',
  'V8',
  'v8',
  'XR',
];

const _SPECIAL_TOKENS_WITH_NUMBERS: string[] = SPECIAL_TOKENS.filter(token =>
  /[0-9]/.test(token)
);

const _TOKEN_PATTERNS: string[] = [
  '[A-Z]?[a-z]+',
  '[A-Z]+(?![a-z])',
  '[0-9][Dd](?![a-z])',
  '[0-9]+',
];

const _TOKEN_RE: RegExp = new RegExp('(' + [...SPECIAL_TOKENS, ..._TOKEN_PATTERNS].join('|') + ')', 'g');

function tokenizeName(name: string): string[] {
  let tokens: string[] = [];
  const match = new RegExp('^(' + _SPECIAL_TOKENS_WITH_NUMBERS.join('|') + ')', 'i').exec(name);
  if (match) {
    tokens.push(match[0]);
    name = name.slice(match[0].length);
  }
  return tokens.concat(name.match(_TOKEN_RE) || []);
}

export class NameStyleConverter {
  private tokens: string[];
  private _original: string;

  constructor(name: string) {
    this.tokens = tokenizeName(name);
    this._original = name;
  }

  get original(): string {
    return this._original;
  }

  toSnakeCase(): string {
    return this.tokens.map(token => token.toLowerCase()).join('_');
  }

  toUpperCamelCase(): string {
    let tokens = this.tokens;
    if (tokens.length && tokens[0].toLowerCase() === tokens[0]) {
      for (const special of SPECIAL_TOKENS) {
        if (special.toLowerCase() === tokens[0]) {
          tokens = [...tokens];
          tokens[0] = special;
          break;
        }
      }
    }
    return tokens.map(token => token[0].toUpperCase() + token.slice(1)).join('');
  }

  toLowerCamelCase(): string {
    if (!this.tokens.length) return '';
    return this.tokens[0].toLowerCase() + this.tokens.slice(1).map(token => token[0].toUpperCase() + token.slice(1)).join('');
  }

  toMacroCase(): string {
    return this.tokens.map(token => token.toUpperCase()).join('_');
  }

  toAllCases(): Record<string, string> {
    return {
      'snake_case': this.toSnakeCase(),
      'upper_camel_case': this.toUpperCamelCase(),
      'macro_case': this.toMacroCase(),
    };
  }

  toClassName(prefix?: string, suffix?: string): string {
    const camelPrefix = prefix ? prefix[0].toUpperCase() + prefix.slice(1).toLowerCase() : '';
    const camelSuffix = suffix ? suffix[0].toUpperCase() + suffix.slice(1).toLowerCase() : '';
    return camelPrefix + this.toUpperCamelCase() + camelSuffix;
  }

  toClassDataMember(prefix?: string, suffix?: string): string {
    const lowerPrefix = prefix ? prefix.toLowerCase() + '_' : '';
    const lowerSuffix = suffix ? suffix.toLowerCase() + '_' : '';
    return lowerPrefix + this.toSnakeCase() + '_' + lowerSuffix;
  }

  toFunctionName(prefix?: string, suffix?: string | string[]): string {
    const camelPrefix = prefix ? prefix[0].toUpperCase() + prefix.slice(1).toLowerCase() : '';
    let camelSuffix = '';
    if (Array.isArray(suffix)) {
      camelSuffix = suffix.map(item => item[0].toUpperCase() + item.slice(1).toLowerCase()).join('');
    } else if (suffix) {
      camelSuffix = suffix[0].toUpperCase() + suffix.slice(1).toLowerCase();
    }
    return camelPrefix + this.toUpperCamelCase() + camelSuffix;
  }

  toEnumValue(): string {
    return 'k' + this.toUpperCamelCase();
  }

  toHeaderGuard(): string {
    return this.toMacroCase().replace(/[-/.]/g, '_') + '_';
  }
}