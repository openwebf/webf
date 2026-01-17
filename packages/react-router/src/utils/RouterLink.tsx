import React, { EventHandler, FC, ReactNode, SyntheticEvent, useState } from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";

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
export interface WebFRouterLinkElement extends WebFElementWithMethods<{}> {}

// Create the raw component using createWebFComponent
const RawWebFRouterLink = createWebFComponent<WebFRouterLinkElement, WebFHybridRouterProps>({
  tagName: 'webf-router-link',
  displayName: 'WebFRouterLink',

  // Map props to attributes
  attributeProps: ['path', 'title', 'theme'],

  // Event handlers
  events: [
    {
      propName: 'onScreen',
      eventName: 'onscreen',
      handler: (callback) => (event) => {
        // Cast through unknown first for proper type conversion
        callback(event as unknown as HybridRouterChangeEvent);
      },
    },
    {
      propName: 'offScreen',
      eventName: 'offscreen',
      handler: (callback) => (event) => {
        // Cast through unknown first for proper type conversion
        callback(event as unknown as HybridRouterChangeEvent);
      },
    },
    {
      propName: 'onPrerendering',
      eventName: 'prerendering',
      handler: (callback) => (event) => {
        callback(event as unknown as HybridRouterPrerenderingEvent);
      },
    },
  ],
});

export const WebFRouterLink: FC<WebFHybridRouterProps> = function (props: WebFHybridRouterProps) {
  const [isRender, enableRender] = useState(false);

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
    <RawWebFRouterLink
      title={props.title}
      path={props.path}
      theme={props.theme}
      onScreen={handleOnScreen}
      offScreen={props.offScreen}
      onPrerendering={handlePrerendering}
    >
      {isRender ? props.children : null}
    </RawWebFRouterLink>
  );
}
