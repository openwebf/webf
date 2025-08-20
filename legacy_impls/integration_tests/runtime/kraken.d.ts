/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
type MethodCallHandler = (args: any) => any;
interface MethodChannel {
    addMethodCallHandler(method: string, handler: MethodCallHandler): void;
    removeMethodCallHandler(method: string): void;
    clearMethodCallHandler(): void;
    invokeMethod(method: string, ...args: any[]): Promise<string>
}

interface WebF {
    invokeModule: (module: string, method: string, params?: any | null, fn?: (err: Error, data: any) => any) => any;
    addWebfModuleListener: (moduleName: string, fn: (event: Event, extra: any) => any) => void;
    methodChannel: MethodChannel;
}

declare const webf: WebF;

interface Connection {
  isConnected: boolean;
  type: string;
}

interface DeviceInfo {
  brand: string;
  isPhysicalDevice: boolean;
  platformName: string;
}

declare enum PointerChange {
  cancel,
  add,
  remove,
  hover,
  down,
  move,
  up
}


declare enum PointerSignalKind {
  none,
  scroll,
  unknown
}

type SimulatePointer = (list: [number, number, number, number?, number?, number?][], pointer: number) => void;
type SimulateInputText = (chars: string) => void;
declare const simulatePointer: SimulatePointer;
declare const simulateInputText: SimulateInputText;

interface Navigator {
  connection: {
    getConnectivity(): Connection;
  }
  getDeviceInfo(): DeviceInfo;
}

interface HTMLDivElement {
    toBlob(devicePixelRatio: number): Promise<Blob>;
}

interface HTMLCanvasElement {
    toBlob(devicePixcelRatio: number): Promise<Blob>;
}

interface HTMLMediaElement {
  /**
   * The HTMLMediaElement.fastSeek() method quickly seeks the media to the new time with precision tradeoff.
   * @param time A double.
   */
  fastSeek(time: number): void;
}

interface HTMLElement {
    toBlob(devicePixcelRatio: number): Promise<Blob>;
}

/**
 * The mocked local http server origin.
 */
declare const LOCAL_HTTP_SERVER :string;
