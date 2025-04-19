import { webf } from "./webf";

export interface StorageInterface {
  readonly length: number;
  getItem(key: string): string | null;
  setItem(key: string, value: string): void;
  removeItem(key: string): void;
  clear(): void;
  key(index: number): string | null;
  getAllKeys(): string[];
}

export class Storage implements StorageInterface {
  public moduleName: string;

  constructor(moduleName: string) {
    this.moduleName = moduleName;
  }
  getItem(key: number | string) {
    return webf.invokeModule(this.moduleName, 'getItem', String(key));
  }
  setItem(key: number | string, value: number | string) {
    return webf.invokeModule(this.moduleName, 'setItem', [String(key), String(value)]);
  }
  removeItem(key: number | string) {
    return webf.invokeModule(this.moduleName, 'removeItem', String(key));
  }
  clear() {
    return webf.invokeModule(this.moduleName, 'clear');
  }
  key(index: number) {
    return webf.invokeModule(this.moduleName, 'key', Number(index));
  }
  getAllKeys() {
    return webf.invokeModule(this.moduleName, '_getAllKeys');
  }
  get length(): number {
    return webf.invokeModule(this.moduleName, 'length');
  }
}

export const storageProxyHandler = {
  get(target: Storage, p: string | symbol, receiver: any): any {
    const result = p in target ? target[p as keyof Storage] : target.getItem(p as string);
    return result === null ? undefined : result;
  },
  set(target: Storage, p: string | symbol, newValue: any, receiver: any): boolean {
    target.setItem(p as string, newValue);
    return true;
  },
  has(target: Storage, p: string | symbol): boolean {
    let v = target.getItem(p as string);
    return v !== null;
  },
  ownKeys(target: Storage): ArrayLike<string | symbol> {
    return target.getAllKeys();
  },
  deleteProperty(target: Storage, p: string | symbol): boolean {
    target.removeItem(p as string);
    let descriptor = Reflect.getOwnPropertyDescriptor(target, p);

    if (descriptor != null) {
      Reflect.defineProperty(target, p, {
        value: null
      });
    }
    return true;
  },
  defineProperty(target: Storage, property: string | symbol, attributes: PropertyDescriptor): boolean {
    target.setItem(property as string, attributes.value);
    return Reflect.defineProperty(target, property, attributes);
  },
  getOwnPropertyDescriptor(target: Storage, p: string | symbol): PropertyDescriptor | undefined {
    let descriptor = Reflect.getOwnPropertyDescriptor(target, p);
    const value = target.getItem(p as string);

    if (value == null) {
      return undefined;
    }

    if (descriptor != null) {
      descriptor.value = value;
      descriptor.enumerable = true;
      descriptor.configurable = true;
      descriptor.writable = true;
    } else {
      descriptor = {
        enumerable: true,
        value: value,
        configurable: true,
        writable: true
      };
    }
    return descriptor;
  }
};