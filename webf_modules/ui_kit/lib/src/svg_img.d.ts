interface FlutterSVGImgProperties {
  src: string;
  width?: number | string;
  height?: number | string;
  naturalWidth?: number;
  naturalHeight?: number;
  complete?: boolean;
}

interface FlutterSVGImgEvents {
  load: Event;
  error: Event;
}