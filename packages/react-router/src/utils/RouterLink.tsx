import React, { EventHandler, FC, ReactNode, SyntheticEvent, useState, useEffect, useRef } from "react";
import { createWebFComponent } from "@openwebf/react-core-ui";
import { isWebF } from "../platform";
import { getBrowserHistory } from "../platform/browserHistory";

export interface HybridRouterChangeEvent extends SyntheticEvent {
  readonly state: any;
  readonly kind: 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext';
  readonly path: string;
}

export type HybridRouterChangeEventHandler = EventHandler<HybridRouterChangeEvent>;

export interface HybridRouterPrerenderingEvent extends SyntheticEvent {}

export type HybridRouterPrerenderingEventHandler = EventHandler<HybridRouterPrerenderingEvent>;

export interface WebFHybridRouterProps {
  path: string;
  title?: string;
  theme?: 'material' | 'cupertino';
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  onPrerendering?: HybridRouterPrerenderingEventHandler;
  children?: ReactNode;
}

// Define the element interface for WebFRouterLink
export interface WebFRouterLinkElement {
  // Generic element interface
}

// Lazily create the WebF component only when needed
let RawWebFRouterLink: FC<WebFHybridRouterProps> | null = null;

function getRawWebFRouterLink(): FC<WebFHybridRouterProps> {
  if (RawWebFRouterLink) return RawWebFRouterLink;

  RawWebFRouterLink = createWebFComponent<WebFRouterLinkElement, WebFHybridRouterProps>({
    tagName: 'webf-router-link',
    displayName: 'WebFRouterLink',

    // Map props to attributes
    attributeProps: ['path', 'title', 'theme'],

    // Event handlers
    events: [
      {
        propName: 'onScreen',
        eventName: 'onscreen',
        handler: (callback: any) => (event: any) => {
          callback(event as unknown as HybridRouterChangeEvent);
        },
      },
      {
        propName: 'offScreen',
        eventName: 'offscreen',
        handler: (callback: any) => (event: any) => {
          callback(event as unknown as HybridRouterChangeEvent);
        },
      },
      {
        propName: 'onPrerendering',
        eventName: 'prerendering',
        handler: (callback: any) => (event: any) => {
          callback(event as unknown as HybridRouterPrerenderingEvent);
        },
      },
    ],
  });

  return RawWebFRouterLink!;
}

/**
 * Browser-based RouterLink implementation
 * Used when running in standard browser environment instead of WebF
 */
const BrowserRouterLink: FC<WebFHybridRouterProps> = function (props: WebFHybridRouterProps) {
  const [isActive, setIsActive] = useState(false);
  const [isRender, setIsRender] = useState(false);
  const hasTriggeredOnScreen = useRef(false);

  useEffect(() => {
    const browserHistory = getBrowserHistory();
    const currentPath = browserHistory.path;

    // Check if this route matches the current path
    const isCurrentlyActive = currentPath === props.path;
    setIsActive(isCurrentlyActive);

    if (isCurrentlyActive && !hasTriggeredOnScreen.current) {
      hasTriggeredOnScreen.current = true;
      setIsRender(true);

      // Create a synthetic event for onScreen callback
      if (props.onScreen) {
        const syntheticEvent = {
          state: browserHistory.state,
          kind: 'didPush' as const,
          path: props.path,
          nativeEvent: new Event('onscreen'),
          currentTarget: null,
          target: null,
          bubbles: true,
          cancelable: false,
          defaultPrevented: false,
          eventPhase: 0,
          isTrusted: true,
          preventDefault: () => {},
          isDefaultPrevented: () => false,
          stopPropagation: () => {},
          isPropagationStopped: () => false,
          persist: () => {},
          timeStamp: Date.now(),
          type: 'onscreen',
        } as unknown as HybridRouterChangeEvent;
        props.onScreen(syntheticEvent);
      }
    }

    // Listen for route changes
    const handleRouteChange = (event: Event) => {
      const customEvent = event as CustomEvent;
      const newPath = customEvent.detail?.path || (event as any).path;
      const newIsActive = newPath === props.path;

      if (newIsActive && !isActive) {
        // Route became active
        hasTriggeredOnScreen.current = true;
        setIsRender(true);
        setIsActive(true);

        if (props.onScreen) {
          const syntheticEvent = {
            state: customEvent.detail?.state || (event as any).state,
            kind: (customEvent.detail?.kind || (event as any).kind) as 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext',
            path: newPath,
            nativeEvent: event,
            currentTarget: event.currentTarget,
            target: event.target,
            bubbles: true,
            cancelable: false,
            defaultPrevented: false,
            eventPhase: 0,
            isTrusted: true,
            preventDefault: () => {},
            isDefaultPrevented: () => false,
            stopPropagation: () => {},
            isPropagationStopped: () => false,
            persist: () => {},
            timeStamp: Date.now(),
            type: 'onscreen',
          } as unknown as HybridRouterChangeEvent;
          props.onScreen(syntheticEvent);
        }
      } else if (!newIsActive && isActive) {
        // Route became inactive
        setIsActive(false);

        if (props.offScreen) {
          const syntheticEvent = {
            state: customEvent.detail?.state || (event as any).state,
            kind: (customEvent.detail?.kind || (event as any).kind) as 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext',
            path: newPath,
            nativeEvent: event,
            currentTarget: event.currentTarget,
            target: event.target,
            bubbles: true,
            cancelable: false,
            defaultPrevented: false,
            eventPhase: 0,
            isTrusted: true,
            preventDefault: () => {},
            isDefaultPrevented: () => false,
            stopPropagation: () => {},
            isPropagationStopped: () => false,
            persist: () => {},
            timeStamp: Date.now(),
            type: 'offscreen',
          } as unknown as HybridRouterChangeEvent;
          props.offScreen(syntheticEvent);
        }
      }
    };

    document.addEventListener('hybridrouterchange', handleRouteChange);

    return () => {
      document.removeEventListener('hybridrouterchange', handleRouteChange);
    };
  }, [props.path, props.onScreen, props.offScreen, isActive]);

  // In browser mode, we render a div that acts as a route container
  // Only show content when route is rendered (similar to WebF behavior)
  return (
    <div
      data-path={props.path}
      data-title={props.title}
      style={{
        display: isActive ? 'block' : 'none',
        width: '100%',
        height: '100%',
      }}
    >
      {isRender ? props.children : null}
    </div>
  );
};

/**
 * WebF RouterLink implementation
 * Used in WebF native environment
 */
const WebFNativeRouterLink: FC<WebFHybridRouterProps> = function (props: WebFHybridRouterProps) {
  const [isRender, enableRender] = useState(false);
  const RawComponent = getRawWebFRouterLink();

  const handleOnScreen = (event: HybridRouterChangeEvent) => {
    enableRender(true);

    if (props.onScreen) {
      props.onScreen(event);
    }
  };

  const handlePrerendering = (event: HybridRouterPrerenderingEvent) => {
    enableRender(true);
    props.onPrerendering?.(event);
  };

  return (
    <RawComponent
      title={props.title}
      path={props.path}
      theme={props.theme}
      onScreen={handleOnScreen}
      offScreen={props.offScreen}
      onPrerendering={handlePrerendering}
    >
      {isRender ? props.children : null}
    </RawComponent>
  );
};

/**
 * Unified RouterLink component that works in both WebF and browser environments
 */
export const WebFRouterLink: FC<WebFHybridRouterProps> = function (props: WebFHybridRouterProps) {
  // Use WebF native implementation if in WebF environment
  if (isWebF()) {
    return <WebFNativeRouterLink {...props} />;
  }

  // Use browser-based implementation
  return <BrowserRouterLink {...props} />;
}
