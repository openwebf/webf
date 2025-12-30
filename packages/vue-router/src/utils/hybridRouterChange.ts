export type HybridRouterChangeKind = 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext';

export interface HybridRouterChangeInfo {
  kind?: HybridRouterChangeKind;
  path?: string;
  currentActivePath?: string;
  routerPath?: string;
  stackTopPath?: string;
}

export interface DerivedActivePathResult {
  activePath: string | undefined;
  reason: string;
}

function normalizePath(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

/**
 * Derive the next "active" path from a `hybridrouterchange` event.
 *
 * In WebF, on back/pop, the runtime can emit two events:
 * - `didPopNext`: the route that became visible (the next active route)
 * - `didPop`: the route that was popped (the leaving route)
 *
 * The WebF runtime's `hybridHistory.path` / `buildContextStack` may lag behind the event momentarily.
 * This helper trusts the event payload for "active" kinds and prevents `didPop` from overriding.
 */
export function __unstable_deriveActivePathFromHybridRouterChange(info: HybridRouterChangeInfo): DerivedActivePathResult {
  const kind = info.kind;
  const eventPath = normalizePath(info.path);
  const currentActivePath = normalizePath(info.currentActivePath);
  const routerPath = normalizePath(info.routerPath);
  const stackTopPath = normalizePath(info.stackTopPath);

  if (kind === 'didPush' || kind === 'didPushNext' || kind === 'didPopNext') {
    if (eventPath) return { activePath: eventPath, reason: `${kind}:eventPath` };
    if (stackTopPath) return { activePath: stackTopPath, reason: `${kind}:stackTopPath` };
    if (routerPath) return { activePath: routerPath, reason: `${kind}:routerPath` };
    return { activePath: currentActivePath, reason: `${kind}:currentActivePath` };
  }

  if (kind === 'didPop') {
    if (currentActivePath && currentActivePath !== eventPath) {
      return { activePath: currentActivePath, reason: 'didPop:keepCurrentActivePath' };
    }
    if (stackTopPath && stackTopPath !== eventPath) return { activePath: stackTopPath, reason: 'didPop:stackTopPath' };
    if (routerPath && routerPath !== eventPath) return { activePath: routerPath, reason: 'didPop:routerPath' };
    return { activePath: currentActivePath ?? stackTopPath ?? routerPath ?? eventPath, reason: 'didPop:fallback' };
  }

  if (eventPath) return { activePath: eventPath, reason: 'unknownKind:eventPath' };
  if (stackTopPath) return { activePath: stackTopPath, reason: 'unknownKind:stackTopPath' };
  return { activePath: routerPath ?? currentActivePath, reason: 'unknownKind:fallback' };
}

