import {HTMLImageElement} from "../html_image_element";
import {HTMLCanvasElement} from "./html_canvas_element";
import {Path2D} from "./path_2d";
import {CanvasPattern} from "./canvas_pattern";

interface CanvasRenderingContext2D extends CanvasRenderingContext {
    fillStyle: string | CanvasGradient | null;
    direction: string;
    font: string;
    strokeStyle: string | CanvasGradient | null;
    lineCap: string;
    lineDashOffset: number;
    lineJoin: string;
    lineWidth: number;
    miterLimit: number;
    textAlign: string;
    textBaseline: string;
    // @TODO: Following number should be double.
    // Reference https://html.spec.whatwg.org/multipage/canvas.html
    arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void;
    arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void;
    beginPath(): void;
    bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void;
    clearRect(x: number, y: number, w: number, h: number): void;
    closePath(): void;
    clip(path?: Path2D, fillRule?: string): void;
    drawImage(image: HTMLImageElement, sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number): void;
    drawImage(image: HTMLImageElement, dx: number, dy: number, dw: number, dh: number): void;
    drawImage(image: HTMLImageElement, dx: number, dy: number): void;
    ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void;
    fill(path?: Path2D | string, fillRule?: string): void;
    fillRect(x: number, y: number, w: number, h: number): void;
    fillText(text: string, x: number, y: number, maxWidth?: number): void;
    lineTo(x: number, y: number): void;
    measureText(text: string): TextMetrics;
    moveTo(x: number, y: number): void;
    rect(x: number, y: number, w: number, h: number): void;
    restore(): void;
    resetTransform(): void;
    rotate(angle: number): void;
    roundRect(x: number, y: number, w: number, h: number, radii: number | number[]): void;
    quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): void;
    stroke(path?: Path2D): void;
    strokeRect(x: number, y: number, w: number, h: number): void;
    save(): void;
    scale(x: number, y: number): void;
    strokeText(text: string, x: number, y: number, maxWidth?: number): void;
    setTransform(a: number, b: number, c: number, d: number, e: number, f: number): void;
    transform(a: number, b: number, c: number, d: number, e: number, f: number): void;
    translate(x: number, y: number): void;
    createLinearGradient(x0: number, y0: number, x1: number, y1: number): CanvasGradient;
    createRadialGradient(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number): CanvasGradient;
    createPattern(image: HTMLImageElement | HTMLCanvasElement, repetition: string): CanvasPattern;
    reset(): void;
    new(): void;
}
