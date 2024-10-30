import {Event} from "../dom/events/event";

interface HybridRouterChangeEvent extends Event {
  readonly state: any;
  readonly kind: string;
  readonly name: string;
  new(): HybridRouterChangeEvent;
}