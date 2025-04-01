import {Event} from "../dom/events/event";

interface HybridRouterChangeEvent extends Event {
  readonly state: any;
  readonly kind: string;
  readonly path: string;
  new(): HybridRouterChangeEvent;
}