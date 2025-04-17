import { EventHandler, MouseEventHandler, SyntheticEvent, TouchEventHandler } from "react";
import { createComponent } from "../utils/CreateComponent";
import { HybridRouterChangeEventHandler } from './RouterLink';

interface WebFHybridRouterProps {
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  onTouchStart?: TouchEventHandler;
  onTouchMove?: TouchEventHandler;
  onTouchEnd?: TouchEventHandler;
  onTouchCancel?: TouchEventHandler;
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
    onTouchCancel: 'touchcancel'
  }
}) as React.ComponentType<WebFHybridRouterProps & { children?: React.ReactNode; ref?: React.Ref<HTMLUnknownElement> }>
