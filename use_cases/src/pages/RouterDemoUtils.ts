export function joinBase(basePath: string, path: string) {
  if (!basePath) return path;
  const base = basePath.endsWith('/') ? basePath.slice(0, -1) : basePath;
  const suffix = path.startsWith('/') ? path : `/${path}`;
  return `${base}${suffix}`.replace(/\/{2,}/g, '/');
}

export function inferSegmentAfter(pathname: string, segment: string): string | undefined {
  const parts = pathname.split('/').filter(Boolean);
  const index = parts.lastIndexOf(segment);
  if (index === -1) return undefined;
  return parts[index + 1];
}

export function safeJson(value: unknown): string {
  if (value === undefined) return 'undefined';
  try {
    return JSON.stringify(value, null, 2);
  } catch {
    return String(value);
  }
}

