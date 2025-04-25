import { EventHandler, MouseEventHandler, SyntheticEvent, TouchEventHandler } from "react";
import { createComponent } from "../utils/CreateComponent";
import { HybridRouterChangeEventHandler } from './RouterLink';

interface WebFHybridRouterProps {
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  onTouchStart?: TouchEventHandler<HTMLElement>;
  onTouchMove?: TouchEventHandler<HTMLElement>;
  onTouchEnd?: TouchEventHandler<HTMLElement>;
  onTouchCancel?: TouchEventHandler<HTMLElement>;
  onClick?: MouseEventHandler<HTMLElement>;
}

export const WebFTouchArea = createComponent({
  tagName: 'webf-toucharea',
  displayName: 'WebFTouchArea',
  events: {
    onScreen: 'onscreen',
    offScreen: 'offscreen',
    onTouchStart: 'touchstart',
    onTouchMove: 'touchmove',
    onTouchEnd: 'touchend',
    onTouchCancel: 'touchcancel',
    onClick: 'click'
  }
}) as React.ComponentType<WebFHybridRouterProps & { children?: React.ReactNode; ref?: React.Ref<HTMLUnknownElement> }>
