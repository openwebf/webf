import { EventHandler, FC, ReactNode, SyntheticEvent, useState } from "react";
import { createComponent } from "../utils/CreateComponent";

export interface HybridRouterChangeEvent extends SyntheticEvent {
  readonly state: any;
  readonly kind: string;
  readonly path: string;
}

export type HybridRouterChangeEventHandler<T = Element> = EventHandler<HybridRouterChangeEvent>;

export interface WebFHybridRouterProps {
  path: string;
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  children?: ReactNode;
}

const RawWebFRouterLink = createComponent({
  tagName: 'webf-router-link',
  displayName: 'WebFRouterLink',
  events: {
    onScreen: 'onscreen'
  }
}) as React.ComponentType<WebFHybridRouterProps & { children?: React.ReactNode; ref?: React.Ref<HTMLUnknownElement> }>

export const WebFRouterLink: FC<WebFHybridRouterProps> = function (props: WebFHybridRouterProps) {
  const [isRender, enableRender] = useState(false);

  const handleOnScreen = (event: HybridRouterChangeEvent) => {
    enableRender(true);
    if (props.onScreen) {
      props.onScreen!(event);
    }
  };

  return (
    <RawWebFRouterLink path={props.path} onScreen={handleOnScreen} offScreen={props.offScreen}>
      {isRender ? props.children : null}
    </RawWebFRouterLink>
  );
}