import { EventHandler, SyntheticEvent } from "react";
import { createComponent } from "../utils/CreateComponent";

interface FlutterCupertinoModalPopupProps {
  onClose?: EventHandler<SyntheticEvent>;
  height?: string;
  maskClosable?: string;
  backgroundOpacity?: string;
  surfacePainted?: string;
  children?: React.ReactNode;
}

export interface FlutterCupertinoModalPopupElement extends HTMLElement {
  show: () => void;
  hide: () => void;
}

export const FlutterCupertinoModalPopup = createComponent({
  tagName: 'flutter-cupertino-modal-popup',
  displayName: 'FlutterCupertinoModalPopup',
  events: {
    onClose: 'close'
  }
}) as React.ComponentType<FlutterCupertinoModalPopupProps & { ref?: React.Ref<FlutterCupertinoModalPopupElement> }>

export default FlutterCupertinoModalPopup;