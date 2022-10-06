export interface ElementAttributes {
  // Legacy methods: these methods are not W3C standard.
  getAttribute(name: string): string;
  setAttribute(name: string, value: string): void;
  hasAttribute(name: string): boolean;
  removeAttribute(name: string): void;
  new(): void;
}
