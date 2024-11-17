import {HTMLElement} from "../html_element";

interface WidgetElement extends HTMLElement {

  getPropertyValue(key: string): any;
  getPropertyValueAsync(key: string): Promise<any>;

  setPropertyValue(key: string, value: any): void;
  setPropertyValueAsync(key: string, value: any): void;

  callMethod(methodName: string, ...args: any[]): any;
  callAsyncMethod(methodName: string, ...args: any[]): Promise<void>;

  new(): void;
}