import {DOMMatrix} from "../../geometry/dom_matrix";

interface Path2D {
  closePath(): SupportAsync<DartImpl<void>>;
  moveTo(x: number, y: number): SupportAsync<DartImpl<void>>;
  lineTo(x: number, y: number): SupportAsync<DartImpl<void>>;
  bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): SupportAsync<DartImpl<void>>;
  quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): SupportAsync<DartImpl<void>>;
  arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): SupportAsync<DartImpl<void>>;
  arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): SupportAsync<DartImpl<void>>;
  ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): SupportAsync<DartImpl<void>>;
  rect(x: number, y: number, w: number, h: number): SupportAsync<DartImpl<void>>;
  roundRect(x: number, y: number, w: number, h: number, radii: number | number[]): void;
  addPath(path: Path2D, matrix?: DOMMatrix): void;
  new(init?: Path2D | string): Path2D;
}