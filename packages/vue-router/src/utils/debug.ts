const DEBUG_FLAG = '__WEBF_VUE_ROUTER_DEBUG__';

function isDebugEnabled(): boolean {
  return Boolean((globalThis as any)?.[DEBUG_FLAG]);
}

function safeJson(value: unknown): unknown {
  try {
    return JSON.parse(JSON.stringify(value));
  } catch {
    return String(value);
  }
}

export function debugLog(event: string, payload?: unknown) {
  if (!isDebugEnabled()) return;
  const time = new Date().toISOString();
  const entry = payload === undefined ? undefined : safeJson(payload);
  // eslint-disable-next-line no-console
  console.log(`[vue-router][${time}] ${event}`, entry ?? '');
}

export function debugFlagName() {
  return DEBUG_FLAG;
}

