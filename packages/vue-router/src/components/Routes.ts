import {
  Fragment,
  VNode,
  computed,
  defineComponent,
  h,
  inject,
  isVNode,
  onMounted,
  onUnmounted,
  onUpdated,
  provide,
  reactive,
  ref,
  watchPostEffect,
} from 'vue';
import { HybridRouteStackEntry, WebFRouter, __unstable_setEnsureRouteMountedCallback } from '../router/WebFRouter';
import { matchPath } from '../utils/pathMatcher';
import type { RouteMatch, RouteParams } from '../utils/pathMatcher';
import type { HybridRouterChangeEvent } from '../utils/RouterLink';
import { __unstable_deriveActivePathFromHybridRouterChange, HybridRouterChangeKind } from '../utils/hybridRouterChange';
import { Route } from './Route';
import type { RouteContext } from '../types';
import { debugLog, debugFlagName } from '../utils/debug';

/**
 * Routes component - provides routing context to child Route components
 *
 * This component listens for hybrid router change events and provides route context
 * to all child Route components. It also supports dynamic route mounting based on
 * `webf.hybridHistory.buildContextStack` and an ensure-mount callback used by `WebFRouter`.
 */
function patternScore(pattern: string): number {
  if (pattern === '*') return 0;
  const segments = pattern.split('/').filter(Boolean);
  let score = 0;
  for (const segment of segments) {
    if (segment === '*') score += 1;
    else if (segment.startsWith(':')) score += 2;
    else score += 3;
  }
  return score * 100 + segments.length;
}

function findBestMatch(patterns: string[], pathname: string): RouteMatch | null {
  let best: { match: RouteMatch; score: number } | null = null;
  for (const pattern of patterns) {
    const match = matchPath(pattern, pathname);
    if (!match) continue;
    const score = patternScore(pattern);
    if (!best || score > best.score) best = { match, score };
  }
  return best?.match ?? null;
}

function escapeAttributeValue(value: string): string {
  return value.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function flattenRouteSlotVNodes(nodes: unknown): VNode[] {
  const flat: VNode[] = [];
  const visit = (node: unknown) => {
    if (Array.isArray(node)) {
      for (const child of node) visit(child);
      return;
    }
    if (node == null) return;
    if (!isVNode(node)) return;

    if (node.type === Fragment) {
      const children = (node as any).children;
      if (Array.isArray(children)) {
        for (const child of children) visit(child);
      }
      return;
    }

    flat.push(node);
  };

  visit(nodes);
  return flat;
}

function isRouteVNode(node: VNode): boolean {
  if (node.type === Route) return true;

  const props = node.props as any;
  return typeof props?.path === 'string' && props.path.startsWith('/') && 'element' in props;
}

const RouteContextProvider = defineComponent({
  name: 'RouteContextProvider',
  props: {
    patternPath: {
      type: String,
      required: true,
    },
    mountedPath: {
      type: String,
      required: true,
    },
  },
  setup(props, { slots }) {
    const globalContext = inject<RouteContext>('route-context');

    const routeSpecificContext = computed<RouteContext>(() => {
      const activePath = globalContext?.activePath;
      const activeMountedPath = globalContext?.mountedPath;
      const bestMatchedPatternPath = globalContext?.path;

      const isPatternMounted = props.mountedPath === props.patternPath;

      const shouldUseActivePathForPatternMount =
        isPatternMounted && activePath !== undefined && bestMatchedPatternPath === props.patternPath;

      const shouldFallbackToActiveMountedPath =
        !shouldUseActivePathForPatternMount &&
        activePath !== undefined &&
        activeMountedPath !== undefined &&
        isPatternMounted &&
        bestMatchedPatternPath === props.patternPath &&
        (typeof document === 'undefined' ||
          typeof document.querySelector !== 'function' ||
          !document.querySelector(`webf-router-link[path="${escapeAttributeValue(activeMountedPath)}"]`));

      const mountedPathForMatch = shouldUseActivePathForPatternMount
        ? activePath!
        : shouldFallbackToActiveMountedPath
          ? activeMountedPath!
          : props.mountedPath;

      const isActive = activePath !== undefined && activePath === mountedPathForMatch;
      const match = isActive ? matchPath(props.patternPath, mountedPathForMatch) : null;

      if (isActive && match) {
        const effectiveParams = globalContext?.params !== undefined ? globalContext.params : WebFRouter.state;

        debugLog('route-context:active', {
          patternPath: props.patternPath,
          providerMountedPath: props.mountedPath,
          mountedPathForMatch,
          activePath,
          matchStrategy: shouldUseActivePathForPatternMount
            ? 'pattern-mount:activePath'
            : shouldFallbackToActiveMountedPath
              ? 'pattern-mount:mountedPath-fallback'
              : 'mountedPath',
          matchParams: match.params,
          bestMatchedPatternPath,
        });

        return {
          path: props.patternPath,
          mountedPath: mountedPathForMatch,
          params: effectiveParams,
          routeParams: match.params,
          activePath,
          routeEventKind: globalContext?.routeEventKind,
        };
      }

      debugLog('route-context:inactive', {
        patternPath: props.patternPath,
        providerMountedPath: props.mountedPath,
        activePath,
        activeMountedPath,
        bestMatchedPatternPath,
        matchStrategy: shouldUseActivePathForPatternMount
          ? 'pattern-mount:activePath'
          : shouldFallbackToActiveMountedPath
            ? 'pattern-mount:mountedPath-fallback'
            : 'mountedPath',
      });

      return {
        path: props.patternPath,
        mountedPath: props.mountedPath,
        params: undefined,
        routeParams: undefined,
        activePath,
        routeEventKind: undefined,
      };
    });

    provide('route-specific-context', routeSpecificContext);

    return () => slots.default?.();
  },
});

export const Routes = defineComponent({
  name: 'Routes',
  setup(_, { slots }) {
    const routeContext = reactive<RouteContext>({
      path: undefined,
      mountedPath: undefined,
      activePath: WebFRouter.path,
      params: undefined,
      routeParams: undefined,
      routeEventKind: undefined,
    });

    // Provide route context to child components
    provide('route-context', routeContext);

    const stack = ref<HybridRouteStackEntry[]>(WebFRouter.stack);
    const preMountedPaths = ref<string[]>([]);
    const routePatternsRef = ref<string[]>([]);
    const pendingEnsureResolvers = new Map<string, Array<() => void>>();
    let hybridChangeSeq = 0;

    function hybridHistorySnapshot() {
      const hybridHistory = (globalThis as any)?.webf?.hybridHistory;
      const buildContextStack = (hybridHistory?.buildContextStack as any[]) ?? [];
      const top = buildContextStack.length > 0 ? buildContextStack[buildContextStack.length - 1] : undefined;
      return {
        path: hybridHistory?.path,
        state: hybridHistory?.state,
        stackLength: buildContextStack.length,
        stackTop: top ? { path: top.path, state: top.state } : undefined,
      };
    }

    function trackHybridRouterChange(stage: string, event: Event, seq: number) {
      const detail = (event as any)?.detail;
      const anyEvent = event as any;
      debugLog(`hybridrouterchange:${stage}`, {
        seq,
        type: event.type,
        timeStamp: (event as any)?.timeStamp,
        bubbles: (event as any)?.bubbles,
        composed: (event as any)?.composed,
        eventPhase: (event as any)?.eventPhase,
        targetTag: (event.target as any)?.tagName,
        currentTargetTag: (event.currentTarget as any)?.tagName,
        kind: anyEvent.kind ?? detail?.kind,
        path: anyEvent.path ?? detail?.path,
        state: anyEvent.state ?? detail?.state,
        detail,
        routeContext: {
          activePath: routeContext.activePath,
          mountedPath: routeContext.mountedPath,
          patternPath: routeContext.path,
          routeEventKind: routeContext.routeEventKind,
        },
        webfRouter: {
          path: WebFRouter.path,
          state: WebFRouter.state,
          stackTopPath: WebFRouter.stack.length > 0 ? WebFRouter.stack[WebFRouter.stack.length - 1]?.path : undefined,
          stackLength: WebFRouter.stack.length,
        },
        hybridHistory: hybridHistorySnapshot(),
      });
    }

    function updateRoutePatternsFromSlots() {
      const nodes = flattenRouteSlotVNodes(slots.default?.() ?? []);
      const patterns: string[] = [];
      for (const node of nodes) {
        if (!isRouteVNode(node)) continue;
        const path = (node.props as any)?.path;
        if (typeof path === 'string') patterns.push(path);
      }
      routePatternsRef.value = patterns;
      debugLog('routes:patterns', { patterns });
    }

    function syncFromRuntime(source: string, event?: Event, seq?: number) {
      const eventDetail = (event as any)?.detail;
      const routeEvent = event as any;

      const newStack = WebFRouter.stack;
      const stackTopPath = newStack.length > 0 ? newStack[newStack.length - 1]?.path : undefined;
      const prevActivePath = routeContext.activePath;

      const eventKind = (routeEvent?.kind ?? eventDetail?.kind) as HybridRouterChangeKind | undefined;
      const eventPath = (routeEvent?.path ?? eventDetail?.path) as string | undefined;
      const eventState = routeEvent?.state ?? eventDetail?.state;

      let newActivePath = stackTopPath ?? WebFRouter.path;
      let activePathDecision: { activePath: string | undefined; reason: string } | undefined;

      if (event?.type === 'hybridrouterchange') {
        activePathDecision = __unstable_deriveActivePathFromHybridRouterChange({
          kind: eventKind,
          path: eventPath,
          currentActivePath: prevActivePath,
          routerPath: WebFRouter.path,
          stackTopPath,
        });

        newActivePath = activePathDecision.activePath ?? newActivePath;

        debugLog('routes:activePathDecision', {
          source,
          seq,
          prevActivePath,
          event: { kind: eventKind, path: eventPath },
          stackTopPath,
          routerPath: WebFRouter.path,
          ...activePathDecision,
          debugEnableHint: `set globalThis.${debugFlagName()} = true`,
        });
      }

      stack.value = newStack;
      preMountedPaths.value = preMountedPaths.value.filter((p) => newStack.some((entry) => entry.path === p));

      const bestMatch = newActivePath ? findBestMatch(routePatternsRef.value, newActivePath) : null;
      const routeParams: RouteParams | undefined = bestMatch?.params || undefined;

      const activeEntry =
        [...newStack].reverse().find((entry) => entry.path === newActivePath) ??
        (newStack.length > 0 ? newStack[newStack.length - 1] : undefined);

      const isActiveKind = event?.type === 'hybridrouterchange' && eventKind !== undefined && eventKind !== 'didPop';
      const preferredState = isActiveKind ? eventState : undefined;
      const computedState = preferredState ?? activeEntry?.state ?? eventState ?? WebFRouter.state;

      routeContext.path = bestMatch?.path;
      routeContext.mountedPath = newActivePath;
      routeContext.activePath = newActivePath;
      routeContext.params = computedState;
      routeContext.routeParams = routeParams;
      routeContext.routeEventKind = eventKind;

      let routerLinks: Array<{ path: string | null; title: string | null }> = [];
      try {
        routerLinks = Array.from(document.querySelectorAll('webf-router-link'))
          .slice(0, 20)
          .map((el) => ({
            path: el.getAttribute('path'),
            title: el.getAttribute('title'),
          }));
      } catch {
      }

      debugLog('routes:sync', {
        source,
        seq,
        event: {
          type: event?.type,
          kind: eventKind,
          path: eventPath,
        },
        detail: eventDetail,
        webf: {
          path: WebFRouter.path,
          state: WebFRouter.state,
          stack: newStack,
        },
        computed: {
          stackTopPath,
          bestMatch,
          routeParams,
          activePathDecision,
          computedState,
        },
        preMountedPaths: preMountedPaths.value,
        mountedPath: routeContext.mountedPath,
        patternPath: routeContext.path,
        routerLinks,
        debugEnableHint: `set globalThis.${debugFlagName()} = true`,
      });
    }

    const handleRouteChange = (event: Event) => {
      hybridChangeSeq += 1;
      const seq = hybridChangeSeq;

      trackHybridRouterChange('capture', event, seq);
      syncFromRuntime('hybridrouterchange:capture', event, seq);

      queueMicrotask(() => {
        trackHybridRouterChange('microtask', event, seq);
        syncFromRuntime('hybridrouterchange:microtask', event, seq);
      });
      setTimeout(() => {
        trackHybridRouterChange('timeout', event, seq);
        syncFromRuntime('hybridrouterchange:timeout', event, seq);
      }, 0);
    };

    // Listen to hybridrouterchange event
    onMounted(() => {
      updateRoutePatternsFromSlots();
      syncFromRuntime('mount');
      document.addEventListener('hybridrouterchange', handleRouteChange);

      __unstable_setEnsureRouteMountedCallback((pathname: string) => {
        if (!pathname) return;

        const bestMatch = findBestMatch(routePatternsRef.value, pathname);
        if (!bestMatch) return;

        const selector = `webf-router-link[path="${escapeAttributeValue(pathname)}"]`;
        if (document.querySelector(selector)) return;

        debugLog('routes:ensureRouteMounted', {
          pathname,
          bestMatch,
          selector,
          hasElement: Boolean(document.querySelector(selector)),
        });

        let resolveFn: (() => void) | undefined;
        const promise = new Promise<void>((resolve) => {
          resolveFn = resolve;
        });

        pendingEnsureResolvers.set(pathname, [
          ...(pendingEnsureResolvers.get(pathname) ?? []),
          resolveFn!,
        ]);

        preMountedPaths.value = preMountedPaths.value.includes(pathname) ? preMountedPaths.value : [...preMountedPaths.value, pathname];

        return promise;
      });
    });

    onUnmounted(() => {
      document.removeEventListener('hybridrouterchange', handleRouteChange);
      __unstable_setEnsureRouteMountedCallback(null);
    });

    onUpdated(() => {
      updateRoutePatternsFromSlots();
    });

    watchPostEffect(() => {
      void stack.value;
      void preMountedPaths.value;
      void routeContext.activePath;
      void routePatternsRef.value;

      for (const [pathname, resolvers] of pendingEnsureResolvers.entries()) {
        const selector = `webf-router-link[path="${escapeAttributeValue(pathname)}"]`;
        if (!document.querySelector(selector)) continue;
        for (const resolve of resolvers) resolve();
        pendingEnsureResolvers.delete(pathname);
      }
    });

    return () => {
      const slotNodes = flattenRouteSlotVNodes(slots.default?.() ?? []);

      const declaredRoutes: VNode[] = [];
      const patterns: string[] = [];
      const declaredPaths = new Set<string>();
      const declaredRouteByPattern = new Map<string, VNode>();

      for (const node of slotNodes) {
        if (!isRouteVNode(node)) {
          declaredRoutes.push(node);
          continue;
        }

        const patternPath: string | undefined = (node.props as any)?.path;
        if (!patternPath) {
          declaredRoutes.push(node);
          continue;
        }

        patterns.push(patternPath);
        declaredPaths.add(patternPath);
        declaredRouteByPattern.set(patternPath, node);

        const mountedPath: string = (node.props as any)?.mountedPath ?? patternPath;

        declaredRoutes.push(
          h(
            RouteContextProvider,
            { key: `declared:${patternPath}`, patternPath, mountedPath },
            {
              default: () => [node],
            }
          )
        );
      }

      const mountedPaths: string[] = [];
      for (const entry of stack.value) mountedPaths.push(entry.path);
      for (const path of preMountedPaths.value) mountedPaths.push(path);
      if (routeContext.activePath && !mountedPaths.includes(routeContext.activePath)) mountedPaths.push(routeContext.activePath);

      debugLog('routes:render', {
        activePath: routeContext.activePath,
        patternPath: routeContext.path,
        mountedPath: routeContext.mountedPath,
        mountedPaths,
      });

      const dynamicRoutes: VNode[] = [];
      const seenMountedPaths = new Set<string>();

      for (const mountedPath of mountedPaths) {
        if (seenMountedPaths.has(mountedPath)) continue;
        seenMountedPaths.add(mountedPath);
        if (declaredPaths.has(mountedPath)) continue;

        const bestMatch = findBestMatch(patterns, mountedPath);
        if (!bestMatch) continue;

        const matchingRouteNode = declaredRouteByPattern.get(bestMatch.path);
        if (!matchingRouteNode) continue;

        const routeComponent = matchingRouteNode.type as any;
        const routeInstance = h(routeComponent, {
          ...(matchingRouteNode.props as any),
          mountedPath,
          key: `route:${mountedPath}`,
        });

        dynamicRoutes.push(
          h(
            RouteContextProvider,
            { key: `dynamic:${mountedPath}`, patternPath: bestMatch.path, mountedPath },
            {
              default: () => [routeInstance],
            }
          )
        );
      }

      return h(Fragment, null, [...declaredRoutes, ...dynamicRoutes]);
    };
  }
});
