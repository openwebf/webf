const { SourceMapConsumer } = require('source-map');

class SourceBackwardsIterator {
  constructor(source) {
    this._source = source;
    this._index = source.length - 1;
  }

  index() {
    return this._index;
  }

  char() {
    return this._source[this._index];
  }

  isEnd() {
    return this._index >= 0;
  }

  next() {
    this._index--;
  }
}

function findScriptSourceMapUrl(source) {
  const iterator = new SourceBackwardsIterator(source);

  let start = iterator.index();
  while(iterator.isEnd()) {
    if (iterator.char() === '\n') {
      const line = source.substring(iterator.index(), start);
      const regex = /[#@]\s*sourceMappingURL=(.*)\s*/m;
      const match = regex.exec(line);
      if (match) {
        return match[1];
      }
      start = iterator.index() + 1;
    }

    iterator.next();
  }
  return null;
}

function findScriptSourceURL(source) {
  const iterator = new SourceBackwardsIterator(source);

  let start = iterator.index();
  while(iterator.isEnd()) {
    if (iterator.char() === '\n') {
      const line = source.substring(iterator.index(), start);
      const regex = /[#@]\s*sourceURL=(.*)\s*$/m;
      const match = regex.exec(line);
      if (match) {
        return match[1];
      }
      start = iterator.index() + 1;
    }

    iterator.next();
  }
  return null;
}

function defineGlobalProperty(key, value, isEnumerable = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: true,
    configurable: true
  });
}

function consumeSourceMap(rawSourceMap) {
  return new SourceMapConsumer(rawSourceMap);
}

function parseInlineSourceMap(raw) {
  let rawSourceMap = findScriptSourceMapUrl(raw);
  if (!rawSourceMap) return null;
  let base64Index = rawSourceMap.indexOf('base64');
  let chunkIndex = base64Index + ('base64'.length) + 1;
  let encoded = rawSourceMap.substring(chunkIndex);
  let json = atob(encoded);
  return JSON.parse(json);
}

defineGlobalProperty('findScriptSourceMapUrl', findScriptSourceMapUrl);
defineGlobalProperty('findScriptSourceURL', findScriptSourceURL);
defineGlobalProperty('parseInlineSourceMap', parseInlineSourceMap);
defineGlobalProperty('consumeSourceMap', consumeSourceMap);