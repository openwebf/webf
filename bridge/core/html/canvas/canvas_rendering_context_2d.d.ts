import {HTMLImageElement} from "../html_image_element";
import {HTMLCanvasElement} from "./html_canvas_element";
import {Path2D} from "./path_2d";
import {CanvasPattern} from "./canvas_pattern";

interface CanvasRenderingContext2D extends CanvasRenderingContext {
    fillStyle: SupportAsync<string | CanvasGradient | null>;
    direction: SupportAsync<DartImpl<string>>;
    font: SupportAsync<DartImpl<string>>;
    strokeStyle: SupportAsync<string | CanvasGradient | null>;
    lineCap: SupportAsync<DartImpl<string>>;
    lineDashOffset: SupportAsync<DartImpl<double>>;
    lineJoin: SupportAsync<DartImpl<string>>;
    lineWidth: SupportAsync<DartImpl<double>>;
    miterLimit: SupportAsync<DartImpl<double>>;
    textAlign: SupportAsync<DartImpl<string>>;
    textBaseline: SupportAsync<DartImpl<string>>;
    // @TODO: Following number should be double.
    // Reference https://html.spec.whatwg.org/multipage/canvas.html
    arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): SupportAsync<DartImpl<void>>;
    arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): SupportAsync<DartImpl<void>>;
    beginPath(): SupportAsync<DartImpl<void>>;
    bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): SupportAsync<DartImpl<void>>;
    clearRect(x: number, y: number, w: number, h: number): SupportAsync<DartImpl<void>>;
    closePath(): SupportAsync<DartImpl<void>>;
    clip(path?: Path2D, fillRule?: string): SupportAsync<DartImpl<void>>;
    drawImage(image: HTMLImageElement, sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number): SupportAsync<DartImpl<void>>;
    drawImage(image: HTMLImageElement, dx: number, dy: number, dw: number, dh: number): SupportAsync<DartImpl<void>>;
    drawImage(image: HTMLImageElement, dx: number, dy: number): SupportAsync<DartImpl<void>>;
    ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): SupportAsync<DartImpl<void>>;
    fill(path?: Path2D | string, fillRule?: string): SupportAsyncManual<void>;
    fillRect(x: number, y: number, w: number, h: number): SupportAsync<DartImpl<void>>;
    fillText(text: string, x: number, y: number, maxWidth?: number): SupportAsync<DartImpl<void>>;
    lineTo(x: number, y: number): SupportAsync<DartImpl<void>>;
  measureText(text: string): SupportAsync<TextMetrics>;
    moveTo(x: number, y: number): SupportAsync<DartImpl<void>>;
    rect(x: number, y: number, w: number, h: number): SupportAsync<DartImpl<void>>;
    restore(): SupportAsync<DartImpl<void>>;
    resetTransform(): SupportAsync<DartImpl<void>>;
    rotate(angle: number): SupportAsync<DartImpl<void>>;
    roundRect(x: number, y: number, w: number, h: number, radii: number | number[]): SupportAsyncManual<void>;
    quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): SupportAsync<DartImpl<void>>;
    stroke(path?: Path2D): SupportAsync<DartImpl<void>>;
    strokeRect(x: number, y: number, w: number, h: number): SupportAsync<DartImpl<void>>;
    save(): SupportAsync<DartImpl<void>>;
    scale(x: number, y: number): SupportAsync<DartImpl<void>>;
    strokeText(text: string, x: number, y: number, maxWidth?: number): SupportAsync<DartImpl<void>>;
    setTransform(a: number, b: number, c: number, d: number, e: number, f: number): SupportAsync<DartImpl<void>>;
    transform(a: number, b: number, c: number, d: number, e: number, f: number): SupportAsync<DartImpl<void>>;
    translate(x: number, y: number): SupportAsync<DartImpl<void>>;
    createLinearGradient(x0: number, y0: number, x1: number, y1: number): SupportAsync<CanvasGradient>;
    createRadialGradient(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number): SupportAsync<CanvasGradient>;
    createPattern(image: HTMLImageElement | HTMLCanvasElement, repetition: string): SupportAsyncManual<CanvasPattern>;
    reset(): SupportAsync<DartImpl<void>>;
    new(): void;
}
