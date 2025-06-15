interface FlutterPopupProperties {
  open?: boolean;
  title?: string;
  showClose: boolean;
}

interface FlutterPopupEvents {
  cancel: Event;
  back: Event;
  close: Event;
  mask: Event;
}
