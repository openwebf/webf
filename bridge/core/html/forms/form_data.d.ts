export interface FormData {
  new(): FormData;
  append(name: string, value: (string | Blob), fileName?: string): void;
  delete(name: string): ImplementedAs<void, "deleteEntry">;
  get(name: string): (string | Blob);
  getAll(name: string): (string | Blob)[];
  has(name: string): boolean;
  set(name: string, value: string | Blob, fileName?: string): void;
}