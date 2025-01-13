interface CanvasGradient {
  addColorStop(offset: double, color: string): SupportAsync<DartImpl<void>>;
  new(): void;
}