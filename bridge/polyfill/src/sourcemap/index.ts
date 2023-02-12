import { BasicSourceMapConsumer, IndexedSourceMapConsumer, SourceMapConsumer} from 'source-map';

class SourceMapTranslator {
  public consumer: BasicSourceMapConsumer | IndexedSourceMapConsumer

  constructor(rawSourceMap: any, remoteUrl: string) {
    SourceMapConsumer.with(rawSourceMap, remoteUrl, consumer => {
      this.consumer = consumer;
    });
  }
}

Object.defineProperty(globalThis, 'SourceMapTranslator', {
  value: SourceMapTranslator,
  enumerable: true,
  writable: true,
  configurable: true
});