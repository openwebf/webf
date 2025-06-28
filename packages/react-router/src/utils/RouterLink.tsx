import React, { EventHandler, FC, ReactNode, SyntheticEvent, useState } from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";

export interface HybridRouterChangeEvent extends SyntheticEvent {
  readonly state: any;
  readonly kind: 'didPushNext' | 'didPush' | 'didPop' | 'didPupNext';
  readonly path: string;
}

export type HybridRouterChangeEventHandler = EventHandler<HybridRouterChangeEvent>;

export interface WebFHybridRouterProps {
  path: string;
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  children?: ReactNode;
}

// Define the element interface for WebFRouterLink
export interface WebFRouterLinkElement extends WebFElementWithMethods<{}> {}

// Create the raw component using createWebFComponent
const RawWebFRouterLink = createWebFComponent<WebFRouterLinkElement, WebFHybridRouterProps>({
  tagName: 'webf-router-link',
  displayName: 'WebFRouterLink',
  
  // Map props to attributes
  attributeProps: ['path'],
  
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

  return (
    <RawWebFRouterLink path={props.path} onScreen={handleOnScreen} offScreen={props.offScreen}>
      {isRender ? props.children : null}
    </RawWebFRouterLink>
  );
}