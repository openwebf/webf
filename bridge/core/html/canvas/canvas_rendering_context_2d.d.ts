import {HTMLImageElement} from "../html_image_element";
import {HTMLCanvasElement} from "./html_canvas_element";

interface CanvasRenderingContext2D extends CanvasRenderingContext {
    fillStyle: string | CanvasGradient | null;
    direction: DartImpl<string>;
    font: DartImpl<string>;
    strokeStyle: string | CanvasGradient | null;
    lineCap: DartImpl<string>;
    lineDashOffset: DartImpl<double>;
    lineJoin: DartImpl<string>;
    lineWidth: DartImpl<double>;
    miterLimit: DartImpl<double>;
    textAlign: DartImpl<string>;
    textBaseline: DartImpl<string>;
    // @TODO: Following number should be double.
    // Reference https://html.spec.whatwg.org/multipage/canvas.html
    arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): DartImpl<void>;
    arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): DartImpl<void>;
    beginPath(): DartImpl<void>;
    bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): DartImpl<void>;
    clearRect(x: number, y: number, w: number, h: number): DartImpl<void>;
    closePath(): DartImpl<void>;
    clip(path?: string): DartImpl<void>;
    drawImage(image: HTMLImageElement, sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number): DartImpl<void>;
    drawImage(image: HTMLImageElement, dx: number, dy: number, dw: number, dh: number): DartImpl<void>;
    drawImage(image: HTMLImageElement, dx: number, dy: number): DartImpl<void>;
    ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): DartImpl<void>;
    fill(path?: string): DartImpl<void>;
    fillRect(x: number, y: number, w: number, h: number): DartImpl<void>;
    fillText(text: string, x: number, y: number, maxWidth?: number): DartImpl<void>;
    lineTo(x: number, y: number): DartImpl<void>;
    moveTo(x: number, y: number): DartImpl<void>;
    rect(x: number, y: number, w: number, h: number): DartImpl<void>;
    restore(): DartImpl<void>;
    resetTransform(): DartImpl<void>;
    rotate(angle: number): DartImpl<void>;
    quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): DartImpl<void>;
    stroke(): DartImpl<void>;
    strokeRect(x: number, y: number, w: number, h: number): DartImpl<void>;
    save(): DartImpl<void>;
    scale(x: number, y: number): DartImpl<void>;
    strokeText(text: string, x: number, y: number, maxWidth?: number): DartImpl<void>;
    setTransform(a: number, b: number, c: number, d: number, e: number, f: number): DartImpl<void>;
    transform(a: number, b: number, c: number, d: number, e: number, f: number): DartImpl<void>;
    translate(x: number, y: number): DartImpl<void>;
    createLinearGradient(x0: number, y0: number, x1: number, y1: number): CanvasGradient;
    createRadialGradient(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number): CanvasGradient;
    createPattern(image: HTMLImageElement | HTMLCanvasElement, repetition: string): CanvasPattern;
    reset(): DartImpl<void>;
    new(): void;
}
