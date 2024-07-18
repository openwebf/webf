export interface MediaList {
  mediaText: string;
  length: number;
  [s: number]: string | null;
  appendMedium(medium: string): void;
  deleteMedium(medium: string): void;
  new(): void;
}