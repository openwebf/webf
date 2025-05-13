import { EventHandler, MouseEventHandler } from "react";
import { createComponent } from "../utils/CreateComponent";

interface FlutterCupertinoButtonProps {
  variant?: string;
  onClick?: MouseEventHandler;
  children?: React.ReactNode;
}

export const FlutterCupertinoButton = createComponent({
  tagName: 'flutter-cupertino-button',
  displayName: 'FlutterCupertinoButton',
  events: {
    onClick: 'click'
  }
}) as React.ComponentType<FlutterCupertinoButtonProps & { ref?: React.Ref<HTMLUnknownElement> }>

export default FlutterCupertinoButton;