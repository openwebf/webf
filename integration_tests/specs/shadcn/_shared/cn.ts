export type ClassValue = string | false | null | undefined;

export function cn(...inputs: ClassValue[]): string {
  return inputs.filter(Boolean).join(' ');
}
