/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLImageElement} from "../html_image_element";
import {ImageBitmap} from "../image_bitmap";
import {HTMLCanvasElement} from "./html_canvas_element";
import {Path2D} from "./path_2d";
import {CanvasPattern} from "./canvas_pattern";

interface CanvasRenderingContext2D extends CanvasRenderingContext {
    globalAlpha: number;
    globalCompositeOperation: string;
    fillStyle: string | CanvasGradient | CanvasPattern | null;
    direction: string;
    font: string;
    strokeStyle: string | CanvasGradient | CanvasPattern | null;
    lineCap: string;
    lineDashOffset: number;
    lineJoin: string;
    lineWidth: number;
    miterLimit: number;
    textAlign: string;
    textBaseline: string;
    shadowOffsetX: number;
    shadowOffsetY: number;
    shadowBlur: number;
    shadowColor: string;
    // @TODO: Following number should be double.
    // Reference https://html.spec.whatwg.org/multipage/canvas.html
    arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void;
    // Image data APIs (using `any` so they can be implemented purely on the C++ side without a dedicated IDL type)
    createImageData(sw: number, sh: number): any;
    createImageData(imagedata: any): any;
    getImageData(sx: number, sy: number, sw: number, sh: number): any;
    putImageData(imagedata: any, dx: number, dy: number, dirtyX?: number, dirtyY?: number, dirtyWidth?: number, dirtyHeight?: number): void;
    isPointInPath(path: Path2D | number, x: number, y?: string | number, fillRule?: string): boolean;
    isPointInStroke(path: Path2D, x: number, y: number): boolean;
    isPointInStroke(x: number, y: number): boolean;
    arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void;
    beginPath(): void;
    bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void;
    clearRect(x: number, y: number, w: number, h: number): void;
    closePath(): void;
    clip(path?: Path2D, fillRule?: string): void;
    drawImage(image: HTMLImageElement | ImageBitmap, sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number): void;
    drawImage(image: HTMLImageElement | ImageBitmap, dx: number, dy: number, dw: number, dh: number): void;
    drawImage(image: HTMLImageElement | ImageBitmap, dx: number, dy: number): void;
    ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void;
    fill(path?: Path2D | string, fillRule?: string): void;
    fillRect(x: number, y: number, w: number, h: number): void;
    fillText(text: string, x: number, y: number, maxWidth?: number): void;
    setLineDash(segments: number[]): void;
    getLineDash(): number[];
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
