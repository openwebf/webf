/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

export interface TextDecoderOptions {
  fatal?: boolean;
  ignoreBOM?: boolean;
}

export interface TextDecodeOptions {
  stream?: boolean;
}

export class TextDecoder {
  private _encoding: string;
  private _fatal: boolean;
  private _ignoreBOM: boolean;

  constructor(encoding: string = 'utf-8', options: TextDecoderOptions = {}) {
    this._encoding = encoding;
    this._fatal = options.fatal || false;
    this._ignoreBOM = options.ignoreBOM || false;
  }

  get encoding(): string {
    return this._encoding;
  }

  get fatal(): boolean {
    return this._fatal;
  }

  get ignoreBOM(): boolean {
    return this._ignoreBOM;
  }

  decode(input?: BufferSource, _options?: TextDecodeOptions): string {
    if (!input) {
      return '';
    }

    let bytes: number[];
    if (input instanceof ArrayBuffer) {
      bytes = Array.from(new Uint8Array(input));
    } else if (input instanceof Uint8Array) {
      bytes = Array.from(input);
    } else if (input instanceof Int8Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof Uint16Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof Int16Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof Uint32Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof Int32Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof Float32Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof Float64Array) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else if (input instanceof DataView) {
      bytes = Array.from(new Uint8Array(input.buffer, input.byteOffset, input.byteLength));
    } else {
      throw new TypeError('Input must be a BufferSource');
    }

    return webf.invokeModule('TextCodec', 'textDecoder', bytes, this._encoding, this._fatal, this._ignoreBOM);
  }
}

export class TextEncoder {
  get encoding(): string {
    return 'utf-8';
  }

  encode(input: string = ''): Uint8Array {
    const bytes: number[] = webf.invokeModule('TextCodec', 'textEncoder', input);
    return new Uint8Array(bytes);
  }

  encodeInto(source: string, destination: Uint8Array): TextEncoderEncodeIntoResult {
    if (!destination) {
      throw new TypeError('destination must be a Uint8Array');
    }

    const encoded = this.encode(source);
    const written = Math.min(encoded.length, destination.length);

    for (let i = 0; i < written; i++) {
      destination[i] = encoded[i];
    }

    // Calculate how many UTF-16 code units were read
    let read = 0;
    let bytesProcessed = 0;
    for (let i = 0; i < source.length && bytesProcessed < written; i++) {
      const codePoint = source.codePointAt(i);
      if (codePoint === undefined) break;

      // Calculate UTF-8 byte length for this code point
      let utf8Length: number;
      if (codePoint < 0x80) {
        utf8Length = 1;
      } else if (codePoint < 0x800) {
        utf8Length = 2;
      } else if (codePoint < 0x10000) {
        utf8Length = 3;
      } else {
        utf8Length = 4;
      }

      if (bytesProcessed + utf8Length <= written) {
        read += (codePoint > 0xFFFF) ? 2 : 1; // Surrogate pairs count as 2 UTF-16 code units
        bytesProcessed += utf8Length;
      } else {
        break;
      }
    }

    return {
      read,
      written
    };
  }
}

export interface TextEncoderEncodeIntoResult {
  read: number;
  written: number;
}
