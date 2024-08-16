interface SyncIterator {
  new(): void;
  next(): any;
  readonly done: boolean;
  readonly value: any;
  readonly [Symbol.iterator]: SyncIterator;
}